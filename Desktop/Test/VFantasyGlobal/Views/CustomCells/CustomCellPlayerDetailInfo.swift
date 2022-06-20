//
//  CustomCellPlayerDetailInfo.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/20/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit
import SDWebImage

class CustomCellPlayerDetailInfo: UITableViewCell {
    weak var delegate: CustomCellPlayerDetailInfoDelegate?
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var clubNameLabel: UILabel!
    @IBOutlet weak var clubNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var minorPosition: UILabel!
    @IBOutlet weak var pointValue: UILabel!
    @IBOutlet weak var transferValue: UILabel!
    @IBOutlet weak var injured: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var dropdownView: DropdownSelectionView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var playerValueView: UIStackView!
    @IBOutlet weak var transferValueLabel: UILabel!
    @IBOutlet weak var pointValueLabel: UILabel!
    
    var playerListType = PlayerListType.playerList
    var myTeam: MyTeamData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        transferValueLabel.text = "transfer_value".localiz().uppercased()
        pointValueLabel.text = "points".localiz().uppercased()
        dropdownView.delegate = self
        dropdownView.titleLabel.textAlignment = .left
    }
    
    func reloadView(_ player: PlayerDetailModelView?) {
        name.text = player?.name ?? ""
        position.setPosition(player?.main_position ?? 0, full: true)
        if ((player?.minor_position) != nil) {
            minorPosition.isHidden = false
            minorPosition.setPosition(player?.minor_position ?? 0, full: true)
        } else {
            minorPosition.isHidden = true
        }
        
        pointValue.text = "\(player?.total_point ?? 0)"
        transferValue.text = Int(player?.transfer_value ?? 0).priceDisplay
        avatar.setPlayerAvatar(with: player?.photo)
        
        injured.isHidden = true
        if let injure = player?.isInjured {
            injured.isHidden = !injure
        }
        if playerListType == .playerPool {
            transferValue.textColor = UIColor(hexString: "#E07000")
        } else {
            
        }
      if let realClub = player?.realClub {
        clubNameHeightConstraint.constant = 24
        clubNameLabel.text = realClub.name ?? ""
      } else {
        clubNameHeightConstraint.constant = 0
        clubNameLabel.text = ""
      }
    }
    
    func hidePlayerValue() {
        playerValueView.isHidden = true
    }
    
    func dropdownData(_ data: [CheckBoxData]) {
        let isUppercased = playerListType == .playerPool
        dropdownView.setData(data, isUppercased: isUppercased)
        reloadPitchTeam(data)
    }
    
    func reloadPitchTeam(_ data: [CheckBoxData]) {
        guard playerListType == .playerPool else { return }
        dropdownView.titleLabel.textAlignment = .left
    }
    
    @IBAction func menuAction(_ sender: Any) {
        delegate?.didPickPlayer()
    }
    
    @IBAction func showInfo(_ sender: Any) {
        delegate?.showInfo()
    }
    
    func updateMenuButton(_ selected: Bool?) {
        if let selected = selected {
            if selected {
                setSelected()
            } else {
                setUnselected()
            }
        } else {
            setUnselected()
        }
    }
    
    private func setSelected() {
        menuButton.backgroundColor = #colorLiteral(red: 0.2274509804, green: 0.2431372549, blue: 0.7607843137, alpha: 1)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.setImage(VFantasyCommon.image(named: "ic_agreed.png"), for: .normal)
        menuButton.setTitle("picked".localiz(), for: .normal)
        menuButton.isUserInteractionEnabled = false
    }
    
    private func setUnselected() {
        menuButton.backgroundColor = .white
        menuButton.setTitleColor(#colorLiteral(red: 0.2274509804, green: 0.2431372549, blue: 0.7607843137, alpha: 1), for: .normal)
        menuButton.setImage(VFantasyCommon.image(named: "ic_checkmark_heavy_color.png"), for: .normal)
        menuButton.setTitle("pick".localiz(), for: .normal)
        menuButton.isUserInteractionEnabled = true
    }
}

extension CustomCellPlayerDetailInfo : DropdownSelectionViewDelegate {
    func didChangeSort(_ tag: Int) {
        if let data = dropdownView.selectedData {
//            if playerListType == .playerPool {
//                delegate?.didPickGameweek(data)
//            } else {
                delegate?.didClickSeason(data)
//            }
        }
    }
    
    func didTapDropdown(_ tag: Int) {
        dropdownView.showCheckBox()
    }
}
