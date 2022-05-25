// Copyright © 2018 Stormbird PTE. LTD.

import UIKit
import PromiseKit

protocol SettingsViewControllerDelegate: class, CanOpenURL {
    func settingsViewControllerAdvancedSettingsSelected(in controller: SettingsViewController)
    func settingsViewControllerShowSeedPhraseSelected(in controller: SettingsViewController)
    func settingsViewControllerWalletConnectSelected(in controller: SettingsViewController)
    func settingsViewControllerNameWalletSelected(in controller: SettingsViewController)
    func settingsViewControllerBlockscanChatSelected(in controller: SettingsViewController)
    func settingsViewControllerActiveNetworksSelected(in controller: SettingsViewController)
    func settingsViewControllerAboutSelected(in controller: SettingsViewController)
    func settingsViewControllerShouldShowRedirectAlert(in controller: SettingsViewController, for urlServiceProvider: URLServiceProvider)
}

class SettingsViewController: UIViewController {
    private let lock = Lock()
    private var config: Config
    private let keystore: Keystore
    private let account: Wallet
    private let analyticsCoordinator: AnalyticsCoordinator
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SettingTableViewCell.self)
        tableView.register(SwitchTableViewCell.self)
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = Metrics.anArbitraryRowHeightSoAutoSizingCellsWorkIniOS10
        tableView.tableFooterView = UIView.tableFooterToRemoveEmptyCellSeparators()

        return tableView
    }()
    private var viewModel: SettingsViewModel
    private let resolver = ContactUsEmailResolver()

    weak var delegate: SettingsViewControllerDelegate?

    init(config: Config, keystore: Keystore, account: Wallet, analyticsCoordinator: AnalyticsCoordinator) {
        self.config = config
        self.keystore = keystore
        self.account = account
        self.analyticsCoordinator = analyticsCoordinator
        viewModel = SettingsViewModel(account: account, keystore: keystore, blockscanChatUnreadCount: nil)
        super.init(nibName: nil, bundle: nil)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.anchorsConstraint(to: view)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = R.string.localizable.aSettingsNavigationTitle()
        view.backgroundColor = GroupedTable.Color.background
        navigationItem.largeTitleDisplayMode = .automatic
        tableView.backgroundColor = GroupedTable.Color.background
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.navigationBar.sizeToFit()
        }
        reflectCurrentWalletSecurityLevel()
    }

    func configure(blockscanChatUnreadCount: Int?) {
        viewModel = SettingsViewModel(account: account, keystore: keystore, blockscanChatUnreadCount: blockscanChatUnreadCount)
        tableView.reloadData()
        if let unreadCount = viewModel.blockscanChatUnreadCount, unreadCount > 0 {
            tabBarItem.badgeValue = String(unreadCount)
        } else {
            tabBarItem.badgeValue = nil
        }
    }

    private func reflectCurrentWalletSecurityLevel() {
        tableView.reloadData()
    }

    private func setPasscode(completion: ((Bool) -> Void)? = .none) {
        guard let navigationController = navigationController else { return }
        let viewModel = LockCreatePasscodeViewModel()
        let lock = LockCreatePasscodeCoordinator(navigationController: navigationController, model: viewModel)
        lock.start()
        lock.lockViewController.willFinishWithResult = { result in
            completion?(result)
            lock.stop()
        }
    }

    private func configureChangeWalletCellWithResolvedENS(_ row: SettingsWalletRow, indexPath: IndexPath, cell: SettingTableViewCell) {
        cell.configure(viewModel: .init(
            titleText: row.title,
            subTitleText: viewModel.addressReplacedWithENSOrWalletName(),
            icon: row.icon)
        )

        firstly {
            GetWalletNameCoordinator(config: config).getName(forAddress: account.address)
        }.done { [weak self] name in
            //NOTE check if still correct cell, since this is async
            guard let strongSelf = self, cell.indexPath == indexPath else { return }
            let viewModel: SettingTableViewCellViewModel = .init(
                    titleText: row.title,
                    subTitleText: strongSelf.viewModel.addressReplacedWithENSOrWalletName(name),
                    icon: row.icon
            )
            cell.configure(viewModel: viewModel)
        }.cauterize()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

extension SettingsViewController: CanOpenURL {

    func didPressViewContractWebPage(forContract contract: AlphaWallet.Address, server: RPCServer, in viewController: UIViewController) {
        delegate?.didPressViewContractWebPage(forContract: contract, server: server, in: viewController)
    }

    func didPressViewContractWebPage(_ url: URL, in viewController: UIViewController) {
        delegate?.didPressViewContractWebPage(url, in: viewController)
    }

    func didPressOpenWebPage(_ url: URL, in viewController: UIViewController) {
        delegate?.didPressOpenWebPage(url, in: viewController)
    }
}

extension SettingsViewController: SwitchTableViewCellDelegate {

    func cell(_ cell: SwitchTableViewCell, switchStateChanged isOn: Bool) {
        guard let indexPath = cell.indexPath else { return }

        switch viewModel.sections[indexPath.section] {
        case .system(let rows):
            switch rows[indexPath.row] {
            case .passcode:
                if isOn {
                    setPasscode { result in
                        cell.isOn = result
                    }
                } else {
                    lock.deletePasscode()
                }
            case .selectActiveNetworks:
                break
            }
        case .community:
            break
        }
    }
}

extension SettingsViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfSections(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sections[indexPath.section] {
        case .system(let rows):
            let row = rows[indexPath.row]
            switch row {
            case .passcode:
                let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: .init(
                    titleText: viewModel.passcodeTitle,
                    icon: R.image.faceId()!,
                    value: lock.isPasscodeSet)
                )
                cell.delegate = self

                return cell
            case .selectActiveNetworks:
                let cell: SettingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: .init(settingsSystemRow: row))

                return cell
            }
        case .community(let rows):
            let row = rows[indexPath.row]
            let cell: SettingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: .init(settingsCommunityRow: row))

            return cell
        }
    }
}

