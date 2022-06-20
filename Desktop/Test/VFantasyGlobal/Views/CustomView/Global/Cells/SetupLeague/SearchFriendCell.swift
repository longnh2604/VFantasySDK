//
//  SearchFriendCell.swift
//  PAN689
//
//  Created by Quang Tran Van on 1/5/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit

class SearchFriendCell: UITableViewCell {

    @IBOutlet weak var inviteUserLabel: UILabel!
    @IBOutlet weak var searchBar: IBDCUISearchBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configsUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configsUI() {
        inviteUserLabel.text = "invite_user_system".localiz().uppercased()
        searchBar.placeholder = "search_by_name".localiz()
    }

}
