//
//  TeamPlayerListHeaderCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 7/12/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol TeamPlayerListHeaderCellDelegate: NSObjectProtocol {
    func onChangeSort()
}

class TeamPlayerListHeaderCell: UITableViewCell {

    @IBOutlet weak var headerView: TeamPlayerListHeaderView!
    weak var delegate: TeamPlayerListHeaderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerView.delegate = self
    }
    
    func updateSort(_ type: SortType) {
        headerView.updateSort(type)
    }
    
    func hideSort() {
        headerView.hideSort()
    }
}

extension TeamPlayerListHeaderCell: TeamPlayerListHeaderViewDelegate {
    func onChangeSort() {
        delegate?.onChangeSort()
    }
}
