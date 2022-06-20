//
//  PositionTrackerCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/12/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class PositionTrackerCell: UICollectionViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        countLabel.shadowView(color: UIColor.gray, cornerRadius: 4, size: CGSize.init(width: 0, height: 2), shadowRadius: 3, cornerRadiusShadow: 2, clipToBounds: true)
    }
    
    func active(_ datum: PositionCountModel) {
        updateView(datum)
        positionLabel.active(datum.pos.rawValue)
    }
    
    func inactive(_ datum: PositionCountModel) {
        updateView(datum)
        positionLabel.inactive()
    }
    
    private func updateView(_ datum: PositionCountModel) {
        let pos = datum.pos.rawValue
        positionLabel.setPosition(pos)
        countLabel.text = String(datum.count)
    }
}
