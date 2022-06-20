//
//  CustomPageContol.swift
//  PageControl
//
//  Created by Quach Ngoc Tam on 5/11/18.
//  Copyright © 2018 mr.tamqn. All rights reserved.
//

import UIKit
import PureLayout
import SMPageControl

struct CurrentColor {
    static var selected = #colorLiteral(red: 0.2310000062, green: 0.2469999939, blue: 0.7609999776, alpha: 1)
    static var unSelect = UIColor.white
    static var detailUnselected = #colorLiteral(red: 0.2899999917, green: 0.2899999917, blue: 0.2899999917, alpha: 0.3000000119)
}

protocol CustomPageControlDelegate {
    func currentIndex(indexPath:IndexPath)
}

class CustomPageContol: UIView {
    var delegate:CustomPageControlDelegate?
    
    var collectionView:UICollectionView?
    var pageControl:SMPageControl?
    
    var isLeagueDetail: Bool {
        get {
            return isDetail
        }
        set {
            isDetail = newValue
            self.pageControl!.pageIndicatorImage = newValue ? VFantasyCommon.image(named: "ic_tab_detail_inactive") : VFantasyCommon.image(named: "ic_unSelect_pagecontrol")
        }
    }
    fileprivate var isDetail = false
    
    var data = [String]()
    var font:UIFont?
    
    var indexPath:IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoLayoutCollectionView()
        autoLayoutPageControl()
    }
    
    func commonInit() {
        initCollectionView()
        initPageControl()
    }
    
    //MARK:- CollectionView
    func initCollectionView() {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowlayout)
        self.collectionView?.backgroundColor = UIColor.clear
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.register(UINib(nibName: "CustomCollectionViewCell", bundle: Bundle.sdkBundler()), forCellWithReuseIdentifier: "CustomCollectionViewCell")
        self.addSubview(self.collectionView!)
    }
    
    func autoLayoutCollectionView() {
        self.collectionView?.autoPinEdge(toSuperviewEdge: .top, withInset: 1)
        self.collectionView?.autoPinEdge(toSuperviewEdge: .left, withInset: 1)
        self.collectionView?.autoPinEdge(toSuperviewEdge: .right, withInset: 1)
    }
    
    func loadData(data: [String], indexPath: IndexPath?, font: UIFont) {
        self.data = data
        self.font = font
        self.indexPath = indexPath
        
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        
        self.collectionView!.reloadData()
        
        setPageControl(numberOfPages: self.data.count, currentPage: 0)
        if indexPath != nil {
            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        }
    }
    
    func reloadData(data: [String], currentPage: Int = 0) {
        self.data = data
        setPageControl(numberOfPages: self.data.count, currentPage: currentPage)
        self.collectionView?.reloadData()
        self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
    }
    
    func reloadData(at index: Int) {
        guard let maxIndex = collectionView?.numberOfItems(inSection: 0) else { return }
        if index >= maxIndex { return }
        
        self.indexPath = IndexPath(row: index, section: 0)
        setCurrentPageControl(currentPage: index)
        if index == 0 {
            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        } else if index == maxIndex - 1 {
            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .right)
        } else {
            self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
        self.collectionView?.reloadData()
    }
    
    //MARK:- PageControl
    func initPageControl() {
        self.pageControl = SMPageControl.init(frame: CGRect.zero)
        self.pageControl!.pageIndicatorImage = VFantasyCommon.image(named: "ic_unSelect_pagecontrol")
        self.pageControl!.currentPageIndicatorImage = VFantasyCommon.image(named: "ic_selected_pagecontrol")
        
        self.pageControl!.addTarget(self, action: #selector(pageControl(sender:)), for: .valueChanged)
        self.addSubview(self.pageControl!)
    }
    
    func autoLayoutPageControl() {
        self.pageControl?.autoPinEdge(.top, to: .bottom, of: self.collectionView!)
        self.pageControl?.autoPinEdge(toSuperviewEdge: .left, withInset: 1)
        self.pageControl?.autoPinEdge(toSuperviewEdge: .right, withInset: 1)
        self.pageControl?.autoPinEdge(toSuperviewEdge: .bottom, withInset: 1)
        self.pageControl?.autoSetDimension(.height, toSize: 20)
    }
    
    func setPageControl(numberOfPages:Int, currentPage:Int) {
        setNumberPageControl(numberOfPage: numberOfPages)
        setCurrentPageControl(currentPage: currentPage)
    }
    
    func setCurrentPageControl(currentPage:Int) {
        self.pageControl?.currentPage = currentPage
    }
    
    func setNumberPageControl(numberOfPage:Int)  {
        self.pageControl?.numberOfPages = numberOfPage
    }
    
    @objc func pageControl(sender:SMPageControl) {
        print(sender.currentPage)
        for i in 0...sender.numberOfPages - 1 {
            let indexPath = IndexPath(row: i, section: 0)
            if i == sender.currentPage {
                handleItemSelected(indexPath)
            } else {
                handleItemDeselected(indexPath)
            }
        }
    }
    
    //MARK:- delegate
    func currentIndexPath(indexPath:IndexPath) {
        self.indexPath = indexPath
        // set current page control
        self.setCurrentPageControl(currentPage: indexPath.row)
        
        // callback to root current indexpath
        guard let delegate = delegate else {
            return
        }
        NotificationCenter.default.post(name: NotificationName.changeView, object: nil, userInfo: [NotificationKey.changeView : indexPath])
        delegate.currentIndex(indexPath: indexPath)
    }
    
    func handleItemSelected(_ indexPath: IndexPath) {
        guard let collectionView = collectionView else { return }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            cell.name.textColor = CurrentColor.selected
            self.currentIndexPath(indexPath: indexPath)
            
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func handleItemDeselected(_ indexPath: IndexPath) {
        guard let collectionView = collectionView else { return }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            cell.name.textColor = isDetail ? CurrentColor.detailUnselected : CurrentColor.unSelect
        }
    }
}

extension CustomPageContol: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        cell.name.text = data[indexPath.row]
        cell.name.font = font
        if self.indexPath != nil {
            if self.indexPath! == indexPath {
                cell.name.textColor = CurrentColor.selected
            }else{
                cell.name.textColor = isDetail ? CurrentColor.detailUnselected : CurrentColor.unSelect
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        handleItemSelected(indexPath)
        self.collectionView?.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        handleItemDeselected(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = data[indexPath.row]
        let width = text.width(withConstrainedHeight: (self.collectionView?.frame.size.height)!, font: font!)

        return CGSize.init(width: width + 18, height: (self.collectionView?.frame.size.height)!)
    }
}
