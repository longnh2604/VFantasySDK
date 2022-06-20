//
//  RankingViewHeader.swift
//  PAN689
//
//  Created by Quang Tran on 1/7/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import Foundation
import UIKit

class RankingViewHeader: UIView {

    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var totalPointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configsUI()
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "RankingViewHeader", bundle: Bundle.sdkBundler()).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    private func configsUI() {
        teamLabel.text = "team".localiz().uppercased()
        totalPointLabel.text = "total_pts".localiz().uppercased()
    }
}
