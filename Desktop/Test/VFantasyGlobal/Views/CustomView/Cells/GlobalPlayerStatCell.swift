//
//  GlobalPlayerStatCell.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class GlobalPlayerStatCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblClub: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var contentToBottomLayout: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateData(_ player: Player) {
        ivIcon.setPlayerAvatarRefreshCache(with: player.photo)
        lblName.text = player.name
        lblPosition.text = player.positionShortName().uppercased()
        lblClub.text = player.realClub?.name
        lblPoint.text = VFantasyCommon.formatPoint(player.point)
    }
    
    static var identifierCell: String {
        return "GlobalPlayerStatCell"
    }
    
    static var heightCell: CGFloat {
        return 72.0
    }
}
