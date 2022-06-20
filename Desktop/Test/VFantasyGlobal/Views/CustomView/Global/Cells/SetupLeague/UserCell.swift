//
//  UserCell.swift
//  PAN689
//
//  Created by Quang Tran on 1/5/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit

protocol UserCellDelegate: NSObjectProtocol {
    func onInviteFriend(_ index: Int)
}

class UserCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var invitedLabel: UILabel!
    
    var index = 0
    weak var delegate: UserCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configUI() {
        inviteButton.titleLabel?.text = "invite".localiz()
        invitedLabel.text = "invited".localiz()
    }
    
    func updateUI(_ user: LeagueFriendDatum?) {
        guard let user = user else { return }
        avatarImageView.setPlayerAvatar(with: user.photo)
        userNameLabel.text = user.name
        inviteButton.isHidden = user.isInvited == true
        invitedLabel.isHidden = user.isInvited != true
    }

    // MARK: - Actions
    
    @IBAction func inviteTapped(_ sender: Any) {
        delegate?.onInviteFriend(index)
    }
    
}
