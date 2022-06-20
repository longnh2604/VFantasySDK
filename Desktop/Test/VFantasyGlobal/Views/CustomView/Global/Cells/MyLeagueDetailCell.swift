//
//  MyLeagueDetailCell.swift
//  PAN689
//
//  Created by AgileTech on 12/11/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class MyLeagueDetailCell: UITableViewCell {
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var leagueNameLabel: UILabel!
    @IBOutlet weak var lineView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        ivIcon.roundCorners(.allCorners, radius: 8.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var heightCell: CGFloat {
        return 64
    }
    
}
