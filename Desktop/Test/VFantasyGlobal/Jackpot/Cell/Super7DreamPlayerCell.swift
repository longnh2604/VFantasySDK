//
//  Super7DreamPlayerCell.swift
//  PAN689
//
//  Created by Quang Tran on 12/15/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class Super7DreamPlayerCell: UICollectionViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var ivStar: UIImageView!
    @IBOutlet weak var lblScore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configData(_ player: Player) {
        self.lblName.text = player.getNameDisplay()
        self.ivAvatar.setPlayerAvatar(with: player.photo)
        self.lblScore.text = "\(player.point ?? 0)"
    }
    
    static var sizeCell: CGSize {
        let width: CGFloat = (UIScreen.SCREEN_WIDTH - 33)/2.0
        return CGSize(width: width, height: 64)
    }

}
