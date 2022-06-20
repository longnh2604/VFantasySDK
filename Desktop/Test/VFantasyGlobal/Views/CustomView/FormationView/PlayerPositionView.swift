//
//  PlayerView.swift
//  LetsPlay360
//
//  Created by Quang Tran on 11/13/19.
//  Copyright © 2019 quangtran. All rights reserved.
//

import UIKit
import SwiftDate

class PlayerPositionView: UIView {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var mainView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = self.createFromNib()
        if let containerView = views?.first as? UIView {
            containerView.backgroundColor = .clear
            containerView.frame = self.bounds
            addSubview(containerView)
        }
    }
    
    func update(_ position: Int?) {
        if let position = position {
            lblName.text = positionName(position)
          mainView.backgroundColor = PlayerPositionView.positionColor(position)
            mainView.isHidden = false
        } else {
            mainView.isHidden = true
        }
    }
    
    private func positionName(_ position: Int) -> String {
        switch position {
            case 0: return "G"
            case 1: return "D"
            case 2: return "M"
            case 3: return "A"
            default: return ""
        }
    }
        
    static func positionColor(_ position: Int) -> UIColor? {
        switch position {
            case 0: return UIColor(red: 68.0/255.0, green: 155.0/255.0, blue: 231.0/255.0, alpha: 1.0)
            case 1: return UIColor(red: 90.0/255.0, green: 165.0/255.0, blue: 28.0/255.0, alpha: 1.0)
            case 2: return UIColor(red: 253.0/255.0, green: 187.0/255.0, blue: 88.0/255.0, alpha: 1.0)
            case 3: return UIColor(red: 252.0/255.0, green: 28.0/255.0, blue: 37.0/255.0, alpha: 1.0)
            default: return UIColor(red: 234.0/255.0, green: 228.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        }
    }
    
}
