//
//  MainVC.swift
//  CHK Demo
//
//  Created by Dan Tran Thanh  on 16/08/2021.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class MainVC: BaseCollectionVC {
    let searchTrigger = BehaviorRelay<String?>(value: nil)

    override func showFooterLoadMore() -> Bool {
        return false
    }
    
    override func hideNavigation() -> Bool {
        return false
    }
    
    lazy var headerView: UIView = {
        let v = UIView()
        v.addSubview(searchBar)
        //
        let padding : CGFloat =  16
        searchBar.autoPinEdge(toSuperviewEdge: .top, withInset: ScreenSize.STATUS_BAR_HEIGHT + padding/2)
        searchBar.autoPinEdge(toSuperviewEdge: .left, withInset: padding)
        searchBar.autoPinEdge(toSuperviewEdge: .right, withInset: padding)
        searchBar.autoSetDimension(.height, toSize: 32)
        return v
    }()
    
    lazy var searchBar: SearchBar = {
        let v = SearchBar.newAutoLayout()
        v.cancelButtonClicked
            .subscribe(onNext: { [unowned self] () in
                self.showSearch(false)
            }).disposed(by: disposeBag)
        v.textDidBeginEditing
            .subscribe(onNext: { [unowned self](tf) in
                self.searchTrigger.accept(tf.text)
                self.showSearch(true)
            }).disposed(by: disposeBag)
        
        v.textSignal
            .debounce(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self](str) in
                self.searchTrigger.accept(str)
            }).disposed(by: disposeBag)
        return v
    }()
    
    lazy var searchCV: UICollectionView = {
        let v = UICollectionView.init(frame: .zero, collectionViewLayout: layout())
        v.alpha = 0
        v.backgroundColor = .white
        v.keyboardDismissMode = .onDrag
        v.dataSource = nil
        v.delegate = self
        v.register(CoinCell.self, forCellWithReuseIdentifier: CoinCell.cellId)
        v.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 59 + ScreenSize.BOTTOM_PADDING, right: 0)
        v.rx.itemSelected.subscribe(onNext: { [unowned self] _ in
            self.searchBar.tfSeach.resignFirstResponder()
        }).disposed(by: disposeBag)
        return v
    }()
    
    override func makeUI() {
        super.makeUI()
        view.backgroundColor = .white
        //
        view.insertSubview(headerView, aboveSubview: collectionView)
        view.insertSubview(searchCV, aboveSubview: collectionView)
        //
        let h = ScreenSize.NAVIGATION_HEIGHT_FULL
        headerView.autoPinEdge(toSuperviewEdge: .top)
        headerView.autoPinEdge(toSuperviewEdge: .left)
        headerView.autoPinEdge(toSuperviewEdge: .right)
        headerView.autoSetDimension(.height, toSize: h)
        
        searchCV.autoPinEdge(.top, to: .bottom, of: view)
        searchCV.autoPinEdge(toSuperviewEdge: .left)
        searchCV.autoPinEdge(toSuperviewEdge: .right)
        searchCV.autoSetDimension(.height, toSize: ScreenSize.SCREEN_MAX_LENGTH - h)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        //
        guard let viewModel = viewModel as? MainVM else { return }
        let refresh = Observable.of(Observable.just(()), self.refreshTrigger).merge()
        let input = MainVM.Input(headerTrigger: refresh,
                                 selectionTrigger: collectionView.rx.modelSelected(CoinModel.self).asDriver(),
                                 searchTrigger: self.searchTrigger.asDriver())
        
        let output = viewModel.transform(input: input)
        output.items.asObservable()
            .map({[CoinSection(items: $0, headerTitle: "")]})
            .bind(to: collectionView.rx.items(dataSource: dataSource()))
            .disposed(by: disposeBag)
        // search result
        output.searchResult.asObservable()
            .map({[CoinSection(items: $0, headerTitle: "")]})
            .bind(to: searchCV.rx.items(dataSource: searchDataSource()))
            .disposed(by: disposeBag)
    }
    
    override func registerCell() {
        collectionView.register(CoinCell.self, forCellWithReuseIdentifier: CoinCell.cellId)
    }
    
    func dataSource() -> RxCollectionViewSectionedReloadDataSource<CoinSection> {
        let datasource = RxCollectionViewSectionedReloadDataSource<CoinSection>(
            configureCell: { (dataSource, tableView, indexPath, model) -> CollectionViewCell in
                let cell = tableView.dequeueReusableCell(withReuseIdentifier: CoinCell.cellId, for: indexPath) as! CoinCell
                cell.model = model
                return cell
            })
        return datasource
    }
    
    func searchDataSource() -> RxCollectionViewSectionedAnimatedDataSource<CoinSection> {
        let datasource = RxCollectionViewSectionedAnimatedDataSource<CoinSection>(
            configureCell: { (dataSource, tableView, indexPath, model) -> CollectionViewCell in
                let cell = tableView.dequeueReusableCell(withReuseIdentifier: CoinCell.cellId, for: indexPath) as! CoinCell
                cell.model = model
                return cell
            })
        datasource.animationConfiguration = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade)
        return datasource
    }
    
    // show search view
    func showSearch(_ isShow: Bool) {
        if isShow {
            searchBar.tfSeach.becomeFirstResponder()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: { [unowned self] in
                self.searchCV.alpha = 1.0
                self.searchCV.transform = CGAffineTransform(translationX: 0, y: -self.searchCV.frame.height)
                
            }) { (finished) in
            }
            return
        }
        searchBar.text = ""
        searchBar.tfSeach.resignFirstResponder()
        searchBar.showCancelButton(false, animated: true)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: { [unowned self] in
            self.searchCV.alpha = 0.0
            self.searchCV.transform = CGAffineTransform.identity
        }) { (finished) in
        }
    }
}

