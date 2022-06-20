//
//  ConfirmLineupCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/11/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class GlobalConfirmLineupCell: UITableViewCell {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var completeButton: CustomButton!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    weak var delegate: GlobalConfirmLineupCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        valueLabel.text = "value".localiz()
        budgetLabel.text = "bank".localiz().uppercased() + ":"
        completeButton.setTitle("complete_team".localiz().uppercased(), for: .normal)
        //toggleSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        enableCompleteTeam()
    }
    
//    @objc func stateChanged(_ toggle: UISwitch) {
//        NotificationCenter.default.post(name: NotificationName.updateField, object: nil, userInfo: [NotificationKey.showValue : toggle.isOn])
//    }
    
    func reloadView(_ budget: Double, sumValue: Int) {
        priceLabel.text = budget.priceDisplay
        valueLabel.text = sumValue.priceDisplay
    }
    
    func hideCompleteButton() {
        completeButton.hidden(true)
    }
    
    func disableCompleteTeam() {
        completeButton.shadowLayer?.isHidden = true
        completeButton.setBackgroundImage(nil, for: .normal)
        completeButton.backgroundColor = .gray
        completeButton.isUserInteractionEnabled = false
    }
    
    func enableCompleteTeam() {
        completeButton.shadowLayer?.isHidden = false
        completeButton.setBackgroundImage(VFantasyCommon.image(named: "ic_bg_button.png"), for: .normal)
        completeButton.backgroundColor = .clear
        completeButton.isUserInteractionEnabled = true
    }
    
    @IBAction func onComplete(_ sender: Any) {
        delegate?.onCompleteLineup()
    }
}
