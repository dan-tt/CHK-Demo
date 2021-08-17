//
//  BaseCollectionVC.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import KafkaRefresh
import NSObject_Rx

class BaseCollectionVC: BaseVC, UIScrollViewDelegate {
    
    let defaultCellId = "CellId"
    let defaultHeaderCellId = "HeaderCellId"
    
    lazy var constraint_top_clv: NSLayoutConstraint = NSLayoutConstraint()
    lazy var constraint_bottom_clv: NSLayoutConstraint = NSLayoutConstraint()
    
    lazy var vHeaderRefresh: KafkaReplicatorHeader = {
        let v = KafkaReplicatorHeader()
        v.themeColor = UIColor.lightGray
        v.refreshHandler = { [weak self] in
            self?.refreshTrigger.onNext(())
        }
        return v
    }()
    
    lazy var vFooterRefresh: KafkaReplicatorFooter = {
        let v = KafkaReplicatorFooter()
        v.themeColor = UIColor.lightGray
        return v
    }()
    
    lazy var collectionView : UICollectionView = {
        let v = UICollectionView.init(frame: .zero, collectionViewLayout: layout())
        v.backgroundColor = .clear
        v.indicatorStyle = .black
        v.delegate = nil
        v.dataSource = nil
        v.rx.setDelegate(self).disposed(by: rx.disposeBag)
        if self.showEmptyDataSet() {
            v.emptyDataSetDelegate = self
            v.emptyDataSetSource = self
        }
        
        if self.showHeaderRefresh(){
            v.headRefreshControl = vHeaderRefresh
        }
        
        if self.showFooterLoadMore(){
            v.footRefreshControl = vFooterRefresh
            v.footRefreshControl.autoRefreshOnFoot = true
        }
        
        v.reloadEmptyDataSet()
        
        if #available(iOS 11.0, *) {
            v.contentInsetAdjustmentBehavior = .automatic
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showEmptyDataSet() -> Bool{
        return true
    }
    
    func showHeaderRefresh() -> Bool{
        return true
    }
    
    func showFooterLoadMore() -> Bool{
        return true
    }
    
    override func makeUI() {
        super.makeUI()
        self.view.addSubview(self.collectionView)
        registerCell()
        self.viewData = self.collectionView
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        if self.showHeaderRefresh() {
            self.viewModel?.headerLoading.asObservable().bind(to: collectionView.headRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)
        }
        if self.showFooterLoadMore() {
            self.viewModel?.footerLoading.asObservable().bind(to: collectionView.footRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)
            self.viewModel?.canLoadMoreSignal
                .distinctUntilChanged()
                .subscribe(onNext: { [unowned self] (canLoadMore) in
                    if canLoadMore {
                        self.collectionView.footRefreshControl.isHidden = false
                        self.collectionView.footRefreshControl.resumeRefreshAvailable()
                    } else {
                        self.collectionView.footRefreshControl.endRefreshingAndNoLongerRefreshing(withAlertText: "")
                        self.collectionView.footRefreshControl.isHidden = true
                    }
                }).disposed(by: rx.disposeBag)
        }
        
        self.viewModel?.errorSignal.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.showFooterLoadMore() {
                self.collectionView.footRefreshControl.isHidden = true
            }
        }).disposed(by: rx.disposeBag)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        let topClv: CGFloat = hideNavigation() ? 0 : ScreenSize.NAVIGATION_HEIGHT_FULL
        constraint_top_clv = self.collectionView.autoPinEdge(toSuperviewEdge: .top, withInset: topClv)
        self.collectionView.autoPinEdge(toSuperviewEdge: .leading)
        self.collectionView.autoPinEdge(toSuperviewEdge: .trailing)
        constraint_bottom_clv = self.collectionView.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    func layout() -> UICollectionViewFlowLayout {
        return UICollectionViewFlowLayout()
    }
    
    func registerCell() {}
    
    func configsDelegate(vc: BaseCollectionVC?, disposeBag: DisposeBag?) {
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        self.collectionView.rx.setDelegate(vc ?? self).disposed(by: disposeBag ?? rx.disposeBag)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel?.sizeForItemAt(indexPath: indexPath) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - load more
extension BaseCollectionVC {
    func loadMoreAt(indexPath: IndexPath) {
        let lastSection = self.collectionView.numberOfSections - 1
        let lastItem = self.collectionView.numberOfItems(inSection: lastSection) - 2
        let canLoadMore = self.viewModel?.canLoadMoreSignal.value ?? false
        let isLoading = self.viewModel?.loadingSignal.value ?? false
        if indexPath.section == lastSection,
           indexPath.item == lastItem,
           canLoadMore,
           !isLoading {
            self.loadMoreTrigger.onNext(())
        }
    }
}
