//
//  GlobalRankingCell.swift
//  PAN689
//
//  Created by Quang Tran on 1/7/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit

class GlobalRankingCell: UITableViewCell {

    @IBOutlet weak var sttLabel: UILabel!
    @IBOutlet weak var sttImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalPointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateData(data: RankingData, index: Int, color: UIColor) {
        updateUI(data.rank ?? 0)
        nameLabel.text = data.name
        totalPointLabel.text = String(data.totalPoint ?? 0)
        self.backgroundColor = color
    }
    
    private func updateUI(_ index: Int) {
        sttLabel.text = String(index)
        sttImageView.isHidden = index > 3
        if index == 1 {
            sttImageView.image = VFantasyCommon.image(named: "ic_one")
        }
        if index == 2 {
            sttImageView.image = VFantasyCommon.image(named: "ic_two")
        }
        if index == 3 {
            sttImageView.image = VFantasyCommon.image(named: "ic_three")
        }
    }

}
