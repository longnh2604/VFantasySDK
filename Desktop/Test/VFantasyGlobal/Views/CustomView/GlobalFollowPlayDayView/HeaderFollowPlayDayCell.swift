//
//  HeaderHomeCell.swift
//  its_ready
//
//  Created by Tu Tran on 10/14/20.
//  Copyright © 2020 Quang Tran. All rights reserved.
//

import UIKit

class HeaderFollowPlayDayCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static var nib: UINib {
        return UINib.init(nibName: self.className, bundle: Bundle.sdkBundler())
    }
    
    static var identifier: String {
        return self.className
    }
    
    static var heightCell: CGFloat {
        return 42
    }

}
