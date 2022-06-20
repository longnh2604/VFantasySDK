//
//  GlobalPlayerStatCell.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol GlobalPlayerNewCellDelegate {
    func onAction(sender: GlobalPlayerNewCell, _ player: Player)
}

class GlobalPlayerNewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblClub: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var contentToBottomLayout: NSLayoutConstraint!
    
    var player: Player!
    var delegate: GlobalPlayerNewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateData(_ player: Player) {
        self.player = player
        ivIcon.setPlayerAvatarRefreshCache(with: player.photo)
        lblName.text = player.name
        lblPosition.text = player.positionShortName().uppercased()
        lblClub.text = player.realClub?.name
        lblPoint.text = VFantasyCommon.formatPoint(player.point)
        lblValue.text = VFantasyCommon.budgetDisplay(player.transferValue)
        btnAdd.isHidden = !player.isAddNew || !player.isEnoughMoneyForTransfer
    }
    
    func swapToHighlightMode() {
        self.mainView.backgroundColor = UIColor(hex: 0xF6F7FB)
        self.lblName.textColor = UIColor(hex: 0x1E2539)
        self.lblPoint.textColor = UIColor(hex: 0x1E2539)
        self.btnAdd.isHidden = false
        self.btnAdd.setImage(VFantasyCommon.image(named: "global_ic_transfer_swap"), for: .normal)
    }
    
    @IBAction func onClick(_ sender: Any) {
        if self.player.isSelected != true {
            self.delegate?.onAction(sender: self, self.player)
        }
    }
    
    static var identifierCell: String {
        return "GlobalPlayerNewCell"
    }
    
    static var heightCell: CGFloat {
        return 72.0
    }
}
