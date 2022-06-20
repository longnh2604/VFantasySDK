//
//  TeamPlayerListHeaderView.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/15/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol TeamPlayerListHeaderViewDelegate: NSObjectProtocol {
    func onChangeSort()
}

class TeamPlayerListHeaderView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var sortIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTitleLabel: UILabel!
    
    weak var delegate: TeamPlayerListHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        let _ = Bundle.sdkBundler()?.loadNibNamed("TeamPlayerListHeaderView", owner: self, options: nil)
        guard let content = containerView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(content)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sortView.addAction {
            self.delegate?.onChangeSort()
        }
        titleLabel.text = "name_club_pos".localiz()
        valueTitleLabel.text = "value".localiz()
    }
    
    func hideSort() {
        sortView.isHidden = true
    }
    
    func updateSort(_ sortType: SortType) {
        self.sortIcon.image = sortType == .desc ? VFantasyCommon.image(named: "ic_sort_desc.png") : VFantasyCommon.image(named: "ic_sort_asc.png")
    }
}
