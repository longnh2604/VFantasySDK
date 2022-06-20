//
//  PlayerBottomCell.swift
//  PAN689
//
//  Created by Quang Tran on 12/28/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class PlayerBottomCell: UICollectionViewCell {

    @IBOutlet weak var playerView: PlayerView!

    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.updateUIDark()
    }

    static var identifierCell: String {
        return "PlayerBottomCell"
    }
    
    static var sizeCell: CGSize {
        return CGSize(width: 50, height: 110)
    }
    
}

