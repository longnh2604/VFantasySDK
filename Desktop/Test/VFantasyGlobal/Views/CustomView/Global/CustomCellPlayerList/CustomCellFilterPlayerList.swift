//
//  CustomCellFilterPlayerList.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/13/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol CustomCellFilterPlayerListDelegate: NSObjectProtocol {
    func didClickFilter()
    func didClickSection(_ id: String)
    func didClickDisplay()
}

class CustomCellFilterPlayerList: UITableViewCell {
    weak var delegate: CustomCellFilterPlayerListDelegate?
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var displayButton: UIButton!
    @IBOutlet weak var searchBar: IBDCUISearchBar!
    @IBOutlet weak var dropdownView: DropdownSelectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dropdownHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropdownTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var budgetTitleLabel: UILabel!
    @IBOutlet weak var budgetValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateUIFollowType(type: .playerList)
        
        searchBar.placeholder = "search_player_placeholder".localiz()
        searchBar.isShowCancel = false
        filterButton.setTitle("filter".localiz(), for: .normal)
        displayButton.setTitle("display".localiz(), for: .normal)
        budgetTitleLabel.text = "bank".localiz().uppercased()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAnywhere(_:)))
        self.addGestureRecognizer(tapGesture)
        
        guard let customFont = UIFont(name: FontName.bold, size: FontSize.normal) else {
            return
        }
        searchBar.updateFontPlaceHolder(font: customFont)
        dropdownView.delegate = self
        
    }
    
    @objc func tapAnywhere(_ sender: Any) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func actionFilter(_ sender: Any) {
        guard let delegate = self.delegate else {return}
        delegate.didClickFilter()
    }
    
    @IBAction func actionDisplay(_ sender: Any) {
        guard let delegate = self.delegate else {return}
        delegate.didClickDisplay()
    }
    
    func reloadView(seasons: [SeasonData], current: SeasonData?) {
        dropdownView.setData(VFantasyCommon.getCheckboxFilters(seasons, current: current))
    }
    
    func setTitle(_ text: String) {
        titleLabel.text = text.localiz().uppercased()
    }
    
    func updateUIFollowType(type: PlayerListType) {
        budgetTitleLabel.isHidden = type != .playerPool
        budgetValueLabel.isHidden = type != .playerPool
        
        guard type == .playerPool else { return }
        dropdownTopConstraint.constant = 10
        dropdownHeightConstraint.constant = 0
    }
    
    func setBudgetTitle(value: Double) {
        budgetValueLabel.text = value.priceDisplay
    }
}

extension CustomCellFilterPlayerList : DropdownSelectionViewDelegate {
    func didTapDropdown(_ tag: Int) {
        dropdownView.showCheckBox()
    }
  
    func didChangeSort(_ tag: Int) {
        if let data = dropdownView.selectedData {
            if let id = data.key {
                delegate?.didClickSection(id)
            }
        }
    }
}
