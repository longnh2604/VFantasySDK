//
//  GlobaNavigationBar.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol GlobaNavigationSearchBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationSearchBar)
    func onRightOnClick(_ sender: GlobaNavigationSearchBar)
    func onSearch(_ sender: GlobaNavigationSearchBar, _ key: String)
}

class GlobaNavigationSearchBar: UIView {

    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnRightWidthLayout: NSLayoutConstraint!
    @IBOutlet weak var btnRightToTrailing: NSLayoutConstraint!
    
    var delegate: GlobaNavigationSearchBarDelegate?
    var hasRightItem: Bool = true {
        didSet {
            self.btnRight.isHidden = !hasRightItem
            self.btnRightWidthLayout.constant = hasRightItem ? 44.0 : 0.0
            self.btnRightToTrailing.constant = hasRightItem ? 10.0 : 6.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = self.createFromNib()
        let contentView = views?.first as? UIView
        contentView?.backgroundColor = .clear
        contentView?.frame = self.bounds
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        setup()
    }
    
    func setup() {
        self.searchBar.delegate = self
        self.searchBar.layer.cornerRadius = 16.0
        self.searchBar.layer.masksToBounds = true
        self.updateLayoutIfNeed()
    }

    func updateLayoutIfNeed() {
        guard let heightLayout = self.constraints.first else {
            return
        }
        heightLayout.constant = max(64.0, 44 + KEY_WINDOW_SAFE_AREA_INSETS.top)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.delegate?.onLeftOnClick(self)
    }
    
    @IBAction func onRight(_ sender: Any) {
        self.delegate?.onRightOnClick(self)
    }
    
}

extension GlobaNavigationSearchBar: SearchBarDelegate {
    func onSearch(_ key: String) {
        self.delegate?.onSearch(self, key)
    }
}
