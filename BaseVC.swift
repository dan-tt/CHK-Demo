//
//  BaseVC.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class BaseVC: UIViewController, Navigatable {
    var viewModel: BaseVM?
    var navigator: Navigator!
    var didUpdateContrains = false
    var bindedViewModel = false
    
    let refreshTrigger = PublishSubject<Void>()
    let loadMoreTrigger = PublishSubject<Void>()
    var disposeBag = DisposeBag()

    var showLoading: Bool = true
    var showNoNetwork: Bool = false
    var showNoData: Bool = false
    
    var isShowShimmer: Bool = false
    
    var needRefreshData: Bool = false
    
    var emptyDataConfig: EmptyDataConfig?
    var emptyDataType : EmptyDataType {
        return .Base
    }
    
    var viewData:UIScrollView?
    
    var isPresent : Bool {
        return false
    }
    

    // MARK: - Init
    
    init(viewModel: BaseVM?, navigator: Navigator) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyDataConfig = EmptyDataConfig(controller: self)
        makeUI()
        self.view.setNeedsUpdateConstraints()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Application.shared.mainNav == nil  {
            return
        }
        if needRefreshData {
            self.refreshTrigger.onNext(())
            self.needRefreshData = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared.clearMemory()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    var statusBarHidden : Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        }
        
        return .default
    }
    
    var applyUserChanged: Bool {
        return true
    }
    
    //MARK: - Init
    
    func makeUI() {

    }
    
    override func updateViewConstraints() {
        if !self.didUpdateContrains {
            self.updateConstraints()
            self.didUpdateContrains = true
        }
        super.updateViewConstraints()
    }
    
    func updateConstraints() {

    }
    
    func bindViewModel() {
        self.viewModel?.loadingSignal.subscribe(onNext: { [weak self] (isLoading) in
            guard let self = self else { return }
            if isLoading{
                self.showNoData = false
                self.showNoNetwork = false
            }
            self.showLoading = isLoading
            self.viewData?.reloadEmptyDataSet()
        }).disposed(by: disposeBag)
        
        self.viewModel?.errorSignal.subscribe(onNext: { [weak self] (error) in
            guard let self = self else { return }
            let errorCode = error.errorCode
            if (errorCode == 224) {
                self.showNoData = true
            }else{
                self.showNoNetwork = true
            }
            self.viewData?.reloadEmptyDataSet()
        }).disposed(by: disposeBag)
        
        self.viewModel?.dismissSignal.subscribe(onNext: { [weak self] _ in
            self?.dismiss()
        }).disposed(by: disposeBag)
    }
    
    func dismiss() {
        if self.isPresent {
            dissmissAllPresentationController()
            return
        }
        
        self.navigator.pop(sender: self)
    }

    func dissmissAllPresentationController() {
        if let vc = self.presentedViewController {
            vc.dismiss(animated: true) {
                self.dissmissAllPresentationController()
            }
            
            return
        }
        self.navigator.dismiss(sender: self)
    }
    
    // MARK: - NagivationBar
    
    func hideNavigation() -> Bool {
        return true
    }
    
    func emptyDataSetDidTapButton() {
        self.refreshTrigger.onNext(())
    }
    
    // MARK: - Deinit
    deinit {
        Logger.log(message: "\(Self.self) - Deinit")
        NotificationCenter.default.removeObserver(self)
        disposeBag = DisposeBag()
    }
}


// MARK: - EmptyDataSetDelegate

extension BaseVC : EmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
                
        if (self.showLoading && !isShowShimmer) || self.showNoData || self.showNoNetwork {
            return true
        }
        
        return false
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        if (self.showLoading && !isShowShimmer) {
            return false
        }
        return true
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView) -> Bool {
        return (self.showLoading && !isShowShimmer)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView) {
        NSLog("emptyDataSet did tap view")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        NSLog("emptyDataSet did tap button")
        self.emptyDataSetDidTapButton()
    }
}

// MARK: - EmptyDataSetSource

extension BaseVC: EmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return emptyDataConfig?.titleString
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return emptyDataConfig?.detailString
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return emptyDataConfig?.image
    }
    
    func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? {
        return emptyDataConfig?.imageAnimation
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return emptyDataConfig?.buttonTitle(state)
    }
    
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        return emptyDataConfig?.buttonBackgroundImage(state)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return emptyDataConfig?.backgroundColor
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return emptyDataConfig?.verticalOffset ?? 0
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return emptyDataConfig?.spaceHeight ?? 0
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return emptyDataConfig?.customView
    }
}
