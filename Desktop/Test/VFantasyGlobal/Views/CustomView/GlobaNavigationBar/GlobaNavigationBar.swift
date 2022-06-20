//
//  GlobaNavigationBar.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol GlobaNavigationBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationBar)
}

class GlobaNavigationBar: UIView {

    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var ivAvatar: UIImageView!
    
    var delegate: GlobaNavigationBarDelegate?
    var headerTitle: String = "" {
        didSet {
            self.lblHeader.text = headerTitle
        }
    }
    var hasLeftBtn: Bool = true {
        didSet {
            self.btnLeft.isHidden = !hasLeftBtn
            self.btnLeft.isUserInteractionEnabled = hasLeftBtn
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
        self.updateLayoutIfNeed()
    }

    func updateLayoutIfNeed() {
        guard let heightLayout = self.constraints.first else {
            return
        }
        heightLayout.constant = 44 + KEY_WINDOW_SAFE_AREA_INSETS.top
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.delegate?.onLeftOnClick(self)
    }
    
}
