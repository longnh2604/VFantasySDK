//
//  GlobalHeaderInfoView.swift
//  PAN689
//
//  Created by Quang Tran on 7/13/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol GlobalHeaderInfoViewDelegate {
    func onSelectedWeekScore(_ sender: GlobalHeaderInfoView)
    func onSelectedTotalScore(_ sender: GlobalHeaderInfoView)
    func onSelectedRanking(_ sender: GlobalHeaderInfoView)
    func onSelectedBudget(_ sender: GlobalHeaderInfoView)
}

class GlobalHeaderInfoView: UIView {

    @IBOutlet weak var lblWeekScore: UILabel!
    @IBOutlet weak var lblTotalScore: UILabel!
    @IBOutlet weak var lblRanking: UILabel!
    @IBOutlet weak var lblBudget: UILabel!
    @IBOutlet weak var lblHeaderToTopLayout: NSLayoutConstraint!

    var delegate: GlobalHeaderInfoViewDelegate?
    
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
        contentView?.frame = self.bounds
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        setup()
    }
    
    func setup() {
        self.lblHeaderToTopLayout.constant = KEY_WINDOW_SAFE_AREA_INSETS.top + 10.0
        self.resetData()
    }
    
    func resetData() {
        self.updateContent(in: lblWeekScore, "0")
        self.updateContent(in: lblTotalScore, "0")
        self.updateContent(in: lblRanking, "0")
        self.updateContent(in: lblBudget, "0", "m")
    }
    
    func updateData(_ myteam: MyTeamData?) {
        self.resetData()
        guard let myteam = myteam else { return }
        self.updateContent(in: lblWeekScore, "\(myteam.currentGW?.point ?? 0)")
        self.updateContent(in: lblTotalScore, "\(myteam.totalPoint ?? 0)")
        self.updateContent(in: lblRanking, "\(myteam.globalRanking?.global?.rank ?? 0)")
        self.updateContent(in: lblBudget, VFantasyCommon.budgetDisplay(myteam.currentBudget, suffixMillion: "", suffixThousands: ""), (myteam.currentBudget ?? 0) >= 1000000 ? "m" : "k")
    }
    
    private func updateContent(in label: UILabel, _ value: String, _ suffix: String? = nil) {
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: FontName.bold, size: 18) as Any]
        let suffixAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: FontName.regular, size: 12) as Any]
        let attributedString = NSMutableAttributedString(string: "\(value)", attributes: attributes)
        if let suffix = suffix, !suffix.isEmpty {
            attributedString.append(NSAttributedString(string: " \(suffix)", attributes: suffixAttributes))
        }
        label.attributedText = attributedString
    }
    
    @IBAction func onWeekScore(_ sender: Any) {
        self.delegate?.onSelectedWeekScore(self)
    }
    
    @IBAction func onTotalScore(_ sender: Any) {
        self.delegate?.onSelectedTotalScore(self)
    }
    
    @IBAction func onRanking(_ sender: Any) {
        self.delegate?.onSelectedRanking(self)
    }
    
    @IBAction func onBudget(_ sender: Any) {
        self.delegate?.onSelectedBudget(self)
    }
    
}