// MARK: -
// MARK: - CoinCell
class CoinCell: CollectionViewCell {
    static var cellHeight : CGFloat {
        return 80.0
    }
    lazy var vLine: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.lightGray
        return v
    }()
    
    lazy var imv : UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    lazy var vInfo: UIView = {
        let v = UIView()
        let views = [lbTitle, lbDesc, lbBuyPrice, lbSellPrice]
        views.forEach { subView in
            subView.backgroundColor = UIColor.clear
            v.addSubview(subView)
        }
        let space : CGFloat = 8
        //
        lbTitle.autoPinEdge(toSuperviewEdge: .top)
        lbTitle.autoPinEdge(toSuperviewEdge: .left)
        lbTitle.autoPinEdge(.right, to: .left, of: lbBuyPrice, withOffset: -space, relation: .lessThanOrEqual)
        //
        lbDesc.autoPinEdge(.top, to: .bottom, of: lbTitle, withOffset: space/2)
        lbDesc.autoPinEdge(.left, to: .left, of: lbTitle)
        lbTitle.autoPinEdge(.right, to: .left, of: lbSellPrice, withOffset: -space, relation: .lessThanOrEqual)
        //
        lbBuyPrice.autoPinEdge(toSuperviewEdge: .right)
        lbBuyPrice.autoAlignAxis(.horizontal, toSameAxisOf: lbTitle)
        
        lbSellPrice.autoPinEdge(toSuperviewEdge: .right)
        lbSellPrice.autoAlignAxis(.horizontal, toSameAxisOf: lbDesc)
        
        v.autoPinEdge(.bottom, to: .bottom, of: lbDesc)
        
        return v
    }()
    
    lazy var lbTitle : UILabel = {
        let v = UILabel()
        v.font = UIFont.titleFont()
        v.textColor = UIColor.titleColor()
        return v
    }()
    
    lazy var lbDesc: UILabel = {
        let v = UILabel()
        v.font = UIFont.descFont()
        v.textColor = UIColor.descColor()
        return v
    }()
    
    lazy var lbBuyPrice: UILabel = {
        let v = UILabel()
        v.font = UIFont.buyPriceFont()
        v.textColor = UIColor.buyPriceColor()
        return v
    }()
    
    lazy var lbSellPrice: UILabel = {
        let v = UILabel()
        v.font = UIFont.sellPriceFont()
        v.textColor = UIColor.sellPriceColor()
        return v
    }()
    
    var model : CoinModel? {
        didSet {
            guard let model = model else {
                return
            }
            lbTitle.text = model.name
            lbDesc.text = model.base
            lbBuyPrice.text = "\(model.buyPrice ?? "0.0") \(model.counter ?? "")"
            lbSellPrice.text = "\(model.sellPrice ?? "0.0") \(model.counter ?? "")"
            let defaultImage = UIImage.iconFont(IconFont.ic_coin_default, fontSize: FontSize.h0, color: UIColor.lightGray)
            imv.setImage(with: URL(string: model.icon ?? ""), defaultImage: defaultImage)
        }
    }
    
    override func makeUI() {
        super.makeUI()
        imv.backgroundColor = UIColor.clear
        vInfo.backgroundColor = UIColor.clear
        contentView.addSubview(imv)
        contentView.addSubview(vInfo)
        contentView.addSubview(vLine)
        //
        let space : CGFloat = 16
        imv.autoPinEdge(toSuperviewEdge: .left, withInset: space)
        imv.autoAlignAxis(toSuperviewAxis: .horizontal)
        imv.autoSetDimensions(to: CGSize(width: 40, height: 40))
        
        vInfo.autoPinEdge(.left, to: .right, of: imv, withOffset: space)
        vInfo.autoAlignAxis(toSuperviewAxis: .horizontal)
        vInfo.autoPinEdge(toSuperviewEdge: .right, withInset: space)
        
        vLine.autoPinEdge(toSuperviewEdge: .left, withInset: space)
        vLine.autoPinEdge(toSuperviewEdge: .bottom)
        vLine.autoPinEdge(toSuperviewEdge: .right)
        vLine.autoSetDimension(.height, toSize: ScreenSize.BORDER_WIDTH)
    }
}
