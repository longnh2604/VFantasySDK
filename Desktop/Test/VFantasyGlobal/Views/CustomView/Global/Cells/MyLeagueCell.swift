//
//  MyLeagueCell.swift
//  PAN689
//
//  Created by AgileTech on 12/10/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

protocol MyLeagueCellDelegate {
    func onRedeemCode()
    func onCreateLeague()
    func onDetailLeague(_ league: LeagueDatum)
}
class MyLeagueCell: UITableViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var btnCreate: UIButton!
    
    var delegate: MyLeagueCellDelegate?
    var leagues: [LeagueDatum] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnJoin.backgroundColor = UIColor(hex: 0xFEE6D7)
        btnJoin.setTitle("join_league".localiz().uppercased(), for: .normal)
        btnJoin.titleLabel?.font = UIFont(name: FontName.bold, size: 14)
        btnJoin.setTitleColor(UIColor(hex: 0xF87221), for: .normal)

        btnCreate.backgroundColor = UIColor(hex: 0xFEE6D7)
        btnCreate.setTitle("Create League".localiz().uppercased(), for: .normal)
        btnCreate.titleLabel?.font = UIFont(name: FontName.bold, size: 14)
        btnCreate.setTitleColor(UIColor(hex: 0xF87221), for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "MyLeagueDetailCell", bundle: Bundle.sdkBundler())
        tableView.register(nib, forCellReuseIdentifier: "MyLeagueDetailCell")
    }
    func setupCell(leagues: [LeagueDatum]) {
        self.leagues.removeAll()
        self.tableViewHeightLayout.constant = CGFloat(leagues.count) * MyLeagueDetailCell.heightCell
        self.layoutIfNeeded()
        self.leagues.append(contentsOf: leagues)
        self.tableView.reloadData()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func onRedeemCode(_ sender: Any) {
        delegate?.onRedeemCode()
    }
    
    @IBAction func onCreateLeague(_ sender: Any) {
        delegate?.onCreateLeague()
    }
    
    static func statusImage(_ status: Int) -> UIImage? {
        if status == 0 {
            return VFantasyCommon.image(named: "ic_static_trend")
        }
        if status > 0 {
            return VFantasyCommon.image(named: "ic_up_trend")
        }
        return VFantasyCommon.image(named: "ic_down_trend")
    }
    
}

extension MyLeagueCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MyLeagueDetailCell.heightCell
    }
}

extension MyLeagueCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyLeagueDetailCell", for: indexPath) as? MyLeagueDetailCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let league = leagues[indexPath.row]
        cell.leagueNameLabel.text = league.name
        cell.rankLabel.text = league.rankDisplay
        let status = league.rankStatus ?? 0
        cell.status.changeHeight(to: 16)
        cell.status.image = MyLeagueCell.statusImage(status)
        cell.ivIcon.setPlayerAvatar(with: league.logo)
        cell.lineView.isHidden = indexPath.row == leagues.count - 1
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.onDetailLeague(leagues[indexPath.row])
    }
}
