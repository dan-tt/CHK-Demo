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
    var api: API?

    var mainNav: NavigationController?
    
    private override init() {
        self.navigator = Navigator.default
        self.api = APIService()
        super.init()
    }
    
    func start(in window: UIWindow?) {
        guard let window = window else {
            return
        }
        window.makeKeyAndVisible()
        self.window = window
        let rootVC = NavigationController(rootViewController: MainVC(viewModel: MainVM(api: api), navigator: navigator))
        window.rootViewController = rootVC
        self.mainNav = window.rootViewController as? NavigationController
    }
}

// MARK: - APP LIFE CYCLE
extension Application {
    func didBecomeActive() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func didEnterBackground() {
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
