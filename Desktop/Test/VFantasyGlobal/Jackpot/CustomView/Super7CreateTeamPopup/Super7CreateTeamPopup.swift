//
//  GlobalLeagueCreateTeamPopup.swift
//  PAN689
//
//  Created by Quang Tran on 12/26/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

protocol Super7CreateTeamPopupDelegate {
    func onCreateTeam()
}

class Super7CreateTeamPopup: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var lblContent: UILabel!
    
    var delegate: Super7CreateTeamPopupDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
        
    fileprivate func initialize() {
        Bundle.sdkBundler()?.loadNibNamed("Super7CreateTeamPopup", owner: self, options: nil)
        guard let content = self.contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(content)
        
        self.lblContent.text = "You have not yet set up your team in the Jackpot ranking. Please create a team first.".localiz()
    }

    @IBAction func onCreate(_ sender: Any) {
        delegate?.onCreateTeam()
    }
    
}
