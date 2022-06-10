// Copyright © 2018 Stormbird PTE. LTD.

import UIKit
import Result
import PromiseKit
import Combine

private let reuseIdentifier = "AccountWalletCollectionViewCell"

protocol TokensViewControllerDelegate: AnyObject {
    func viewWillAppear(in viewController: UIViewController)
    func didSelect(token: TokenObject, in viewController: UIViewController)
    func didHide(token: TokenObject, in viewController: UIViewController)
    func didTapOpenConsole(in viewController: UIViewController)
    func walletConnectSelected(in viewController: UIViewController)
    func whereAreMyTokensSelected(in viewController: UIViewController)
    func didPressAddHideTokens(viewModel: TokensViewModel)
    
    func didSelectAccount(account: Wallet, in viewController: TokensViewController)
    func didDeleteAccount(account: Wallet, in viewController: TokensViewController)
    func didSelectInfoForAccount(account: Wallet, sender: UIView, in viewController: TokensViewController)
}

class TokensViewController: UIViewController {
    private let tokenCollection: TokenCollection
    private let assetDefinitionStore: AssetDefinitionStore

    private (set) var viewModel: TokensViewModel {
        didSet {
            viewModel.walletConnectSessions = oldValue.walletConnectSessions
            viewModel.isSearchActive = oldValue.isSearchActive
            viewModel.filter = oldValue.filter
        }
    }
    let accountsViewModel: AccountsViewModel
    private let sessions: ServerDictionary<WalletSession>
    private let account: Wallet