extension SettingsViewController: UITableViewDelegate {

    //Hide the footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch viewModel.sections[section] {
        case .system:
            return nil
        default:
            let headerView: SettingViewHeader = SettingViewHeader()
            let viewModel = SettingViewHeaderViewModel(section: self.viewModel.sections[section])
            headerView.configure(viewModel: viewModel)

            return headerView
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.sections[indexPath.section] {
        case .system(let rows):
            switch rows[indexPath.row] {
            case .passcode:
                break
            case .selectActiveNetworks:
                delegate?.settingsViewControllerActiveNetworksSelected(in: self)
            }
        case .community(let rows):
            switch rows[indexPath.row] {
            case .faq:
                logAccessFaq()
                delegate?.settingsViewControllerAboutSelected(in: self)
            case .discord:
                logAccessDiscord()
                delegate?.settingsViewControllerShouldShowRedirectAlert(in: self, for: .discord)
            case .telegramCustomer:
                logAccessTelegramCustomerSupport()
                delegate?.settingsViewControllerShouldShowRedirectAlert(in: self, for: .telegramCustomer)
            case .twitter:
                logAccessTwitter()
                delegate?.settingsViewControllerShouldShowRedirectAlert(in: self, for: .twitter)
            case .facebook:
                logAccessFacebook()
                delegate?.settingsViewControllerShouldShowRedirectAlert(in: self, for: .facebook)
            case .email:
                let attachments = Features.default.isAvailable(.isAttachingLogFilesToSupportEmailEnabled) ? DDLogger.logFilesAttachments : []
                resolver.present(from: self, attachments: attachments)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    private func openURL(_ provider: URLServiceProvider) {
        if let deepLinkURL = provider.deepLinkURL, UIApplication.shared.canOpenURL(deepLinkURL) {
            UIApplication.shared.open(deepLinkURL, options: [:], completionHandler: .none)
        } else {
            delegate?.didPressOpenWebPage(provider.remoteURL, in: self)
        }
    }
}

// MARK: Analytics
extension SettingsViewController {
    private func logAccessFaq() {
        analyticsCoordinator.log(navigation: Analytics.Navigation.faq)
    }

    private func logAccessDiscord() {
        analyticsCoordinator.log(navigation: Analytics.Navigation.discord)
    }

    private func logAccessTelegramCustomerSupport() {
        analyticsCoordinator.log(navigation: Analytics.Navigation.telegramCustomerSupport)
    }

    private func logAccessTwitter() {
        analyticsCoordinator.log(navigation: Analytics.Navigation.twitter)
    }

    private func logAccessReddit() {
        analyticsCoordinator.log(navigation: Analytics.Navigation.reddit)
    }

    private func logAccessFacebook() {
        analyticsCoordinator.log(navigation: Analytics.Navigation.facebook)
    }

    private func logAccessGithub() {
        analyticsCoordinator.log(navigation: Analytics.Navigation.github)
    }
}

extension SettingsViewController: RedirectAlertViewControllerDelegate {
    func redirectAlertViewController(redirectAlertViewController: RedirectAlertViewController, didTapCancelButton cancelButton: UIButton) {
        
    }
    
    func redirectAlertViewController(redirectAlertViewController: RedirectAlertViewController, didTapAllowButton allowButton: UIButton, forServiceProvider serviceProvider: URLServiceProvider) {
        openURL(serviceProvider)
    }
}
