//
//  SegmentItemView.swift
//  VTMan
//
//  Created by Quang Tran on 3/23/19.
//  Copyright © 2019 ppcLink. All rights reserved.
//

import UIKit

protocol SegmentItemViewDelegate {
    func selectedItem(_ sender: SegmentItemView, _ index: Int)
}

class SegmentItemView: UIView {
    
    @IBOutlet weak var lblName: UILabel!
    
    var delegate: SegmentItemViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = self.createFromNib()
        if let containerView = views?.first as? UIView {
            containerView.backgroundColor = .clear
            containerView.frame = self.bounds
            addSubview(containerView)
        }
        setup()
    }
    
    func setup() {
        
    }
    
    func updateItem(_ name: String) {
        lblName.text = name
    }
    
    func getWidthItem() -> CGFloat {
        self.layoutIfNeeded()
        return lblName.bounds.width
    }
    
    @IBAction func onSelected(_ sender: Any) {
        if let delegate = delegate {
            delegate.selectedItem(self, self.tag)
        }
    }
}
