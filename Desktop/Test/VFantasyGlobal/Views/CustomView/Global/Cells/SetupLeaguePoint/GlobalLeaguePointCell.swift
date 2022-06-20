//
//  GlobalLeaguePointCell.swift
//  PAN689
//
//  Created by Quang Tran on 1/10/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit

class GlobalLeaguePointCell: UITableViewCell {

    @IBOutlet weak var sttLabel: UILabel!
    @IBOutlet weak var sttImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var displays: [LeaguePointFilterData]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateData(data: LeaguePointModelView?, index: Int, color: UIColor) {
        updateUI(data?.rank ?? 0)
        nameLabel.text = data?.name
        self.backgroundColor = color
    }
    
    private func updateUI(_ index: Int) {
        sttLabel.text = "\(index)"
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
    
    func loadData(displays: [LeaguePointFilterData], model: LeaguePointModelView) {
        self.displays = displays
        let maxColums = 2
        
        stackView.removeAllArrangedSubviews()
        
        for index in 0 ..< displays.count {
            guard index < maxColums else { continue }
            
            let data = displays[index]
            let key = data.key
            
            if let text = model.value(forKey: key) as? String {
                let label = self.createLabel()
                label.text = text
                stackView.addArrangedSubview(label)
            }
        }
    }
    
    func createLabel() -> UILabel {
        let temp = UILabel()
        temp.font = UIFont(name: FontName.regular, size: 14)
        temp.textColor = UIColor(hexString: "#4A4A4A")
        temp.textAlignment = .right
        return temp
    }

}