    private let walletsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = SnappingCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 200)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AccountWalletCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    private var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.pageIndicatorTintColor = .gray
        pc.currentPageIndicatorTintColor = EthernityColors.electricYellow
        
        return pc
    }()
    
    lazy private var tableViewFilterView: ScrollableSegmentedControl = {
        let cellConfiguration = Style.ScrollableSegmentedControlCell.configuration
        let controlConfiguration = Style.ScrollableSegmentedControl.configuration
        let cells = TokensViewModel.segmentedControlTitles.map { title in
            ScrollableSegmentedControlCell(frame: .zero, title: title, configuration: cellConfiguration)
        }
        let control = ScrollableSegmentedControl(cells: cells, configuration: controlConfiguration)
        control.setSelection(cellIndex: 0, animated: false)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let segmentedControl : UISegmentedControl = {
        let segmentedControl = UISegmentedControl (items: TokensViewModel.segmentedControlTitles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = UIColor(hex: "0C86FF")
        segmentedControl.layer.backgroundColor = UIColor.white.cgColor
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.tintColor = UIColor.white
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white, NSAttributedString.Key.font: Fonts.regular(size: 14)], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(hex: "6D6D6D"), NSAttributedString.Key.font: Fonts.regular(size: 13)], for: .normal)
        
        return segmentedControl
    }()
    
    private var filtersSegmentedControl : CustomSegmentedControl?
    private let emptyTableView: EmptyTableView = {
        let view = EmptyTableView(title: "", image: R.image.activities_empty_list()!, heightAdjustment: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    private var emptyTableViewHeightConstraint: NSLayoutConstraint?
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(FungibleTokenViewCell.self)
        tableView.register(EthTokenViewCell.self)
        tableView.register(NonFungibleTokenViewCell.self)
        tableView.register(ServerTableViewCell.self)
        tableView.register(OpenSeaNonFungibleTokenPairTableCell.self)

        tableView.registerHeaderFooterView(GeneralTableViewSectionHeader<CustomSegmentedControl>.self)
        tableView.registerHeaderFooterView(GeneralTableViewSectionHeader<AddHideTokensView>.self)
        tableView.registerHeaderFooterView(ActiveWalletSessionView.self)
        //tableView.registerHeaderFooterView(GeneralTableViewSectionHeader<WalletSummaryView>.self)
        tableView.estimatedRowHeight = DataEntry.Metric.TableView.estimatedRowHeight
        tableView.tableFooterView = UIView.tableFooterToRemoveEmptyCellSeparators()
        tableView.separatorInset = .zero

        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()
    private lazy var tableViewRefreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return control
    }()
    private (set) lazy var blockieImageView: BlockieImageView = BlockieImageView(size: .init(width: 24, height: 24))
    private var addHideButton: UIButton {
        let button  = UIButton()
        let imageButton = R.image.searchbar_add_hide_token()
        button.setImage(imageButton, for: .normal)
        button.backgroundColor = UIColor.white
        button.cornerRadius = 6
        button.contentEdgeInsets = .init(top:10, left: 10, bottom: 4, right: 4)
        button.addTarget(self, action: #selector(addHideToken), for: .touchUpInside)
        
        return button
    }
    
    private let searchController: UISearchController
    private lazy var searchBar: DummySearchView = {
        return DummySearchView(closure: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.enterSearchMode()
        }, button: addHideButton)
    }()


    private var isSearchBarConfigured = false
    private var bottomConstraint: NSLayoutConstraint!
    private lazy var keyboardChecker = KeyboardChecker(self, resetHeightDefaultValue: 0, ignoreBottomSafeArea: true)
    private let config: Config
    private let walletConnectCoordinator: WalletConnectCoordinator
    private lazy var whereAreMyTokensView: AddHideTokensView = {
        let view = AddHideTokensView()
        view.delegate = self
        view.configure(viewModel: ShowAddHideTokensViewModel.configuredForTestnet())

        return view
    }()

    weak var delegate: TokensViewControllerDelegate?

    private var walletSummaryView = WalletSummaryView(edgeInsets: .init(top: 10, left: 0, bottom: 0, right: 0), spacing: 0)
    private lazy var searchBarHeader: TokensViewController.ContainerView<DummySearchView> = {
        let header: TokensViewController.ContainerView<DummySearchView> = .init(subview: searchBar)
        header.useSeparatorLine = false

        return header
    }()
    private var cancellable = Set<AnyCancellable>()
    
    init(sessions: ServerDictionary<WalletSession>,
         account: Wallet,

         tokenCollection: TokenCollection,
         assetDefinitionStore: AssetDefinitionStore,
         tokensFilter: TokensFilter,
         config: Config,
         walletConnectCoordinator: WalletConnectCoordinator,
         walletBalanceService: WalletBalanceService,
         accountsViewModel: AccountsViewModel
    ) {
        self.sessions = sessions
        self.account = account
        self.tokenCollection = tokenCollection
        self.assetDefinitionStore = assetDefinitionStore
        self.config = config
        self.walletConnectCoordinator = walletConnectCoordinator
        self.accountsViewModel = accountsViewModel
        viewModel = TokensViewModel(tokensFilter: tokensFilter, tokens: [], config: config)

        searchController = UISearchController(searchResultsController: nil)

        super.init(nibName: nil, bundle: nil)

        
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false

        tableViewFilterView.addTarget(self, action: #selector(didTapSegment(_:)), for: .touchUpInside)
        tableViewFilterView.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
        
        filtersSegmentedControl = CustomSegmentedControl(subview: segmentedControl)

        
        view.addSubview(walletsCollectionView)
        view.addSubview(pageControl)
        
        walletsCollectionView.delegate = self
        walletsCollectionView.dataSource = self
        
        // Do any additional setup after loading the view.
        
        NSLayoutConstraint.activate([
            walletsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            walletsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            walletsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            walletsCollectionView.heightAnchor.constraint(equalToConstant: 300.0),
            
            pageControl.topAnchor.constraint(equalTo: walletsCollectionView.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
        view.addSubview(tableView)

        bottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        keyboardChecker.constraints = [bottomConstraint]

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: pageControl.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomConstraint
        ])
        

        tableView.addSubview(emptyTableView)
        let heightConstraint = emptyTableView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: 0)
        emptyTableViewHeightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            emptyTableView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            heightConstraint
        ])

        refreshView(viewModel: viewModel)

        setupFilteringWithKeyword()

        walletConnectCoordinator.sessions
            .receive(on: RunLoop.main)
            .sink { [weak self] sessions in
                guard let strongSelf = self else { return }

                let viewModel = strongSelf.viewModel
                viewModel.walletConnectSessions = sessions.count
                strongSelf.viewModel = viewModel

                strongSelf.tableView.reloadData()
            }.store(in: &cancellable)

//        let initialWalletSummary = WalletSummary(balances: [walletBalanceService.walletBalance(wallet: account)])

//        let walletSummary = walletBalanceService
//            .walletBalancePublisher(wallet: account)
//            .map { return WalletSummary(balances: [$0]) }
//            .receive(on: RunLoop.main)
//            .prepend(initialWalletSummary)
//            .eraseToAnyPublisher()
//
//        walletSummaryView.configure(viewModel: .init(walletSummary: walletSummary, config: config, alignment: .center))

        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(tableViewRefreshControl)
        tableView.separatorColor = .clear
        
        handleTokenCollectionUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.applyTintAdjustment()
        hidesBottomBarWhenPushed = false

        fetch()
        fixNavigationBarAndStatusBarBackgroundColorForiOS13Dot1()
        keyboardChecker.viewWillAppear()
        delegate?.viewWillAppear(in: self)
        hideNavigationBarTopSeparatorLine()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardChecker.viewWillDisappear()
        showNavigationBarTopSeparatorLine()
    }

    @objc func pullToRefresh() {
        tableViewRefreshControl.beginRefreshing()
        fetch()
    }
    
    @objc func addHideToken(){
        delegate?.didPressAddHideTokens(viewModel: self.viewModel)
    }

    func fetch() {
        tokenCollection.fetch()
    }

    override func viewDidLayoutSubviews() {
        //viewDidLayoutSubviews() is called many times
        configureSearchBarOnce()
    }

    private func reloadTableData() {
        tableView.reloadData()
    }

    private func reload() {
        reloadTableData()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func refreshView(viewModel: TokensViewModel) {
        view.backgroundColor = viewModel.backgroundColor
        tableView.backgroundColor = viewModel.walletTableBackground
    }

    private func handleTokenCollectionUpdates() {
        //NOTE: we don't apply .subscribe(on: DispatchQueue.main) for refresh table view immediatelly, otherwise an empty tokens view will be presented
        tokenCollection.tokensViewModel
            .sink { [weak self] viewModel in
                guard let strongSelf = self else { return }
                strongSelf.viewModel = viewModel
                strongSelf.refreshView(viewModel: viewModel)
                strongSelf.reload()

                if strongSelf.tableViewRefreshControl.isRefreshing {
                    strongSelf.tableViewRefreshControl.endRefreshing()
                }
            }.store(in: &cancellable)
    }

    @objc private func enterSearchMode() {
        let searchController = searchController
        navigationItem.searchController = searchController

        viewModel.isSearchActive = true
        viewModel.filter = viewModel.filter
        tableView.reloadData()

        DispatchQueue.main.async {
            searchController.isActive = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                searchController.searchBar.becomeFirstResponder()
            }
        }
    }
    
    @objc func segmentedValueChanged(_ sender:UISegmentedControl!)
    {
        let selectedIndex = UInt(sender.selectedSegmentIndex)
        let controlSelection = ControlSelection.selected(selectedIndex)
        guard let filter = viewModel.convertSegmentedControlSelectionToFilter(controlSelection) else { return }
        apply(filter: filter, withSegmentAtSelection: controlSelection)
        
        if filter == .assets {
            searchBar.buttonIsHidden(isHidden: false)
        }
        else {
            searchBar.buttonIsHidden(isHidden: true)
        }
    }
}

