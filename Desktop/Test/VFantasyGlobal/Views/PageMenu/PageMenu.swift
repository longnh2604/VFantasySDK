//
//  PageMenu.swift
//  VTMan
//
//  Created by Quang Tran on 3/27/19.
//  Copyright © 2019 ppcLink. All rights reserved.
//

import UIKit

/**
 ** PageMenuDelegate
 */
@objc protocol PageMenuDelegate {
    func pageViewDidEndScroll(_ pageMenu: PageMenu, _ previousIndex: Int, _ pageIndex: Int, _ viewItem: UIView)
    @objc optional func pageViewBeginScroll(_ pageMenu: PageMenu, _ pageIndex: Int, _ viewItem: UIView)
    @objc optional func pageReloadData(_ pageMenu: PageMenu, _ pageIndex: Int, _ pages: [UIView])
}

/**
 ** PageMenuDatasource
 */
@objc protocol PageMenuDatasource {
    /* Numbers page render in view */
    func numbersPage(in pageMenu: PageMenu) -> Int
    
    /* Customs view to render one page */
    func pageMenu(_ pageMenu: PageMenu, viewForPageAt index: Int) -> UIView
    
    /* Height for header menu */
    func heightForSegmentMenu(_ pageMenu: PageMenu) -> CGFloat
    
    /* Customs view menu for header */
    func pageMenu(_ pageMenu: PageMenu, viewForSegmentAt index: Int) -> UIView
    
    /* Customs segment for header menu */
    @objc optional func viewForMenuHeader(_ pageMenu: PageMenu) -> UIView?
    
    /* Tag label has change color selected/normal */
    func tagsLabelForUpdateSegment(_ pageMenu: PageMenu) -> [Int]
    
    /* Title normal label has change unselecte */
    func titleNormalColors(_ pageMenu: PageMenu) -> [UIColor]
    
    /* Title selected label has change selected */
    func titleSelectedColors(_ pageMenu: PageMenu) -> [UIColor]
    
    /* Menu Width Segment Type */
    @objc optional func menuHeaderWidthType(_ pageMenu: PageMenu) -> Int
    
    /* Menu Indicator Segment Type */
    @objc optional func indicatorSegmentType(_ pageMenu: PageMenu) -> Int
    
}

class PageMenu: UIView {
    
    //Delegate and Datasource
    var delegate: PageMenuDelegate?
    var dataSource: PageMenuDatasource!
    
    //Variables
    private var mainScrollView: UIScrollView!
    var pageHeader: HeaderMenu?
    private var isUpdateLayout: Bool = false
    private var bottomLine: UIView?
    
    var currentPage: UIView? {
        if indexSelected < pages.count {
            return pages[indexSelected]
        }
        return nil
    }
    var pages: [UIView] = []
    var indexSelected: Int = 0
    var hasBottomLineHeader: Bool = false {
        didSet {
            if let line = bottomLine {
                line.isHidden = !hasBottomLineHeader
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        mainScrollView = UIScrollView.init(frame: self.bounds)
        mainScrollView.backgroundColor = .clear
        mainScrollView.isPagingEnabled = true
        mainScrollView.delegate = self
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.autoresizingMask = .flexibleHeight
        addSubview(mainScrollView)
//        let constraints = [mainScrollView!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
//                           mainScrollView!.topAnchor.constraint(equalTo: topAnchor, constant: 0),
//                           mainScrollView!.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
//                           mainScrollView!.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
//        ]
//        
//        NSLayoutConstraint.activate(constraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isUpdateLayout {
            mainScrollView.frame = self.bounds
            self.initLayout()
        }
    }
    
    private func initLayout(_ currentPage: Int = 0) {
        indexSelected = -1
        isUpdateLayout = true
        guard let _ = self.dataSource else { return }
        // Add Header If Need
        let heightHeader = self.dataSource.heightForSegmentMenu(self)
        let numbersPage = self.dataSource.numbersPage(in: self)
        if numbersPage == 0 {
            return
        }
        if heightHeader > 0 {
            if let _ = self.dataSource.viewForMenuHeader, let segment = self.dataSource.viewForMenuHeader!(self) {
                segment.frame = CGRect(x: 0,
                                       y: 0,
                                       width: segment.frame.size.width,
                                       height: heightHeader)
                self.addSubview(segment)
            } else {
                initHeaderMenu(heightHeader, numbersPage, currentPage)
            }
            
            // Update frame scrollview
            let frame = mainScrollView.frame
            mainScrollView.frame = CGRect(x: frame.origin.x,
                                          y: heightHeader,
                                          width: frame.size.width,
                                          height: self.bounds.height - heightHeader)
        }
        
        for index in 0..<numbersPage {
            let view = self.dataSource.pageMenu(self, viewForPageAt: index)
            view.frame = CGRect(x: CGFloat(index) * self.bounds.size.width,
                                y: 0,
                                width: self.mainScrollView.bounds.size.width,
                                height: self.mainScrollView.bounds.size.height)
            pages.append(view)
            mainScrollView.addSubview(view)
            view.autoresizingMask = .flexibleHeight
        }
        mainScrollView.contentSize = CGSize(width: self.mainScrollView.bounds.size.width * CGFloat(numbersPage),
                                            height: self.mainScrollView.bounds.size.height)
        self.onSegmentDidChanged(currentPage)
    }
    
    func updatePagesFrame(_ rect: CGRect) {
        var frame = self.mainScrollView.frame
        frame.size.height = rect.height
        self.mainScrollView.frame = frame
        for page in pages {
            var frame = page.frame
            frame.size.height = rect.height
            page.frame = frame
        }
    }
    
    private func initHeaderMenu(_ heightHeader: CGFloat, _ numbersPage: Int, _ indexSelected: Int = 0) {
        pageHeader = HeaderMenu.init(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: self.mainScrollView.bounds.size.width,
                                                   height: heightHeader - 1.0))
        pageHeader!.delegate = self
        pageHeader!.backgroundColor = .clear
        
        addSubview(pageHeader!)
        
        // Add bottom line in header
        bottomLine = UIView(frame: CGRect(x: 0,
                                          y: pageHeader!.frame.maxY,
                                          width: self.mainScrollView.bounds.size.width,
                                          height: 1.0))
        bottomLine?.isHidden = false
        bottomLine?.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        addSubview(bottomLine!)
        
        // Add Item Header
        var items: [UIView] = []
        for index in 0..<numbersPage {
            let view = self.dataSource.pageMenu(self, viewForSegmentAt: index)
            items.append(view)
        }
        let normalsColor = self.dataSource.titleNormalColors(self)
        let selectedsColor = self.dataSource.titleSelectedColors(self)
        let tags = self.dataSource.tagsLabelForUpdateSegment(self)
        assert(normalsColor.count == selectedsColor.count, "State colors selected/normal is not equal")
        assert(normalsColor.count == tags.count, "State colors and tags Label is not equal")
        
        if let _ = self.dataSource.menuHeaderWidthType {
            if let value = MenuHeaderWidthType(rawValue: self.dataSource.menuHeaderWidthType!(self)) {
                pageHeader!.menuType = value
            }
        }
        if let _ = self.dataSource.indicatorSegmentType {
            if let value = MenuHeaderIndicatorType(rawValue: self.dataSource.indicatorSegmentType!(self)) {
                pageHeader!.indicatorType = value
            }
        }
        pageHeader!.indexSeleted = indexSelected
        pageHeader!.listItem = items
        pageHeader!.normalsColor = normalsColor
        pageHeader!.selectedsColor = selectedsColor
        pageHeader!.tags = tags
    }
    
