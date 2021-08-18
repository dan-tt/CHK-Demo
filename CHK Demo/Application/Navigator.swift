//
//  Navigator.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit

protocol Navigatable {
    var navigator: Navigator! { get set }
}
struct Navigator {
    static var `default` = Navigator()
    
    enum Transition {
        case root(in: UIWindow)
        case navigation
        case customModal
        case modal
        case fullscreenModal
        case detail
        case alert
        case custom
    }
    
    enum Scene {
        case coinDetail(viewModel: CoinDetailVM)
    }
    
    func get(segue: Scene) -> UIViewController? {
        switch segue {
        case .coinDetail(let viewModel):
            return CoinDetailVC(viewModel: viewModel, navigator: self)
        }
    }
    
    func pop(sender: UIViewController?, toRoot: Bool = false){
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        }else{
            sender?.navigationController?.popViewController(animated: true)
        }
    }
    
    func dismiss(sender: UIViewController?){
        if sender?.navigationController != nil {
            sender?.navigationController?.dismiss(animated: true, completion: {
                if #available(iOS 13.0, *), sender?.modalPresentationStyle == .pageSheet {
                    if let vc = Application.shared.topViewController() as? BaseVC {
                        vc.viewWillAppear(true)
                    }
                }
            })
            return
        }
        sender?.dismiss(animated: true, completion: {
            if #available(iOS 13.0, *), sender?.modalPresentationStyle == .pageSheet {
                if let vc = Application.shared.topViewController() as? BaseVC {
                    vc.viewWillAppear(true)
                }
            }
        })
    }
    
    func show(segue:Scene, sender: UIViewController?, transition: Transition = .navigation) {
        if let target = get(segue: segue) {
            show(target: target, sender: sender, transition: transition)
        }
    }
    
    func show(target: UIViewController, sender: UIViewController?, transition: Transition){
        switch transition {
        case .root(in: let window):
            // remove current rootVC
            if let curRoot = window.rootViewController {
                curRoot.dismiss(animated: false, completion: {
                    curRoot.view.removeFromSuperview()
                })
            }
            // replace new rootVC
            window.rootViewController = target
            
            return
        case .custom:
            return
            
        default:
            break
        }
        
        guard let sender = sender else{
            //push view controller to root if sender is nil
            if let rootNav = Application.shared.window?.rootViewController as? NavigationController {
                rootNav.pushViewController(target, animated: true)
            }
            return
        }
        
        if let nav = sender as? UINavigationController {
            nav.pushViewController(target, animated: false)
            return
        }
        
        switch transition {
        case .navigation:
            if let nav = sender.navigationController {
                nav.pushViewController(target, animated: true)
            }
        case .customModal:
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.present(nav, animated: true, completion: nil)
            }
        case .modal:
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.present(nav, animated: true, completion: nil)
            }
        case .fullscreenModal:
            DispatchQueue.main.async {
                if #available(iOS 13, *) {
                    target.modalPresentationStyle = .fullScreen
                }
                sender.present(target, animated: true, completion: nil)
            }
        case .detail:
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.showDetailViewController(nav, sender: nil)
            }
        case .alert:
            DispatchQueue.main.async {
                sender.present(target, animated: true, completion: nil)
            }
        default:
            break
        }
    }
}
