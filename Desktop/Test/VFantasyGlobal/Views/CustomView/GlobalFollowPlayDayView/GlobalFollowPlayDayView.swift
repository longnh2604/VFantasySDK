//
//  GlobalFollowPlayDayView.swift
//  PAN689
//
//  Created by Quang Tran on 7/22/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit
import SwiftDate

class GlobalFollowPlayDayView: UIView {
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tbvList: UITableView!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lblMatchWeek: UILabel!
    @IBOutlet weak var mainViewToBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var tbvListToHeightLayout: NSLayoutConstraint!
    
    var group: [MatchGroup] = [] {
        didSet {
            if let first = group.first?.value.first, let round = first.round {
                lblMatchWeek.text = "Matchweek \(round)".uppercased()
                if VFantasyManager.shared.isVietnamese() {
                    lblMatchWeek.text = "Vòng đấu \(round)"
                }
            } else {
                lblMatchWeek.text = nil
            }
            
            self.tbvList.reloadData()
            self.tbvList.setNeedsLayout()
            self.tbvList.layoutIfNeeded()
            var height = self.tbvList.contentSize.height
            if height > UIScreen.SCREEN_HEIGHT*0.7 {
                height = UIScreen.SCREEN_HEIGHT*0.7
            }
            self.tbvListToHeightLayout.constant = height
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mainView.roundCorners([.topLeft, .topRight], 16.0)
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
        contentView?.frame = self.bounds
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        setup()
    }
    
    func setup() {
        self.blurView.alpha = 0.0
        self.mainViewToBottomLayout.constant = -UIScreen.SCREEN_HEIGHT
        self.ivIcon.round(corners: .allCorners, radius: 20.0, borderColor: UIColor(hex: 0xECECEC), borderWidth: 1.0)
        
        self.tbvList.register(FollowPlayDayCell.nib, forCellReuseIdentifier: FollowPlayDayCell.identifier)
        self.tbvList.register(HeaderFollowPlayDayCell.nib, forHeaderFooterViewReuseIdentifier: HeaderFollowPlayDayCell.identifier)
        
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.hide()
    }
    
    func show(root: UIView,  animated: Bool = true) {
        //update data
        root.addSubview(self)
        self.mainViewToBottomLayout.constant = 0.0
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.blurView.alpha = 0.8
            self.layoutIfNeeded()
        }
    }
    
    func hide(_ animated: Bool = true, _ pushCompletion: Bool = true) {
        self.mainViewToBottomLayout.constant = -UIScreen.SCREEN_HEIGHT
        UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
            self.blurView.alpha = 0.0
            self.layoutIfNeeded()
        }) { (success) in
            self.removeFromSuperview()
        }
    }
    
    func getTimeline(from dateString: String) -> String? {
        guard let date = "\(dateString)".toDate(fromFormat: DateFormat.kyyyyMMdd_1) else { return dateString }
        if dateString == Date().toString(DateFormat.kyyyyMMdd_1) {
            return "Today".localiz()
        }
        return date.toString(FormatDate.format_9)
    }
}

extension GlobalFollowPlayDayView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return group.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let matches = self.group[section].value
        var items = matches.count/2
        if matches.count % 2 != 0 {
            items += 1
        }
        return items
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowPlayDayCell.identifier, for: indexPath) as? FollowPlayDayCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        let matches = self.group[indexPath.section].value
        var values = [RealMatch]()
        if indexPath.row * 2 < matches.count {
            values.append(matches[indexPath.row * 2])
        }
        if indexPath.row * 2 + 1 < matches.count {
            values.append(matches[indexPath.row * 2 + 1])
        }
        cell.configData(values)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFollowPlayDayCell.identifier) as? HeaderFollowPlayDayCell else {
            return UIView()
        }
        let group = self.group[section]
        headerView.lblTitle.text = getTimeline(from: group.key)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FollowPlayDayCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HeaderFollowPlayDayCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
}
