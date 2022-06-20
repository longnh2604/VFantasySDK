//
//  GlobalPlayerListPositionCell.swift
//  PAN689
//
//  Created by Quang Tran on 11/25/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class GlobalPlayerListPositionCell: UICollectionViewCell {

    @IBOutlet weak var lblPosition: UILabel!
    
    var isActive: Bool = false {
        didSet {
            lblPosition.backgroundColor = isActive ? UIColor(white: 1.0, alpha: 0.2) : .clear
            lblPosition.layer.cornerRadius = 15.0
            lblPosition.layer.masksToBounds = true
            lblPosition.layer.borderWidth = isActive ? 1 : 0.0
            lblPosition.layer.borderColor = isActive ? UIColor(white: 1.0, alpha: 0.2).cgColor : UIColor.clear.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblPosition.font = UIFont(name: FontName.bold, size: 14)
    }

}