extension TokensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        didSelectToken(indexPath: indexPath)
    }

    //Hide the footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeaderInSection(for: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch viewModel.sections[section] {
//        case .walletSummary:
//            let header: TokensViewController.GeneralTableViewSectionHeader<WalletSummaryView> = tableView.dequeueReusableHeaderFooterView()
//            header.subview = walletSummaryView
//
//            return header
        case .filters:
            let header: TokensViewController.GeneralTableViewSectionHeader<CustomSegmentedControl> = tableView.dequeueReusableHeaderFooterView()
            header.subview = filtersSegmentedControl
            header.useSeparatorLine = false

            return header
        case .activeWalletSession(let count):
            let header: ActiveWalletSessionView = tableView.dequeueReusableHeaderFooterView()
            header.configure(viewModel: .init(count: count))
            header.delegate = self

            return header
        case .testnetTokens:
            let header: TokensViewController.GeneralTableViewSectionHeader<AddHideTokensView> = tableView.dequeueReusableHeaderFooterView()
            header.useSeparatorTopLine = true
            header.useSeparatorBottomLine = viewModel.isBottomSeparatorLineHiddenForTestnetHeader(section: section)
            header.subview = whereAreMyTokensView

            return header
        case .search:
            return searchBarHeader
        case .tokens, .collectiblePairs, .transactions:
            return nil
        }
    }

    // UIScrollViewDelegate calls

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        hideNavigationBarTopSeparatorLineInScrollEdgeAppearance()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y == 0 ? hideNavigationBarTopSeparatorLineInScrollEdgeAppearance() : showNavigationBarTopSeparatorLineInScrollEdgeAppearance()
        
