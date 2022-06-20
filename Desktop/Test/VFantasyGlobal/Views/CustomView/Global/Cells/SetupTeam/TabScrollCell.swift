//
//  TabScrollCell.swift
//  PAN689
//
//  Created by AgileTech on 12/13/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class TabScrollCell: UITableViewCell {

    @IBOutlet weak var tabControl: CustomPageContol!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupTab()
    }
    func setupTab() {
        guard let customFont = UIFont(name: FontName.blackItalic, size: FontSize.large) else {
            return
        }
        tabControl.delegate = self
        tabControl.isLeagueDetail = true
        tabControl.loadData(data: ["Line-up".localiz(), "Player List".localiz()], indexPath: IndexPath.init(row: 0, section: 0), font: customFont)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension TabScrollCell: CustomPageControlDelegate {
    func currentIndex(indexPath: IndexPath) {
    }
    
    
}

