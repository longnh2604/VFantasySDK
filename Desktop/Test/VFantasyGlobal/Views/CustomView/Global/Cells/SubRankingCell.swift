//
//  RankingCell.swift
//  PAN689
//
//  Created by AgileTech on 12/10/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class SubRankingCell: UICollectionViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var ivStatus: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(_ data: ItemRanking?) {
        if let name = data?.name {
            lblName.text = name.uppercased()
        } else {
            lblName.text = "-"
        }
        if let rank = data?.rank {
            lblRank.text = "\(rank)"
        } else {
            lblRank.text = "-"
        }
        let status = data?.rankStatus ?? 0
        ivStatus.image = MyLeagueCell.statusImage(status)
        ivStatus.isHidden = status == 0
    }

}
