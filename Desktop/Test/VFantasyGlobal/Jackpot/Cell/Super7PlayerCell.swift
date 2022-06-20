//
//  GlobalPlayerStatCell.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol Super7PlayerCellDelegate {
    func onAction(sender: Super7PlayerCell, _ player: Player)
}

class Super7PlayerCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var contentToBottomLayout: NSLayoutConstraint!
    
    var player: Player!
    var delegate: Super7PlayerCellDelegate?
    
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
    }
    
    @IBAction func onClick(_ sender: Any) {
        if self.player.isSelected != true {
            self.delegate?.onAction(sender: self, self.player)
        }
    }
    
    static var identifierCell: String {
        return "Super7PlayerCell"
    }
    
    static var heightCell: CGFloat {
        return 72.0
    }
}
