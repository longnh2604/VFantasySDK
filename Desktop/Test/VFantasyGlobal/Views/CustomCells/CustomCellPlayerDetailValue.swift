//
//  CustomCellPlayerDetailValue.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/20/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class CustomCellPlayerDetailValue: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func reloadView(_ model: StatisticWithTeamData) {
        name.text = model.name
        let types: [PlayerStatsType] = [.yellow_cards, .turnovers, .fouls_committed]
        if !types.filter({ return $0.rawValue == model.key.lowercased() }).isEmpty {
            name.textColor = UIColor(red: 252.0/255.0, green: 28.0/255.0, blue: 37.0/255.0, alpha: 1.0)
            value.textColor = UIColor(red: 252.0/255.0, green: 28.0/255.0, blue: 37.0/255.0, alpha: 1.0)
            value.text = model.value.roundToInt() == 0 ? "\(model.value.roundToInt())" : "-\(model.value.roundToInt())"
        } else {
            name.textColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            value.textColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            value.text = model.type == 0 ? "\(model.value.roundToInt())" : "\(model.value.roundToInt())"
        }
    }
}