    private func scrollDidEnd() {
        let index = Int(roundf(Float(mainScrollView.contentOffset.x/self.bounds.size.width)))
        if indexSelected != index {
            if let delegate = delegate {
                delegate.pageViewDidEndScroll(self, self.indexSelected, index, pages[index])
            }
            indexSelected = index
            if let header = pageHeader {
                header.updateSelectedItem(indexSelected)
            }
        }
    }
    
    func reloadPageMenu(_ page: Int) {
        self.mainScrollView.setContentOffset(.zero, animated: false)
        for view in mainScrollView.subviews {
            view.removeFromSuperview()
        }
        pageHeader?.removeFromSuperview()
        bottomLine?.removeFromSuperview()
        self.pages.removeAll()
        initLayout(page)
    }
    
    func reloadHeaderMenu() {
        let heightHeader = self.dataSource.heightForSegmentMenu(self)
        let numbersPage = self.dataSource.numbersPage(in: self)
        if heightHeader > 0 && pageHeader != nil {
            pageHeader!.removeFromSuperview()
            pageHeader = nil
            if numbersPage > 0 {
                initHeaderMenu(heightHeader, numbersPage)
            }
        }
    }
    
    func reloadData(index: Int = -1) {
        if let delegate = delegate,
           let _ = self.delegate?.pageReloadData,
           index < pages.count {
            delegate.pageReloadData!(self, index, pages)
        }
    }
    
    func scroll(to index: Int, _ animated: Bool = true) {
        self.indexSelected = index
        self.pageHeader?.updateSelectedItem(index)
        self.mainScrollView.setContentOffset(CGPoint(x: self.mainScrollView.bounds.size.width * CGFloat(indexSelected),
                                                     y: 0),
                                             animated: animated)
    }
}

// MARK: UIScrollViewDelegate

extension PageMenu: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollDidEnd()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDidEnd()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let delegate = delegate,
           let _ = self.delegate?.pageViewBeginScroll {
            let index = Int(roundf(Float(scrollView.contentOffset.x/self.bounds.size.width)))
            if index < pages.count {
                delegate.pageViewBeginScroll!(self, index, pages[index])
            }
        }
    }
}

// MARK: HeaderMenuDelegate

extension PageMenu: HeaderMenuDelegate {
    func onSegmentDidChanged(_ indexSelected: Int) {
        if self.indexSelected == indexSelected || indexSelected >= self.pages.count {
            return
        }
        let previousIndex = self.indexSelected
        self.indexSelected = indexSelected
        self.mainScrollView.setContentOffset(CGPoint(x: self.mainScrollView.bounds.size.width * CGFloat(indexSelected),
                                                     y: 0),
                                             animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let delegate = self.delegate {
                delegate.pageViewDidEndScroll(self, previousIndex, indexSelected, self.pages[indexSelected])
            }
        }
    }
}