//        pageControl.currentPage = Int(
//            (walletsCollectionView.contentOffset.x / walletsCollectionView.frame.width)
//                .rounded(.toNearestOrAwayFromZero)
//            )
    }

}

extension TokensViewController: ActiveWalletSessionViewDelegate {

    func view(_ view: ActiveWalletSessionView, didSelectTap sender: UITapGestureRecognizer) {
        delegate?.walletConnectSelected(in: self)
    }
}

extension TokensViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sections[indexPath.section] {
        case .search, .testnetTokens/*, .walletSummary*/, .filters, .activeWalletSession:
            return UITableViewCell()
        case .tokens:
            switch viewModel.item(for: indexPath.row, section: indexPath.section) {
            case .rpcServer(let server):
                let cell: ServerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: TokenListServerTableViewCellViewModel(server: server, isTopSeparatorHidden: true))

                return cell
            case .tokenObject(let token):
                let server = token.server
                let session = sessions[server]

                switch token.type {
                case .nativeCryptocurrency:
                    let cell: EthTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.configure(viewModel: .init(
                        token: token,
                        ticker: session.tokenBalanceService.coinTicker(token.addressAndRPCServer),
                        currencyAmount: session.tokenBalanceService.ethBalanceViewModel?.currencyAmountWithoutSymbol,
                        assetDefinitionStore: assetDefinitionStore
                    ))

                    return cell
                case .erc20:
                    let cell: FungibleTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.configure(viewModel: .init(token: token,
                        assetDefinitionStore: assetDefinitionStore,
                        isVisible: isVisible,
                        ticker: session.tokenBalanceService.coinTicker(token.addressAndRPCServer)
                    ))
                    return cell
                case .erc721, .erc721ForTickets, .erc1155:
                    let cell: NonFungibleTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.configure(viewModel: .init(token: token, server: server, assetDefinitionStore: assetDefinitionStore))
                    return cell
                case .erc875:
                    let cell: NonFungibleTokenViewCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.configure(viewModel: .init(token: token, server: server, assetDefinitionStore: assetDefinitionStore))
                    return cell
                }
            }
        case .collectiblePairs:
            let pair = viewModel.collectiblePairs[indexPath.row]

            let cell: OpenSeaNonFungibleTokenPairTableCell = tableView.dequeueReusableCell(for: indexPath)
            cell.delegate = self

            let left: OpenSeaNonFungibleTokenViewCellViewModel = .init(token: pair.left)
            let right: OpenSeaNonFungibleTokenViewCellViewModel? = pair.right.flatMap { token in
                return OpenSeaNonFungibleTokenViewCellViewModel(token: token)
            }

            cell.configure(viewModel: .init(leftViewModel: left, rightViewModel: right))

            return cell
            
        case .transactions:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight(for: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        guard let cell = cell as? OpenSeaNonFungibleTokenPairTableCell else { return }

        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = viewModel.numberOfItems(for: section)
        let mode = viewModel.sections[section]
        if mode == .tokens || mode == .collectiblePairs || mode == .transactions{
            handleTokensCountChange(rows: rowCount)
        }
        return rowCount
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch viewModel.sections[indexPath.section] {
        case .collectiblePairs, .testnetTokens, .search/*, .walletSummary*/, .filters, .activeWalletSession:
            return nil
        case .tokens:
            return trailingSwipeActionsConfiguration(forRowAt: indexPath)
        case .transactions:
            return nil
        }
    }

    private func trailingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = viewModel.item(for: indexPath.row, section: indexPath.section)
        guard item.canDelete else { return nil }
        switch item {
        case .rpcServer:
            return nil
        case .tokenObject(let token):
            let title = R.string.localizable.walletsHideTokenTitle()
            let hideAction = UIContextualAction(style: .destructive, title: title) { [weak self] (_, _, completion) in
                guard let strongSelf = self else { return }

                let deletedIndexPathArray = strongSelf.viewModel.indexPathArrayForDeletingAt(indexPath: indexPath)
                strongSelf.delegate?.didHide(token: token, in: strongSelf)

                let didHideToken = strongSelf.viewModel.markTokenHidden(token: token)
                if didHideToken {
                    strongSelf.tableView.deleteRows(at: deletedIndexPathArray, with: .automatic)
                } else {
                    strongSelf.reloadTableData()
                }

                completion(didHideToken)
            }

            hideAction.backgroundColor = R.color.danger()
            hideAction.image = R.image.hideToken()
            let configuration = UISwipeActionsConfiguration(actions: [hideAction])
            configuration.performsFirstActionWithFullSwipe = true

            return configuration
        }
    }

    private func handleTokensCountChange(rows: Int) {
        let isEmpty = rows == 0
        let title: String
        switch viewModel.filter {
        case .assets:
            title = R.string.localizable.emptyTableViewWalletTitle(R.string.localizable.aWalletContentsFilterAssetsOnlyTitle())
        case .transactions:
            title = "No transactions yet. \nSend and receive payments to get started"
        case .collectiblesOnly:
            title = R.string.localizable.emptyTableViewWalletTitle(R.string.localizable.aWalletContentsFilterCollectiblesOnlyTitle())
        case .defi:
            title = R.string.localizable.emptyTableViewWalletTitle(R.string.localizable.aWalletContentsFilterDefiTitle())
        case .governance:
            title = R.string.localizable.emptyTableViewWalletTitle(R.string.localizable.aWalletContentsFilterGovernanceTitle())
        case .keyword:
            title = R.string.localizable.emptyTableViewSearchTitle()
        case .all:
            title = R.string.localizable.emptyTableViewWalletTitle(R.string.localizable.emptyTableViewAllTitle())
        default:
            title = ""
        }
        if isEmpty {
            if let height = tableHeight() {
                emptyTableViewHeightConstraint?.constant = height/2.0
            } else {
                emptyTableViewHeightConstraint?.constant = 0
            }
            emptyTableView.title = title
        }
        emptyTableView.isHidden = !isEmpty
    }

    private func tableHeight() -> CGFloat? {
        guard let delegate = tableView.delegate else { return nil }
        let sectionCount = viewModel.sections.count
        var height: CGFloat = 0
        for sectionIndex in 0..<sectionCount {
            let rows = viewModel.numberOfItems(for: sectionIndex)
            for rowIndex in 0..<rows {
                height += (delegate.tableView?(tableView, heightForRowAt: IndexPath(row: rowIndex, section: sectionIndex))) ?? 0
            }
            height += (delegate.tableView?(tableView, heightForHeaderInSection: sectionIndex)) ?? 0
            height += (delegate.tableView?(tableView, heightForFooterInSection: sectionIndex)) ?? 0
        }
        return height
    }
}

