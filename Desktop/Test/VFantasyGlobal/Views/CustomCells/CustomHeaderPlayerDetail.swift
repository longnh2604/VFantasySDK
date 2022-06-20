//
//  CustomHeaderPlayerDetail.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/22/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class CustomHeaderPlayerDetail: UIView {

    @IBOutlet weak var roundName: UILabel!
    @IBOutlet weak var point: UILabel!
    @IBOutlet weak var change: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundName.text = "round".localiz()
        point.text = "points".localiz()
        change.text = "change".localiz()
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomHeaderPlayerDetail", bundle: Bundle.sdkBundler()).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
