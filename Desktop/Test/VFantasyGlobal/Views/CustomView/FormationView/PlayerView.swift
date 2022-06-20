//
//  PlayerView.swift
//  LetsPlay360
//
//  Created by Quang Tran on 11/13/19.
//  Copyright © 2019 quangtran. All rights reserved.
//

import UIKit
import SwiftDate

protocol PlayerViewDelegate {
    func onSelectPlayer(_ sender: PlayerView)
}

class PlayerView: UIView {
    
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var ivMark: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewLock: UIView!
    @IBOutlet weak var lblLock: UILabel!
    @IBOutlet weak var ivLock: UIImageView!
    @IBOutlet weak var viewValue: UIView!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var viewInprogress: UIView!
    @IBOutlet weak var lblClub: UILabel!
    @IBOutlet weak var lblNameToTopLayout: NSLayoutConstraint!
    
    //Positions
    @IBOutlet weak var mainPosition: PlayerPositionView!
    @IBOutlet weak var centerPosition: UIView!
    @IBOutlet weak var leftPosition: PlayerPositionView!
    @IBOutlet weak var rightPosition: PlayerPositionView!
    @IBOutlet weak var injuredLabel: UILabel!
    
    var player: Player?
    var delegate: PlayerViewDelegate?
    var isBottom: Bool = false
    var isPoints: Bool = false
    var position: PositionPlayer! {
        didSet {
            ivMark.image = position.type.iconAdd
            ivAvatar.layer.borderWidth = 3
            ivAvatar.layer.borderColor = PlayerPositionView.positionColor(position.type.position)?.cgColor
        }
    }
    
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
        injuredLabel.injured()
        injuredLabel.isHidden = true
    }
    
    @IBAction func onSelect(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.onSelectPlayer(self)
        }
    }
    
    func updateUIDark() {
        isBottom = true
        let color: UIColor = UIColor(hexString: "4A4A4A")
        lblNameToTopLayout.constant = 20
        lblName.textColor = color
        lblLock.textColor = color
        lblValue.textColor = color
        lblClub.textColor = color
        viewValue.backgroundColor = .clear
        viewInprogress.backgroundColor = .clear
        ivLock.image = VFantasyCommon.image(named: "ic_lock_gray")
        ivAvatar.layer.borderColor = PlayerPositionView.positionColor(-1)?.cgColor
        ivAvatar.layer.borderColor = UIColor(hexString: "EDEAF6").cgColor
        ivMark.isHidden = true
    }
    
    func update(_ player: Player, _ pitchData: PitchTeamData?) {
        self.player = player
        lblName.text = player.getNameDisplay(.shortName)
        ivMark.isHidden = true
        ivAvatar.sd_setImage(with: URL(string: player.photo ?? ""), placeholderImage: VFantasyCommon.image(named: "ic_user_default"), options: .refreshCached) { (_, _ , _, _) in
        }
        //Time: Player co transfer deadline. (TD). If TD > Date() -> Hien thi so gio con lai
        //Player co Start At. (ST). If ST < Date() -> Hien thi point.
        //Lock: If TD <= Date.
        viewLock.isHidden = true
        viewValue.isHidden = true
        viewInprogress.isHidden = true
        centerPosition.isHidden = true
        mainPosition.isHidden = true
        injuredLabel.isHidden = !(player.isInjured ?? false)
        
        if isBottom {
            injuredLabel.isHidden = true
            if let minorPosition = player.minorPosition, (minorPosition <= 3 && minorPosition >= 0) {
                centerPosition.isHidden = false
                leftPosition.update(player.mainPosition)
                rightPosition.update(minorPosition)
            } else {
                mainPosition.isHidden = false
                mainPosition.update(player.mainPosition)
            }
        }
        
        //Su dung man points
        if let startAt = player.startAt, let startDate = startAt.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss), isPoints {
            if startDate < Date() {
                viewValue.isHidden = false
                viewLock.isHidden = true
                viewInprogress.isHidden = true
                if let point = player.point {
                    lblValue.text = "\(point)"
                } else {
                    lblValue.text = "-"
                }
                return
            }
        }
        
        if isPoints {
            lblLock.text = player.realClubName()
        } else {
            lblLock.text = player.realClubNext()
        }
        
        //      if let currentRound = pitchData?.currentRound, let startAt = currentRound.startAt?.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss), let endAt = currentRound.endAt?.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss), startAt < Date(), Date() < endAt {
        //        //Hien thi lock
        //        viewLock.isHidden = false
        //      } else {
        //Su dung man line up
        if let transferDeadline = player.transferDeadline, let deadlineDate = transferDeadline.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss) {
            if deadlineDate <= Date() {
                //Hien thi lock
                viewLock.isHidden = false
            } else {
                //Hien thi view date
                viewInprogress.isHidden = false
                updateTimeLeft(player, pitchData)
            }
        }
        //      }
    }
    
    private func updateTimeLeft(_ player: Player, _ pitchData: PitchTeamData?) {
        if let transferDeadline = player.transferDeadline, let deadlineDate = transferDeadline.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss) {
            if deadlineDate <= Date() {
                //Hien thi lock
                viewLock.isHidden = false
                viewInprogress.isHidden = true
            } else {
                viewInprogress.isHidden = false
                let delta = deadlineDate - Date()
                if isPoints {
                    lblClub.text = String(format: "%@ %@", player.realClubName(), getTimeLeftString(delta))
                } else {
                    lblClub.text = String(format: "%@ %@", player.realClubNext(), getTimeLeftString(delta))
                }
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
    
}
