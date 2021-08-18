//
//  NavigationController.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit

class NavigationController: UINavigationController {
        
    static let tagIgnoreRecognizeSimultaneous = 999

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
        setNavigationBarHidden(true, animated: false)
        //
        setupFullWidthBackGesture()
    }
    
    private lazy var fullWidthBackGestureRecognizer = UIPanGestureRecognizer()

    private func setupFullWidthBackGesture() {
        guard
            let interactivePopGestureRecognizer = interactivePopGestureRecognizer,
            let targets = interactivePopGestureRecognizer.value(forKey: "targets")
        else {
            return
        }

        fullWidthBackGestureRecognizer.setValue(targets, forKey: "targets")
        fullWidthBackGestureRecognizer.delegate = self
        view.addGestureRecognizer(fullWidthBackGestureRecognizer)
    }
    
    // MARK: - Deinit
    deinit {
        Logger.log(message: "\(Self.self) - Deinit")
    }
}



// MARK: - UIGestureRecognizerDelegate

extension NavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isSystemSwipeToBackEnabled = interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = viewControllers.count > 1
        var isSwipeRight: Bool = false
        if let sender = gestureRecognizer as? UIPanGestureRecognizer {
            let distance: CGPoint = sender.translation(in: view)
            if (sender.state == .ended || sender.state == .possible) {
                if (distance.x > 0) {
                    isSwipeRight = true
                }
            }
        }

        return isSystemSwipeToBackEnabled && isThereStackedViewControllers && isSwipeRight
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
