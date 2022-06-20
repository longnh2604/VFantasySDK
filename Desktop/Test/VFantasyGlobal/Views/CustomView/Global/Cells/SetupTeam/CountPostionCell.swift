//
//  CountPostionCell.swift
//  PAN689
//
//  Created by AgileTech on 12/13/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class CountPostionCell: UITableViewCell {

    @IBOutlet weak var gkCount: UIButton!
    @IBOutlet weak var defCount: UIButton!
    @IBOutlet weak var midCount: UIButton!
    @IBOutlet weak var attachCount: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        gkCount.dropShadow(color: .darkGray, offSet: CGSize(width: 0, height: 0), radius: 5)
        defCount.dropShadow(color: .darkGray, opacity: 0.5, offSet: .zero, radius: 5)
        midCount.dropShadow(color: .darkGray, opacity: 0.5, offSet: .zero, radius: 5)
        attachCount.dropShadow(color: .darkGray, opacity: 0.5, offSet: .zero, radius: 5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
