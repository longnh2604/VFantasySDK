//
//  GlobalLeagueHeaderView.swift
//  PAN689
//
//  Created by AgileTech on 12/2/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class GlobalLeagueHeaderView: UIView {

    @IBOutlet weak var title: UILabel!
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GlobalLeagueHeaderView", bundle: Bundle.sdkBundler()).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