extension TokensViewController: AddHideTokensViewDelegate {

    func view(_ view: AddHideTokensView, didSelectAddHideTokensButton sender: UIButton) {
        delegate?.whereAreMyTokensSelected(in: self)
    }
}

extension TokensViewController {
    @objc func didTapSegment(_ control: ScrollableSegmentedControl) {
        guard let filter = viewModel.convertSegmentedControlSelectionToFilter(control.selectedSegment) else { return }
        apply(filter: filter, withSegmentAtSelection: control.selectedSegment)
    }

    private func apply(filter: WalletFilter, withSegmentAtSelection selection: ControlSelection?) {
        let previousFilter = viewModel.filter
        viewModel.filter = filter
        reload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //Important to update the segmented control (and hence add the segmented control back to the table) after they have been re-added to the table header through the table reload. Otherwise adding to the table header will break the animation for segmented control
            if let selection = selection, case let ControlSelection.selected(index) = selection {
                //self.tableViewFilterView.setSelection(cellIndex: Int(index))
                self.segmentedControl.selectedSegmentIndex = Int(index)
                if filter == .assets {
                    self.searchBar.buttonIsHidden(isHidden: false)
                }
            }
        }
        //Exit search if user tapped on the wallet filter. Careful to not trigger an infinite recursion between changing the filter by "category" and search keywords which are all based on filters
        if previousFilter == filter {
            //do nothing
        } else {
            switch filter {
            case .all, .defi, .governance, .assets, .transactions, .collectiblesOnly, .type:
                searchController.isActive = false
            case .keyword:
                break
            }
        }
    }
}

