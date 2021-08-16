//
//  Application.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import Alamofire

class Application: NSObject {
    static let shared = Application()
    let navigator: Navigator
    
    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.portrait
    var mainNav: NavigationController?
    var numberOfOpenApp: Int = 0
    var isShowingPopup: Bool = false
    //status network
    let reachabilityManager = Alamofire.NetworkReachabilityManager()
    var isConnectToInternet: Bool {
        return reachabilityManager?.isReachable ?? false
    }
    //
    var backgroundTask : UIBackgroundTaskIdentifier?
    var backgroundCompletionHandlerList = [String: (() -> Void)?]()
    //deeplink
    var appActived = false
    
    private override init() {
        self.navigator = Navigator.default
        super.init()
    }
    
    func start(in window: UIWindow?) {
        guard let window = window else {
            return
        }
        window.makeKeyAndVisible()
        self.window = window
        let rootVC = NavigationController(rootViewController: MainVC(viewModel: MainVM(), navigator: navigator))
        window.rootViewController = rootVC
        self.mainNav = window.rootViewController as? NavigationController
    }
}

// MARK: - APP LIFE CYCLE
extension Application {
    func didBecomeActive() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.appActived = true
    }
    
    func didEnterBackground() {
        /*
         Implement the UIApplication begin background task.
         Invoke callTask() in didReceiveRemoteNotification.
         This as per documentation the application gives you a maximum of 180 seconds to perform tasks in background.
         So make sure that in receiving silent notification, the total time taken for download, parsing and saving doesn’t exceed 180 seconds.
         */
        let application = UIApplication.shared
        backgroundTask = application.beginBackgroundTask(expirationHandler: {[weak self] in
            if let bgTask = self?.backgroundTask {
                application.endBackgroundTask(bgTask)
                self?.backgroundTask = nil
            }
        })
    }
    
    func willEnterForeground() {

    }
    
    func willTerminate() {
    }
}

// MARK: - Setup
extension Application {
    // Get TopViewController
    func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller ?? UIViewController()
    }
}
