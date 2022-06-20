//
//  MyLeagueDetailCell.swift
//  PAN689
//
//  Created by AgileTech on 12/11/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class NewGlobalRankingCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var contentToBottomLayout: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ivIcon.roundCorners(.allCorners, 8.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateData(data: RankingData, isWeekScore: Bool = false) {
        ivIcon.setPlayerAvatarRefreshCache(with: data.logo)
        lblNumber.text = String(data.rank ?? 0)
        lblName.text = data.name
        rankLabel.text = VFantasyCommon.formatPoint(isWeekScore ? data.point : data.totalPoint)
    }
    
    static var identifierCell: String {
        return "NewGlobalRankingCell"
    }
    
    static var heightCell: CGFloat {
        return 72
    }
}