extension TokensViewController: UISearchControllerDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        guard viewModel.isSearchActive else { return }

        navigationItem.searchController = nil

        viewModel.isSearchActive = false
        viewModel.filter = viewModel.filter

        tableView.reloadData()
    }
}

extension TokensViewController: UISearchResultsUpdating {
    //At least on iOS 13 beta on a device. updateSearchResults(for:) is called when we set `searchController.isActive = false` to dismiss search (because user tapped on a filter), but the value of `searchController.isActive` remains `false` during the call, hence the async.
    //This behavior is not observed in iOS 12, simulator
    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async {
            self.processSearchWithKeywords()
        }
    }

    private func processSearchWithKeywords() {
        guard searchController.isActive else {
            switch viewModel.filter {
            case .all, .defi, .governance, .assets, .transactions, .collectiblesOnly, .type:
                break
            case .keyword:
                //Handle when user taps Cancel button to stop search
                setDefaultFilter()
            }
            return
        }
        let keyword = searchController.searchBar.text ?? ""
        updateResults(withKeyword: keyword)
    }

    private func updateResults(withKeyword keyword: String) {
        tableViewFilterView.unselect()
        apply(filter: .keyword(keyword), withSegmentAtSelection: nil)
    }

    private func setDefaultFilter() {
        apply(filter: .assets, withSegmentAtSelection: .selected(0))
    }
}

fileprivate class CustomSegmentedControl : UIView, ReusableTableHeaderViewType {
    
    init(subview: UIView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14),
            subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14),
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class DummySearchView: UIView {

    private let searchBar: UISearchBar = {
        let searchBar: UISearchBar = UISearchBar(frame: .init(x: 0, y: 0, width: 100, height: 50))
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.isUserInteractionEnabled = false
        UISearchBar.configure(searchBar: searchBar, backgroundColor: Colors.walletTableBackground)

        return searchBar
    }()

    private var overlayView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    private var button: UIButton?

    init(closure: @escaping () -> Void, button : UIButton) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        self.button = button
        
        let stackView = [
            searchBar,
            self.button!
        ].asStackView(axis: .horizontal, /*spacing: 5,*/ alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        addSubview(overlayView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            //stackView.anchorsConstraint(to: self),
            overlayView.anchorsConstraint(to: searchBar)])
        
        UITapGestureRecognizer(addToView: overlayView, closure: closure)
    }
    
    func buttonIsHidden(isHidden: Bool) {
        self.button?.isHidden = isHidden
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TokensViewController: OpenSeaNonFungibleTokenPairTableCellDelegate {

    private func didSelectToken(indexPath: IndexPath) {
        let selection = viewModel.item(for: indexPath.row, section: indexPath.section)

        switch (viewModel.sections[indexPath.section], selection) {
        case (.tokens, .tokenObject(let token)):
            delegate?.didSelect(token: token, in: self)
        case (_, _):
            break
        }
    }

    func didSelect(cell: OpenSeaNonFungibleTokenPairTableCell, indexPath: IndexPath, isLeftCardSelected: Bool) {
        switch viewModel.sections[indexPath.section] {
        case .collectiblePairs:
            let pair = viewModel.collectiblePairs[indexPath.row]
            guard let token: TokenObject = isLeftCardSelected ? pair.left : pair.right else { return }
            delegate?.didSelect(token: token, in: self)
        case .tokens, .transactions, .testnetTokens, .activeWalletSession, .filters, .search/*, .walletSummary*/:
            break
        }
    }
}

///Support searching/filtering tokens with keywords. This extension is set up so it's easier to copy and paste this functionality elsewhere
extension TokensViewController {
    private func makeSwitchToAnotherTabWorkWhileFiltering() {
        definesPresentationContext = true
    }

    private func wireUpSearchController() {
        searchController.searchResultsUpdater = self
    }

    private func fixNavigationBarAndStatusBarBackgroundColorForiOS13Dot1() {
        view.superview?.backgroundColor = viewModel.backgroundColor
    }

    private func setupFilteringWithKeyword() {
        navigationItem.hidesSearchBarWhenScrolling = false
        wireUpSearchController()
        TokensViewController.functional.fixTableViewBackgroundColor(tableView: tableView, backgroundColor: viewModel.walletTableBackground)
        doNotDimTableViewToReuseTableForFilteringResult()
        makeSwitchToAnotherTabWorkWhileFiltering()
    }

    private func doNotDimTableViewToReuseTableForFilteringResult() {
        searchController.obscuresBackgroundDuringPresentation = false
    }

    //Makes a difference where this is called from. Can't be too early
    private func configureSearchBarOnce() {
        guard !isSearchBarConfigured else { return }
        isSearchBarConfigured = true
        UISearchBar.configure(searchBar: searchController.searchBar, backgroundColor: Colors.walletTableBackground)
    }
}

// MARK: Search
extension TokensViewController {
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: "f", modifierFlags: .command, action: #selector(enterSearchMode))]
    }
}

