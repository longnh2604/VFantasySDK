//
//  SuccessorTableViewCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 5/23/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class SuccessorTableViewCell: UITableViewCell {

    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
