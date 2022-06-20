//
//  CustomCellPlayDetailRound.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/22/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class CustomCellPlayDetailRound: UITableViewCell {
    @IBOutlet weak var round: UILabel!
    @IBOutlet weak var point: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var statusChange: UIImageView!
    
    func reloadView(_ model:PlayerStatisticsMeta,_ indexPath:IndexPath) {
        round.text = String(format: "round_format".localiz(), model.round ?? indexPath.row + 1)
        
        point.text = "\(model.point ?? 0)"
        if let changeValue = model.change {
            if changeValue > 0 {
                change.text = "\(changeValue)"
                change.textColor = #colorLiteral(red: 0.3409999907, green: 0.6549999714, blue: 0, alpha: 1)
                statusChange.image = VFantasyCommon.image(named: "ic_up")
                statusChange.isHidden = false
            } else if changeValue < 0 {
                change.text = "\(-changeValue)"
                change.textColor = #colorLiteral(red: 0.8159999847, green: 0.1959999949, blue: 0.00800000038, alpha: 1)
                statusChange.image = VFantasyCommon.image(named: "ic_ArrowDown")
                statusChange.isHidden = false
            } else {
                //change == 0
                change.text = "-"
                statusChange.isHidden = true
            }
        }        
    }
}

class CustomCellTotalPointsGW: UITableViewCell {
    @IBOutlet weak var totalPoints: UILabel!
    
    func update(_ totalPoint: Int) {
        self.totalPoints.text = String(format: "This game week: points".localiz(), totalPoint)
    }
}