extension TokensViewController {
    class functional {}
}

extension TokensViewController.functional {
    static func fixTableViewBackgroundColor(tableView: UITableView, backgroundColor: UIColor) {
        let v = UIView()
        v.backgroundColor = backgroundColor
        tableView.backgroundView?.backgroundColor = backgroundColor
        tableView.backgroundView = v
    }
}

extension UISearchBar {
    static func configure(searchBar: UISearchBar, backgroundColor: UIColor = Colors.appBackground) {
        if let placeholderLabel = searchBar.firstSubview(ofType: UILabel.self) {
            placeholderLabel.textColor = Colors.lightGray
        }
        if let textField = searchBar.firstSubview(ofType: UITextField.self) {
            textField.textColor = Colors.appText
            if let imageView = textField.leftView as? UIImageView {
                imageView.image = R.image.search_bar_icon()!.withRenderingMode(.alwaysOriginal)
                //imageView.tintColor = Colors.appText
            }
        }
        //Hack to hide the horizontal separator below the search bar
        searchBar.superview?.firstSubview(ofType: UIImageView.self)?.isHidden = true
        //Remove border line
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.clear.cgColor
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = R.string.localizable.tokensSearchbarPlaceholder()
        searchBar.backgroundColor = backgroundColor
        searchBar.textField?.textAlignment = .center
        searchBar.textField?.layer.cornerRadius = 6
        searchBar.textField?.layer.masksToBounds = true
        searchBar.textField?.cornerRadius = 6
        searchBar.cornerRadius = 6
        searchBar.layer.cornerRadius = 6
        searchBar.clipsToBounds = true
        searchBar.setImage(R.image.search_bar_icon()!.withRenderingMode(.alwaysOriginal), for: .search, state: .normal)
        
        
        //let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField

//        //get the sizes
//        guard let searchBarWidth = searchBar.textField?.frame.width else {return}
//        let placeholderIconWidth = textFieldInsideSearchBar?.leftView?.frame.width
//        let placeHolderWidth = textFieldInsideSearchBar?.attributedPlaceholder?.size().width
//        let offsetIconToPlaceholder: CGFloat = 8
//        let placeHolderWithIcon = placeholderIconWidth! + offsetIconToPlaceholder
//        let offset = UIOffset(horizontal: ((searchBarWidth / 2) - (placeHolderWidth! / 2) - placeHolderWithIcon), vertical: 0)
//        self.setPositionAdjustment(offset, for: .search)
    }
}


extension TokensViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numberOfItems = 1

        
        return numberOfItems
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = viewModel.numberOfItems(for: section)
        pageControl.numberOfPages = numberOfItems
        
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let walletViewModel = viewModel.accountViewModel(forIndexPath: indexPath) else {return UITableViewCell()}
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AccountWalletCollectionViewCell
        let cellViewModel = AccountWalletCollectionViewCellViewModel(accountTitle: "Wallet \(indexPath.row)", walletAddress: walletViewModel.addressesAttrinutedString, amount: walletViewModel.)
        // Configure the cell
        
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: walletsCollectionView.contentOffset, size: walletsCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = walletsCollectionView.indexPathForItem(at: visiblePoint)
        pageControl.currentPage = visibleIndexPath!.row
    }

}

class SnappingCollectionViewLayout: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left

        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)

        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)

        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        })

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
