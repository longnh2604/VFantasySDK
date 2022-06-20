//
//  GlobalPlayerStatCell.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol Super7PlayerMatchCellDelegate {
    func onAction(sender: Super7PlayerMatchCell)
}

class Super7PlayerMatchCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTeamOne: UILabel!
    @IBOutlet weak var lblTeamTwo: UILabel!
    @IBOutlet weak var lblScoreTeamOne: UILabel!
    @IBOutlet weak var lblScoreTeamTwo: UILabel!
    @IBOutlet weak var lblSelect: UILabel!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var ivStar: UIImageView!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var contentToBottomLayout: NSLayoutConstraint!
    
    var delegate: Super7PlayerMatchCellDelegate?
    var player: Player? {
        didSet {
            if player == nil && isEndedDeadline {
                lblSelect.isHidden = true
                lblScore.isHidden = true
                ivAvatar.isHidden = true
            } else {
                lblSelect.isHidden = false
                lblScore.isHidden = !isEndedDeadline
                ivAvatar.isHidden = false
            }
            self.playerName = player?.getNameDisplay() ?? ""
            if player == nil {
                self.ivAvatar.image = VFantasyCommon.image(named: "ic_super7_avatar_default")
            } else {
                self.ivAvatar.setPlayerAvatar(with: player?.photo)
            }
            self.lblScore.text = "\(player?.point ?? 0)"
        }
    }
    
    var playerName: String = "" {
        didSet {
            lblSelect.text = playerName.isEmpty ? "Select player".localiz() : playerName
            lblSelect.textColor = UIColor(hex: playerName.isEmpty ? 0xF87221 : 0x1E2539)
        }
    }
    
    var isEndedDeadline: Bool = false
    
    var isStar: Bool = false {
        didSet {
            ivStar.isHidden = !isStar
        }
    }
    
    func configData(_ match: Super7Match, _ isEndedDeadline: Bool) {
        let noValue = "-"
        let format = "EEE, dd MMM yyyy - HH:mm"

        if let delay = match.delayStartAt {
            lblTime.text = delay.toDate?.toString(format)
        } else {
            lblTime.text = match.startAt?.toDate?.toString(format)
        }
        
        lblTeamOne.text = match.team1
        lblTeamTwo.text = match.team2

        if let result1 = match.team1_Result {
            if result1 == -1 {
                lblScoreTeamOne.text = noValue
            } else {
                lblScoreTeamOne.text = String(result1)
            }
        } else {
            lblScoreTeamOne.text = noValue
        }
        if let result2 = match.team2_Result {
            if result2 == -1 {
                lblScoreTeamTwo.text = noValue
            } else {
                lblScoreTeamTwo.text = String(result2)
            }
        } else {
            lblScoreTeamTwo.text = noValue
        }
        self.isEndedDeadline = isEndedDeadline
        self.player = match.selected_player
        self.isStar = match.isStar
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isEndedDeadline = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onClick(_ sender: Any) {
        
    }
    
    static var identifierCell: String {
        return "Super7PlayerMatchCell"
    }
    
    static var heightCell: CGFloat {
        return 102.0
    }
}
