//
//  GlobalPickPlayerCell.swift
//  PAN689
//
//  Created by Quang Tran on 11/24/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class GlobalPickPlayerCell: UICollectionViewCell {
    
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblClub: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var ivRemove: UIImageView!
    
    @IBOutlet weak var ivAvatarWidthLayout: NSLayoutConstraint!
    @IBOutlet weak var lblNameHeightLayout: NSLayoutConstraint!
    
    weak var delegate: GlobalPlayerLineupCellDelegate?
    var index = 0
    var player: Player?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ivAvatar.contentMode = .scaleAspectFill
        
        self.lblName.textColor = .white
        self.lblName.font = UIFont(name: FontName.regular, size: 12)
        self.lblClub.textColor = .white
        self.lblClub.font = UIFont(name: FontName.regular, size: 10)
        self.lblPrice.textColor = .white
        self.lblPrice.font = UIFont(name: FontName.regular, size: 10)
        
        if VFantasyCommon.isIphone5() {
            self.lblNameHeightLayout.constant = 18.0
            self.ivAvatarWidthLayout.constant = 26.0
            self.ivAvatar.layer.cornerRadius = 13.0
            self.ivAvatar.layer.masksToBounds = true
        }
    }
    
    func reloadView(_ positionType: PlayerPositionType, _ player: Player?) {
        ivAvatar.setPlayerAvatarRefreshCache(with: player?.photo ?? "", placeHolder: VFantasyCommon.image(named: "add_avatar_default"))
        self.player = player
        if let player = player {
            self.btnRemove.isHidden = false
            self.ivRemove.isHidden = false
            lblName.text = player.getNameDisplay(.shortName)
            lblPrice.text = "€\(VFantasyCommon.budgetDisplay(player.transferValue))"
            if VFantasyManager.shared.isVietnamese() {
                lblPrice.text = "\(VFantasyCommon.budgetDisplay(player.transferValue))"
            }
            lblClub.text = player.realClubName()
        } else {
            self.btnRemove.isHidden = true
            self.ivRemove.isHidden = true
            ivAvatar.image = VFantasyCommon.image(named: "add_avatar_default")
            lblName.text = "pick".localiz()
            lblPrice.text = "-"
            lblClub.text = "-"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func playerTapped(_ sender: Any) {
        delegate?.tappedPlayer(index: index, player: player)
    }
    
    @IBAction func removePlayer(_ sender: Any) {
        delegate?.removePlayer(index: index, player: player)
    }
}
