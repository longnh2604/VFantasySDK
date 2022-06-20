//
//  CustomTableView.swift
//  VFantasyGlobal
//
//  Created by User on 26/05/2022.
//

import Foundation
import UIKit
import PureLayout

class CustomTableView: UITableView {
    var noResultLb: UILabel? = nil
    
    func isShowNoResult(_ count:Int = 0) {
        if count == 0 {
            showNoResult()
        } else {
            hiddenNoResult()
        }
    }
    
    func showNoResult(_ text: String = "no_data".localiz()) {
        if noResultLb == nil {
            noResultLb = UILabel.init(frame: .zero)
            noResultLb?.text = text
            noResultLb?.textAlignment = .center
            
            let footer = UIView.init(frame: .zero)
            footer.addSubview(noResultLb!)
            self.tableFooterView = footer
            self.tableFooterView?.height = 50
            
            noResultLb?.autoAlignAxis(toSuperviewAxis: .horizontal)
            noResultLb?.autoAlignAxis(toSuperviewAxis: .vertical)
        }
    }
    
    func hiddenNoResult() {
        if noResultLb != nil {
            noResultLb?.removeFromSuperview()
            noResultLb = nil
        }
    }
}
