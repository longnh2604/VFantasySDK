//
//  GlobalRankingHeaderCell.swift
//  PAN689
//
//  Created by Quang Tran on 1/7/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit

class GlobalRankingHeaderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text = "global_ranking".localiz().uppercased()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTitle(_ text: String) {
        guard !text.isEmpty else { return }
        titleLabel.text = text.localiz().uppercased()
    }

}
