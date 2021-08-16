//
//  BaseTableVC.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import KafkaRefresh
import PureLayout

class TableBaseVC: BaseVC, UIScrollViewDelegate {
    lazy var constraint_top_tbv: NSLayoutConstraint = NSLayoutConstraint()
    lazy var constraint_bottom_tbv: NSLayoutConstraint = NSLayoutConstraint()

    lazy var vHeaderRefresh: KafkaReplicatorHeader = {
        let v = KafkaReplicatorHeader()
        v.themeColor = UIColor.gray
        v.refreshHandler = { [unowned self] in
            self.refreshTrigger.onNext(())
        }
        return v
    }()
    
    lazy var vFooterRefresh: KafkaReplicatorFooter = {
        let v = KafkaReplicatorFooter()
        v.themeColor = UIColor.gray
        return v
    }()
    
    lazy var tableView: UITableView = {
        let v = UITableView.init(frame: .zero, style: tableStyle())
        v.rowHeight = UITableView.automaticDimension
        v.tableFooterView = UIView(frame: .zero)
        v.estimatedRowHeight = 50
        v.cellLayoutMarginsFollowReadableWidth = false
        v.keyboardDismissMode = .onDrag
        v.separatorColor = .clear
        v.backgroundColor = .clear
        if self.showEmptyDataSet() {
            v.emptyDataSetDelegate = self
            v.emptyDataSetSource = self
        }
        if rxDelegate(){
            v.delegate = nil
            v.dataSource = nil
            v.rx.setDelegate(self).disposed(by: disposeBag)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.layoutIfNeeded()
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
    
    func tableStyle() -> UITableView.Style{
        return .plain
    }
    
    func rxDelegate()-> Bool{
        return true
    }
    
    override func makeUI() {
        super.makeUI()
        self.view.addSubview(self.tableView)
        registerCell()
        didSelectedItemCell()
        self.viewData = self.tableView
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        if self.showHeaderRefresh() {
            self.viewModel?.headerLoading.asObservable().bind(to: self.tableView.headRefreshControl.rx.isAnimating).disposed(by: disposeBag)
        }
        if self.showFooterLoadMore() {
            self.viewModel?.footerLoading.asObservable().bind(to: self.tableView.footRefreshControl.rx.isAnimating).disposed(by: disposeBag)
            self.viewModel?.canLoadMoreSignal.subscribe(onNext: { [weak self] (canLoadMore) in
                if canLoadMore {
                    self?.tableView.footRefreshControl.isHidden = false
                    self?.tableView.footRefreshControl.resumeRefreshAvailable()
                } else {
                    self?.tableView.footRefreshControl.endRefreshingAndNoLongerRefreshing(withAlertText: "")
                    self?.tableView.footRefreshControl.isHidden = true
                }
            }).disposed(by: disposeBag)
        }
        
        self.viewModel?.errorSignal.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.showFooterLoadMore() {
                self.tableView.footRefreshControl.isHidden = true
            }
        }).disposed(by: disposeBag)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        let topClv: CGFloat = hideNavigation() ? 0 : ScreenSize.NAVIGATION_HEIGHT_FULL
        constraint_top_tbv = self.tableView.autoPinEdge(toSuperviewEdge: .top, withInset: topClv)
        self.tableView.autoPinEdge(toSuperviewEdge: .leading)
        self.tableView.autoPinEdge(toSuperviewEdge: .trailing)
        constraint_bottom_tbv = self.tableView.autoPinEdge(toSuperviewEdge: .bottom, withInset: (ScreenSize.TABBAR_HEIGHT + ScreenSize.BOTTOM_PADDING))
    }
    
    func registerCell() {}
    
    func didSelectedItemCell() {}
    
    func configsDelegate(vc: TableBaseVC?, disposeBag: DisposeBag?) {
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.rx.setDelegate(vc ?? self).disposed(by: disposeBag ?? self.disposeBag)
    }
}

extension TableBaseVC: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}

extension TableBaseVC {
    func loadMoreAt(indexPath: IndexPath) {
        let lastSection = self.tableView.numberOfSections - 1
        let lastItem = self.tableView.numberOfRows(inSection: lastSection) - 1
        let canLoadMore = self.viewModel?.canLoadMoreSignal.value ?? false
        let isLoading = self.viewModel?.loadingSignal.value ?? false
        if indexPath.section == lastSection,
           indexPath.row == lastItem,
           canLoadMore,
           !isLoading {
            self.loadMoreTrigger.onNext(())
        }
    }
}

