//
//  Super7WinnerCell.swift
//  PAN689
//
//  Created by User on 13/01/2022.
//  Copyright © 2022 PAN689. All rights reserved.
//

import UIKit

class Super7WinnerCell: UITableViewCell {

    @IBOutlet weak var lblWinerTeam: UILabel!
    @IBOutlet weak var ivAvatarWinerTeam: UIImageView!
    @IBOutlet weak var lineView: UIView!

    var winner: MyTeamData? = nil {
        didSet {
            lblWinerTeam.text = winner?.name
            ivAvatarWinerTeam.setPlayerAvatar(with: winner?.logo)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 
    static var identifierCell: String {
        return "Super7WinnerCell"
    }
    
    static var heightCell: CGFloat {
        return 72.0
    }
    
}
