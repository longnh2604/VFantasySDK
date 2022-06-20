//
//  GlobalLeaguePointViewHeader.swift
//  PAN689
//
//  Created by Quang Tran on 1/10/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import Foundation
import UIKit

protocol GlobalLeaguePointViewHeaderDelegate: NSObjectProtocol {
    func didFilter()
}

class GlobalLeaguePointViewHeader: UIView {

    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var filterButton: UIButton!
    
    weak var delegate: GlobalLeaguePointViewHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configsUI()
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GlobalLeaguePointViewHeader", bundle: Bundle.sdkBundler()).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    // MARK: - Configs UI
    
    private func configsUI() {
        teamLabel.text = "team".localiz().uppercased()
    }
    
    func updateUI(isFiltered: Bool) {
        let image = isFiltered ? VFantasyCommon.image(named: "ic_filter_blue") : VFantasyCommon.image(named: "ic_FilterList")
        filterButton.setImage(image, for: .normal)
    }
    
    func loadView(data: [LeaguePointFilterData]) {
        stackView.removeAllArrangedSubviews()
        let maxColums = 2
        
        for index in 0 ..< data.count {
            guard index < maxColums else { continue }
            let label = self.createLabel()
            if index < data.count {
                label.text = data[index].name.uppercased()
            }
            self.stackView.addArrangedSubview(label)
        }
    }
    
    func createLabel() -> UILabel {
        let temp = UILabel()
        temp.font = UIFont(name: FontName.regular, size: 12)
        temp.textColor = .white
        temp.textAlignment = .right
        return temp
    }
    
    // MARK: - Actions
    
    @IBAction func filterTapped(_ sender: Any) {
        delegate?.didFilter()
    }
}
