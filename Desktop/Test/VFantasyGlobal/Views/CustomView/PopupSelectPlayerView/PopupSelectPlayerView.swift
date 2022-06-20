//
//  PopupInfoMeStatusView.swift
//  zmooz
//
//  Created by Quang Tran on 8/29/19.
//  Copyright © 2019 quangtran. All rights reserved.
//

import UIKit

class PopupSelectPlayerView: UIView {
    
    @IBOutlet weak var blurView: GradientView!
    @IBOutlet weak var playersView: PlayersBottomView!
    @IBOutlet weak var contentToBottomLayout: NSLayoutConstraint!
    
    var players: [Player] = []
    var data: PitchTeamData?
    var pickCompletion: OnPickedPlayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.setup(.topLeftToRightBottom, [UIColor(hexString: "2324BF").cgColor, UIColor(hexString: "935BBD").cgColor])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = self.createFromNib()
        let contentView = views?.first as? UIView
        contentView?.backgroundColor = .clear
        contentView?.frame =  self.bounds
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        
        self.blurView.alpha = 0.0
        self.playersView.pickCompletion = { player in
            if let completion = self.pickCompletion {
                self.hide(true)
                completion(player)
            }
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        hide(true)
    }
    
    func show(in superView: UIView, _ animated: Bool) {
        playersView.updatePlayers(players, data)
        superView.addSubview(self)
        contentToBottomLayout.constant = 0.0
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.layoutIfNeeded()
            self.blurView.alpha = 0.9
        }
    }
    
    func hide(_ animated: Bool) {
        contentToBottomLayout.constant = -240
        UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
            self.blurView.alpha = 0.0
        }) { (success) in
            self.removeFromSuperview()
        }
    }
    
}

