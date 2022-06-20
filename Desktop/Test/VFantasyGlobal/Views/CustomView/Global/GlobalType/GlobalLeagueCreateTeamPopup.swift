//
//  GlobalLeagueCreateTeamPopup.swift
//  PAN689
//
//  Created by Quang Tran on 12/26/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

protocol GlobalLeagueCreateTeamPopupDelegate {
    func onCreateTeam()
}

class GlobalLeagueCreateTeamPopup: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var contentImageView: UIImageView!
    var delegate: GlobalLeagueCreateTeamPopupDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
        
    fileprivate func initialize() {
        let _ = Bundle.sdkBundler()?.loadNibNamed("GlobalLeagueCreateTeamPopup", owner: self, options: nil)
        guard let content = self.contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(content)
        
        if #available(iOS 11.0, *) {
            contentImageView.clipsToBounds = true
            contentImageView.layer.cornerRadius = 40
            contentImageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
    }

    @IBAction func onCreate(_ sender: Any) {
        delegate?.onCreateTeam()
    }
    
}
