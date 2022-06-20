//
//  GlobalBankPlayerCell.swift
//  PAN689
//
//  Created by Quang Tran on 7/14/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class GlobalBankPlayerCell: UITableViewCell {

    @IBOutlet weak var lblPlayer: UILabel!
    @IBOutlet weak var lblPOS: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblWeekScore: UILabel!
    @IBOutlet weak var lblTotalScore: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var lineViewHeightLayout: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configTitle() {
        updateContent(in: lblPlayer, value: "player".localiz())
        updateContent(in: lblPOS, value: "POS".localiz())
        updateContent(in: lblValue, value: "Value".localiz())
        updateContent(in: lblWeekScore, value: "Week\nScore".localiz())
        updateContent(in: lblTotalScore, value: "Total\nScore".localiz())
        lineViewHeightLayout.constant = 2.0
        setNeedsLayout()
    }
    
    func updateData(_ player: Player) {
        self.updateData(player.getNameDisplay(.shortName) ?? "",
                        player.realClubName(),
                        player.positionShortName().uppercased(),
                        VFantasyCommon.budgetDisplay(player.transferValue),
                        player.gameweek_point ?? 0,
                        player.season_point ?? 0)
    }
    
    private func updateData(_ playerName: String, _ club: String, _ pos: String, _ value: String, _ weekScore: Int, _ totalScore: Int) {
        updateContent(in: lblPlayer, value: playerName, suffix: club)
        updateContent(in: lblPOS, value: pos, primaryColor: UIColor(hex: 0x2C3653), primaryFont: UIFont(name: FontName.regular, size: 14)!)
        updateContent(in: lblValue, value: value, primaryColor: UIColor(hex: 0x2C3653), primaryFont: UIFont(name: FontName.regular, size: 14)!)
        updateContent(in: lblWeekScore, value: "\(VFantasyCommon.formatPoint(weekScore))", primaryColor: UIColor(hex: 0x2C3653), primaryFont: UIFont(name: FontName.regular, size: 14)!)
        updateContent(in: lblTotalScore, value: "\(VFantasyCommon.formatPoint(totalScore))")
        lineViewHeightLayout.constant = 1.0
        setNeedsLayout()
    }
    
    private func updateContent(in label: UILabel,
                               value: String,
                               suffix: String? = nil,
                               primaryColor: UIColor = UIColor(hex: 0x1E2539),
                               primaryFont: UIFont = UIFont(name: FontName.bold, size: 14)!,
                               secondaryColor: UIColor = UIColor(hex: 0x898995),
                               secondaryFont: UIFont = UIFont(name: FontName.regular, size: 12)!) {
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: primaryColor, NSAttributedString.Key.font: primaryFont as Any]
        let suffixAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: secondaryColor, NSAttributedString.Key.font: secondaryFont as Any]
        let attributedString = NSMutableAttributedString(string: "\(value)", attributes: attributes)
        if let suffix = suffix, !suffix.isEmpty {
            attributedString.append(NSAttributedString(string: "\n\(suffix)", attributes: suffixAttributes))
        }
        label.attributedText = attributedString
    }
    
    static var identifierCell: String {
        return "GlobalBankPlayerCell"
    }
    
    static var heightCell: CGFloat {
        return 46.0
    }
    
}
