//
//  PlayerLineupCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/11/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol GlobalPlayerLineupCellDelegate: NSObjectProtocol {
    func removePlayer(index: Int, player: Player?)
    func tappedPlayer(index: Int, player: Player?)
}

class GlobalPlayerLineupCell: UICollectionViewCell {
    
    @IBOutlet weak var playerImage: UIImageView!
    @IBOutlet weak var removeButton: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var borderImage: UIImageView!
    @IBOutlet weak var addIcon: UIImageView!
    @IBOutlet weak var injuredLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    weak var delegate: GlobalPlayerLineupCellDelegate?
    var index = 0
    
    func reloadView(_ positionType: PlayerPositionType, _ player: Player?, _ hideRemoveButton: Bool) {
        switch positionType {
        case .attacker:
            borderImage.image = VFantasyCommon.image(named: "ic_attacker_border")
            if let player = player {
                playerImage.setPlayerAvatarRefreshCache(with: player.photo)
            } else {
                addIcon.image = VFantasyCommon.image(named: "ic_add_attacker")
            }
        case .midfielder:
            borderImage.image = VFantasyCommon.image(named: "ic_midfielder_border.png")
            if let player = player {
                playerImage.setPlayerAvatarRefreshCache(with: player.photo)
            } else {
                addIcon.image = VFantasyCommon.image(named: "ic_add_midfielder.png")
            }
        case .defender:
            borderImage.image = VFantasyCommon.image(named: "ic_defender_border.png")
            if let player = player {
                playerImage.setPlayerAvatarRefreshCache(with: player.photo)
            } else {
                addIcon.image = VFantasyCommon.image(named: "ic_add_defender.png")
            }
        default:
            borderImage.image = VFantasyCommon.image(named: "ic_goalkeeeper_border.png")
            if let player = player {
                playerImage.setPlayerAvatarRefreshCache(with: player.photo)
            } else {
                addIcon.image = VFantasyCommon.image(named: "ic_add_goalkeeper.png")
            }
        }
        if let player = player {
            removeButton.isHidden = hideRemoveButton
            playerImage.isHidden = false
            addIcon.isHidden = true
            nameLabel.text = player.getNameDisplay(.shortName)
            valueLabel.text = player.transferValue?.priceDisplay
            if let injured = player.isInjured {
                injuredLabel.injured()
                injuredLabel.isHidden = !injured
            }
        } else {
            nameLabel.text = " "
            valueLabel.text = " "
            removeButton.isHidden = true
            playerImage.isHidden = true
            addIcon.isHidden = false
            injuredLabel.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func removePlayerTapped(_ sender: Any) {
        delegate?.removePlayer(index: index, player: nil)
    }
}
