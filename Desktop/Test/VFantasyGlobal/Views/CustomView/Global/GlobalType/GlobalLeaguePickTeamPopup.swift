//
//  GlobalLeagueCreateTeamPopup.swift
//  PAN689
//
//  Created by Quang Tran on 12/26/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

protocol GlobalLeaguePickTeamPopupDelegate {
    func onPickTeam()
}

class GlobalLeaguePickTeamPopup: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var lblNote: UILabel!
    @IBOutlet var btnAction: UIButton!
    @IBOutlet var contentImageView: UIImageView!
    var delegate: GlobalLeaguePickTeamPopupDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        let _ = Bundle.sdkBundler()?.loadNibNamed("GlobalLeaguePickTeamPopup", owner: self, options: nil)
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
    
    func setup(_ data: MyTeamData?) {
        
        if let data = data {
            lblNote.text = "Bạn chưa có đủ cầu thủ. Vui lòng chọn thêm 18 cầu thủ với ngân sách \(VFantasyCommon.budgetDisplay(data.currentBudget, suffixMillion: "mio_suffix".localiz()))"
        }
        
    }
    
    @IBAction func onCreate(_ sender: Any) {
        delegate?.onPickTeam()
    }
    
}
