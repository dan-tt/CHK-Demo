//
//  NavigationController.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit

class NavigationController: UINavigationController {
        
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        }
        
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        self.setNavigationBarHidden(true, animated: false)
    }
    // MARK: - Deinit
    deinit {
        Logger.log(message: "\(Self.self) - Deinit")
    }
}
