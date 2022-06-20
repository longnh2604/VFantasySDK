//
//  FooterView.swift
//  PAN689
//
//  Created by AgileTech on 12/16/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class FooterView: UIView {

     class func instanceFromNib() -> UIView {
           return UINib(nibName: "FooterView", bundle: Bundle.sdkBundler()).instantiate(withOwner: nil, options: nil)[0] as! UIView
       }

}
