//
//  PlayerCell.swift
//  PAN689
//
//  Created by AgileTech on 12/16/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class PlayerCell: UICollectionViewCell {
    @IBOutlet weak var avatarButton: UIButton!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarButton.isHidden = false
        removeButton.isHidden = false
    }
    func setupCell(position: PlayerPositionType) {
        removeButton.isHidden = true
        
    }
    func setDefaultImage(position: PlayerPositionType) {
        switch position {
        case .goalkeeper:
            avatarButton.setBackgroundImage(VFantasyCommon.image(named: "add_goalkeeper"), for: .normal)
        case .defender:
            avatarButton.setBackgroundImage(VFantasyCommon.image(named: "add_defender"), for: .normal)
        case .midfielder:
            avatarButton.setBackgroundImage(VFantasyCommon.image(named: "add_midfielder"), for: .normal)
        case .attacker:
            avatarButton.setBackgroundImage(VFantasyCommon.image(named: "add_attacker"), for: .normal)
        default:
            break
        }
    }
    func setBoderImage(position: PlayerPositionType) {
        removeButton.isHidden = false
        switch position {
        case .goalkeeper:
            avatarButton.setBackgroundImage(VFantasyCommon.image(named: "ic_goalkeeeper_border"), for: .normal)
        case .defender:
            avatarButton.setBackgroundImage(VFantasyCommon.image(named: "ic_defender_border"), for: .normal)
        case .midfielder:
            avatarButton.setBackgroundImage(VFantasyCommon.image(named: "ic_midfielder_border"), for: .normal)
        case .attacker:
            avatarButton.setBackgroundImage(VFantasyCommon.image(named: "ic_attacker_border"), for: .normal)
        default:
            break
        }
    }
}
