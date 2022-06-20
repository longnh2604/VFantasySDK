//
//  PlayerView.swift
//  LetsPlay360
//
//  Created by Quang Tran on 11/13/19.
//  Copyright © 2019 quangtran. All rights reserved.
//

import UIKit
import SwiftDate

protocol GlobalPlayerViewDelegate {
    func onSelectPlayer(_ sender: GlobalPlayerView)
}

class GlobalPlayerView: UIView {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblClub: UILabel!
    @IBOutlet weak var lblClubToCenterXLayout: NSLayoutConstraint!
    @IBOutlet weak var btnDetail: UIButton!
    @IBOutlet weak var ivLock: UIImageView!
    @IBOutlet weak var ivUniform: UIImageView!
    
    var isHiddenLock: Bool = true
    var delegate: GlobalPlayerViewDelegate?
    var position: PositionPlayer!
    var player: Player?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = self.createFromNib()
        if let containerView = views?.first as? UIView {
            containerView.backgroundColor = .clear
            containerView.frame = self.bounds
            addSubview(containerView)
        }
        lblName.text = nil
        lblClub.text = nil
        ivLock.isHidden = true
    }
    
    func update(_ player: Player, _ pitchData: PitchTeamData?, _ isLineup: Bool) {
        self.player = player
        lblName.text = player.getNameDisplay(.shortName)
        ivLock.isHidden = true
        lblClubToCenterXLayout.constant = 0.0
        isHiddenLock = true
        ivUniform.setPlayerAvatarRefreshCache(with: player.realClub?.jerseys, placeHolder: VFantasyCommon.image(named: "newGlobal_ic_uniform"))
        if isLineup {
            lblClub.text = player.realClubNext()
            if let transferDeadline = player.transferDeadline, let deadlineDate = transferDeadline.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss) {
                if deadlineDate <= Date() {
                    //Hien thi lock
                    ivLock.isHidden = false
                    lblClubToCenterXLayout.constant = -4.0
                    isHiddenLock = false
                    lblClub.text = "\(player.realClubName())|\(player.point ?? 0)"
                } else {
                    //Hien thi view date
                    updateTimeLeft(player, pitchData)
                }
            }
            
        } else {
            lblClub.text = "\(player.realClubName())|\(player.point ?? 0)"
        }
        self.setNeedsLayout()
    }
    
    private func updateTimeLeft(_ player: Player, _ pitchData: PitchTeamData?) {
        if let transferDeadline = player.transferDeadline, let deadlineDate = transferDeadline.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss) {
            if deadlineDate <= Date() {
                //Hien thi lock
                ivLock.isHidden = false
                lblClubToCenterXLayout.constant = -4.0
                isHiddenLock = false
                lblClub.text = "\(player.realClubName())|\(player.point ?? 0)"
            } else {
                let delta = deadlineDate - Date()
                lblClub.text = String(format: "%@ %@", player.realClubNext(), getTimeLeftString(delta))
            }
        }
    }
    
    private func getTimeLeftString(_ delta: DateComponents) -> String {
        if let days = delta.day, days > 0, let weeks = delta.weekOfYear {
            return String(format: "(%dd)", days + weeks * 7)
        }
        if let hours = delta.hour, hours > 0 {
            return String(format: "(%dhrs)", hours)
        }
        if let minutes = delta.minute, minutes > 0 {
            return String(format: "(%dmins)", minutes)
        }
        if let seconds = delta.second, seconds > 0 {
            return String(format: "(%dsec)", seconds)
        }
        return ""
    }
    
    @IBAction func onDetail(_ sender: Any) {
        self.delegate?.onSelectPlayer(self)
    }
}
