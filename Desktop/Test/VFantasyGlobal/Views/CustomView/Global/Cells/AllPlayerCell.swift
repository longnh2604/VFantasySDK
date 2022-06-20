//
//  AllPlayerCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/25/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class AllPlayerCell: UICollectionViewCell {

    @IBOutlet weak var allLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        allLabel.text = "all".localiz().uppercased()
    }

}
