//
//  CompleteCreateTeamCell.swift
//  PAN689
//
//  Created by AgileTech on 12/23/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class CompleteCreateTeamCell: UITableViewCell {

    @IBOutlet weak var teamValueLabel: UILabel!
    @IBOutlet weak var currentBudgetValue: UILabel!
    @IBOutlet weak var completeButton: CustomButton!
    var presenter: CreateTeamInfoPresenter!
    weak var delegate: ConfirmLineupCellDelegate?
    override func awakeFromNib() {
            super.awakeFromNib()
            selectionStyle = .none
            //toggleSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
            enableCompleteTeam()
    }
        
    //    @objc func stateChanged(_ toggle: UISwitch) {
    //        NotificationCenter.default.post(name: NotificationName.updateField, object: nil, userInfo: [NotificationKey.showValue : toggle.isOn])
        
        func reloadView(_ budget: Double) {
            currentBudgetValue.text = budget.priceDisplay
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
