// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit
import UserNotifications

final class PushNotificationsService: NSObject {
    private var notificationCenter: UNUserNotificationCenter {
        return .current()
    }

    private var presentationViewController: UIViewController? {
        guard let keyWindow = UIApplication.shared.firstKeyWindow else { return nil }

        if let controller = keyWindow.rootViewController?.presentedViewController {
            return controller
        } else {
            return nil
        }
    }

    func registerForReceivingRemoteNotifications() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        notificationCenter.delegate = self
    }

    func requestToEnableNotification() {
        authorizationNotDetermined { [weak self] in
            self?.presentationViewController?.confirm(
                    //TODO We'll just say "Ether" in the prompt. Note that this is not the push notification itself. We could refer to it as "native cryptocurrency", but that's vague. Could be xDai!
                    title: R.string.localizable.transactionsReceivedEtherNotificationPrompt(RPCServer.main.cryptoCurrencyName),
                    message: nil,
                    okTitle: R.string.localizable.oK(),
                    okStyle: .default
            ) { result in
                switch result {
                case .success:
                    //Give some time for the view controller to show up first. We don't have to be precise, so no need to complicate things with hooking up to the view controller's animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.requestForAuthorization()
                    }
                case .failure:
                    break
                }
            }
        }
    }

    private func authorizationNotDetermined(handler: @escaping () -> Void) {
        notificationCenter.getNotificationSettings { settings in
            if case .notDetermined = settings.authorizationStatus {
                DispatchQueue.main.async {
                    handler()
                }
            }
        }
    }

    //TODO call this after send Ether too?
    private func requestForAuthorization() {
        notificationCenter.requestAuthorization(options: [.badge, .alert, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                //Do stuff if unsuccessful…
            }
        }
    }
}

extension PushNotificationsService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
