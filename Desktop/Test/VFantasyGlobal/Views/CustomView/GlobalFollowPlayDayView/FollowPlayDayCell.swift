//
//  FollowPlayDayCell.swift
//  PAN689
//
//  Created by Quang Tran on 7/22/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class FollowPlayDayCell: UITableViewCell {

    @IBOutlet weak var matchOneView: UIView!
    @IBOutlet weak var lblTimeMatchOne: UILabel!
    @IBOutlet weak var lblTeamOneMatchOne: UILabel!
    @IBOutlet weak var lblTeamTwoMatchOne: UILabel!
    @IBOutlet weak var lblScoreTeamOneMatchOne: UILabel!
    @IBOutlet weak var lblScoreTeamTwoMatchOne: UILabel!
    
    @IBOutlet weak var matchTwoView: UIView!
    @IBOutlet weak var lblTimeMatchTwo: UILabel!
    @IBOutlet weak var lblTeamOneMatchTwo: UILabel!
    @IBOutlet weak var lblTeamTwoMatchTwo: UILabel!
    @IBOutlet weak var lblScoreTeamOneMatchTwo: UILabel!
    @IBOutlet weak var lblScoreTeamTwoMatchTwo: UILabel!

    private let noResultValue = -1
    
    func configData(_ matches: [RealMatch]) {
        matchOneView.isHidden = true
        matchTwoView.isHidden = true
        if let first = matches.first {
            matchOneView.isHidden = false
            self.updateData(first, true)
        }
        if let last = matches.last, matches.count > 1 {
            matchTwoView.isHidden = false
            self.updateData(last, false)
        }
    }
    
    private func updateData(_ match: RealMatch, _ isFirst: Bool) {
        let noValue = "-"
        let timeLabel: UILabel = isFirst ? lblTimeMatchOne : lblTimeMatchTwo
        if let delay = match.delayStartAt {
            timeLabel.text = delay.hourMinute()
        } else {
            timeLabel.text = match.startAt?.hourMinute()
        }
        
        let teamOne: UILabel = isFirst ? lblTeamOneMatchOne : lblTeamOneMatchTwo
        let teamTwo: UILabel = isFirst ? lblTeamTwoMatchOne : lblTeamTwoMatchTwo
        teamOne.text = match.team1
        teamTwo.text = match.team2
        
        let scoreTeamOne: UILabel = isFirst ? lblScoreTeamOneMatchOne : lblScoreTeamOneMatchTwo
        let scoreTeamTwo: UILabel = isFirst ? lblScoreTeamTwoMatchOne : lblScoreTeamTwoMatchTwo

        if let result1 = match.team1_Result {
            if result1 == noResultValue {
                scoreTeamOne.text = noValue
            } else {
                scoreTeamOne.text = String(result1)
            }
        } else {
            scoreTeamOne.text = noValue
        }
        if let result2 = match.team2_Result {
            if result2 == noResultValue {
                scoreTeamTwo.text = noValue
            } else {
                scoreTeamTwo.text = String(result2)
            }
        } else {
            scoreTeamTwo.text = noValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var nib: UINib {
        return UINib.init(nibName: self.className, bundle: Bundle.sdkBundler())
    }
    
    static var identifier: String {
        return self.className
    }
    
    static var heightCell: CGFloat  {
        return 98.0
    }
}
