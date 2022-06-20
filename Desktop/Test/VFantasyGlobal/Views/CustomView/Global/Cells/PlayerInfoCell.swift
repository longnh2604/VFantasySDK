//
//  PlayerInfoCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/12/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol PlayerInfoCellDelegate: NSObjectProtocol {
    func onPick(_ cell: PlayerInfoCell)
}

class PlayerInfoCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var mainPosLabel: UILabel!
    @IBOutlet weak var minorPosLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var clubLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    weak var delegate: PlayerInfoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    @IBAction func onPick(_ sender: Any) {
        self.delegate?.onPick(self)
    }
    
    func updateData(_ player: Player) {
        thumbnail.setPlayerAvatar(with: player.photo)
        mainPosLabel.setPosition(player.mainPosition ?? 0)
        if let minorPos = player.minorPosition {
            minorPosLabel.isHidden = false
            minorPosLabel.setPosition(minorPos)
        } else {
            minorPosLabel.isHidden = true
        }
        nameLabel.text = player.getNameDisplay()
        clubLabel.text = player.realClub?.name
        let points = player.pointLastRound ?? 0
        pointsLabel.text = String(format: "last_round_format".localiz(), points.toPoints())
        let price = player.transferValue ?? 0
        priceLabel.text = price.priceDisplay
        priceLabel.isHidden = false
        let selected = player.isSelected ?? false
        statusButton.isHidden = false
        statusButton.setImage(selected ? VFantasyCommon.image(named: "ic_added_player.png") : VFantasyCommon.image(named: "ic_add_player.png"), for: .normal)
    }
    
    func hidePrice() {
        priceLabel.isHidden = true
    }
    
    func hideStatusButton(_ isHide: Bool) {
        statusButton.isHidden = isHide
    }
}
