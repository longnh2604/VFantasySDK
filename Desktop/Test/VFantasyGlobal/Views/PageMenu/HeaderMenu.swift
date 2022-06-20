//
//  HeaderMenu.swift
//  VTMan
//
//  Created by Quang Tran on 3/27/19.
//  Copyright © 2019 ppcLink. All rights reserved.
//

import UIKit

/**
 ** MenuHeaderWidthType. Default is automatic
 */
enum MenuHeaderWidthType: Int {
    case equal = 0      //Width scrollview equal self.bounds.size.width
    case automatic      //Width scrollview increament by item
}

/**
 ** MenuHeaderIndicatorType. Default is bounds
 */
enum MenuHeaderIndicatorType: Int {
    case average = 0  //Width indicator equal average of number items. Only use when MenuHeaderType == equal
    case bounds       //Width indicator equal frame of item. Default
}

protocol HeaderMenuDelegate {
    func onSegmentDidChanged(_ indexSelected: Int)
}

class HeaderMenu: UIView {
    
    let heightIndicator: CGFloat = 2.0
    let offsetX: CGFloat = 16.0
    let betweenItem: CGFloat = 0.0
    
    private var mainScroll: UIScrollView!
    var indicatorView: UIView!
    var indexSeleted: Int = 0
    
    var menuType: MenuHeaderWidthType = .automatic
    var indicatorType: MenuHeaderIndicatorType = .bounds
    
    var listItem: [UIView] = [] {
        didSet {
            initLayout()
        }
    }
    
    var tags: [Int] = [] {
        didSet {
            updateElements()
        }
    }
    
    var normalsColor: [UIColor] = []
    var selectedsColor: [UIColor] = []
    var delegate: HeaderMenuDelegate?
    
    deinit {
        for view in self.mainScroll.subviews {
            view.removeFromSuperview()
        }
        self.mainScroll.removeFromSuperview()
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
        self.backgroundColor = .clear
        mainScroll = UIScrollView(frame: self.bounds)
        mainScroll.backgroundColor = .clear
        mainScroll.showsVerticalScrollIndicator = false
        mainScroll.showsHorizontalScrollIndicator = false
        addSubview(mainScroll)
    }
    
    func initLayout() {
        for view in self.mainScroll.subviews {
            view.removeFromSuperview()
        }
        if menuType == .equal {
            var totalWidth: CGFloat = 0.0
            for item in listItem {
                totalWidth += item.frame.size.width
            }
            if totalWidth >= (self.bounds.size.width - 40) {
                menuType = .automatic
            }
        }
        if menuType == .automatic {
            indicatorType = .bounds
        }
        var originX = offsetX
        let maxWidth = self.bounds.size.width / CGFloat(listItem.count)
        
        for index in 0..<listItem.count {
            let item = listItem[index]
            
            var leftX: CGFloat = 0.0
            if menuType == .equal {
                leftX = (maxWidth - item.frame.size.width)/2.0
                leftX = leftX < 0 ? 0 : leftX
            }
            item.frame = CGRect(x: menuType == .equal ? (maxWidth * CGFloat(index) + leftX) : originX,
                                y: (bounds.size.height - item.bounds.height)/2.0,
                                width: item.frame.size.width,
                                height: item.bounds.height)
            item.tag = index
            originX = item.frame.maxX + (menuType == .equal ? 0 : betweenItem)
            let btn = UIButton.init(type: .system)
            if menuType == .equal {
                btn.frame = CGRect(x: maxWidth * CGFloat(index), y: 0, width: maxWidth, height: bounds.size.height)
            } else {
                btn.frame = item.frame
            }
            btn.tag = 1000 + index
            btn.setTitle(nil, for: .normal)
            btn.addTarget(self, action: #selector(onSelectedSegment(_:)), for: .touchUpInside)
            mainScroll.addSubview(item)
            mainScroll.addSubview(btn)
        }
        if menuType == .automatic {
            originX -= (betweenItem - offsetX)
            mainScroll.contentSize = CGSize(width: originX,
                                            height: mainScroll.bounds.size.height)
        }
        mainScroll.isScrollEnabled = menuType == .automatic
        
        initIndicatorView()
        updateElements()
    }
    
    func initIndicatorView() {
        indicatorView?.removeFromSuperview()
        indicatorView = UIView(frame: CGRect(x: 0, y: bounds.size.height - heightIndicator, width: 16, height: heightIndicator))
        indicatorView.backgroundColor = UIColor(hex: 0xF87221)
        mainScroll.addSubview(indicatorView)
        updateLayoutIndicator(false)
    }
    
    func updateLayoutIndicator(_ animated: Bool = true) {
        if listItem.isEmpty {
            return
        }
        let element = listItem[indexSeleted]
        UIView.animate(withDuration: animated ? 0.25 : 0.0) {
            let originX = self.menuType == .equal ? (CGFloat(self.indexSeleted) * self.bounds.size.width/CGFloat(self.listItem.count)) : element.frame.origin.x
            self.indicatorView.frame = CGRect(x: originX,
                                              y: self.mainScroll.bounds.height - self.heightIndicator,
                                              width: element.bounds.width,
                                              height: self.heightIndicator)
        }
        if menuType == .automatic {
            let offsetX = element.frame.origin.x + element.bounds.size.width/2.0 - mainScroll.bounds.size.width/2.0
            mainScroll.scrollRectToVisible(CGRect(x: offsetX,
                                                  y: 0,
                                                  width: mainScroll.bounds.size.width,
                                                  height: mainScroll.bounds.size.height), animated: animated)
        }
    }
    
    @objc func onSelectedSegment(_ sender: UIButton) {
        let index = sender.tag - 1000
        if index != indexSeleted {
            indexSeleted = index
            updateLayout()
            if let delegate = delegate {
                delegate.onSegmentDidChanged(indexSeleted)
            }
        }
    }
    
    func updateLayout() {
        updateLayoutIndicator()
        updateElements()
    }
    
    func updateSelectedItem(_ index: Int) {
        indexSeleted = index
        self.updateLayout()
    }
    
    func updateElements() {
        for index in 0..<listItem.count {
            let element = listItem[index]
            for i in 0..<tags.count {
                let selected = indexSeleted == index
                let color = !selected ? normalsColor[i] : selectedsColor[i]
                if let lable = getElementWithTag(element, tags[i]) as? UILabel {
                    lable.textColor = color
                }
            }
        }
    }
    
    func getElementWithTag(_ view: UIView, _ tag: Int) -> UIView? {
        if let item = view.viewWithTag(tag) {
            return item
        }
        let views = view.subviews
        for item in views {
            return self.getElementWithTag(item, tag)
        }
        return nil
    }
    
}
