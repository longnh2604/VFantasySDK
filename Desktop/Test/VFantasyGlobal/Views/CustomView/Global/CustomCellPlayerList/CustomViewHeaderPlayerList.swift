//
//  CustomViewHeaderPlayerList.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/13/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class CustomButtonKey: UIButton {
    var key = ""
    var direction = "desc"
}

protocol CustomViewHeaderPlayerListDelegate: NSObjectProtocol {
    func didClickSort(_ key:String,_ direction:String)
}

class CustomViewHeaderPlayerList: UIView {

    @IBOutlet weak var nameOnce: UILabel!
    @IBOutlet weak var nameTwo: UILabel!
    @IBOutlet weak var nameThree: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: CustomViewHeaderPlayerListDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "name_club_pos".localiz()
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomViewHeaderPlayerList", bundle: Bundle.sdkBundler()).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func loadView(data:[FilterData]) {
        stackView.removeAllArrangedSubviews()
        let maxColums = 3
        
        for index in 0 ..< maxColums {
            guard index < data.count else {
                self.stackView.addArrangedSubview(self.createLabel())
                continue
            }
            // remove all button before add new
            if let viewButtonSort  = self.viewWithTag(index) as? CustomButtonKey {
                viewButtonSort.removeFromSuperview()
            }
            
            let display = data[index]
            // create button action
            let sortBt = self.createButton()
            sortBt.setTitle(display.name, for: .normal)
            sortBt.key = display.key
            sortBt.direction = display.direction.rawValue
            if sortBt.direction == "desc" {
                sortBt.setImage(VFantasyCommon.image(named: "ic_sort_desc"), for: .normal)
            } else if sortBt.direction == "asc" {
                sortBt.setImage(VFantasyCommon.image(named: "ic_sort_asc"), for: .normal)
            } else {
                sortBt.setImage(VFantasyCommon.image(named: "ic_sort_none"), for: .normal)
            }
            sortBt.addTarget(self, action: #selector(actionButtonSort(sender:)), for: .touchUpInside)
            self.stackView.addArrangedSubview(sortBt)
        }
    }
    
    @objc func actionButtonSort(sender:CustomButtonKey) {
        guard let delegate = self.delegate else {
            return
        }
        
        if sender.direction == SortType.desc.rawValue {
            sender.direction = SortType.asc.rawValue
        } else {
            sender.direction = SortType.desc.rawValue
        }
        
        delegate.didClickSort(sender.key, sender.direction)
    }
    
    func createButton() -> CustomButtonKey {
        let button = CustomButtonKey()
        button.setTitleColor(#colorLiteral(red: 0.5137254902, green: 0.4862745098, blue: 0.5254901961, alpha: 1), for: .normal)
        
        button.titleLabel?.font = UIFont(name: FontName.bold, size: 13)
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.frame = CGRect.zero
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        return button
    }
    
    func createLabel() -> UILabel {
        let temp = UILabel()
        temp.font = UIFont(name: FontName.bold, size: 13)
        temp.textColor = #colorLiteral(red: 0.5137254902, green: 0.4862745098, blue: 0.5254901961, alpha: 1)
        temp.textAlignment = .center
        return temp
    }
}
