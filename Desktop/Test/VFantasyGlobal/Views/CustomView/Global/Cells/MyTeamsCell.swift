//
//  MyLeagueCell.swift
//  PAN689
//
//  Created by AgileTech on 12/10/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

protocol MyTeamsCellDelegate {
    func onCreateNewTeam()
    func onChooseTeam(_ teamId: Int)
}

class MyTeamsCell: UITableViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var btnCreateTeam: UIButton!
    
    var allTeams: [MyTeamData] = []
    var delegate: MyTeamsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnCreateTeam.backgroundColor = UIColor(hex: 0xFEE6D7)
        btnCreateTeam.setTitle("Create team".localiz().uppercased(), for: .normal)
        btnCreateTeam.titleLabel?.font = UIFont(name: FontName.bold, size: 14)
        btnCreateTeam.setTitleColor(UIColor(hex: 0xF87221), for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "MyTeamDetailCell", bundle: Bundle.sdkBundler())
        tableView.register(nib, forCellReuseIdentifier: "MyTeamDetailCell")
    }
    
    func setupCell(teams: [MyTeamData]) {
        self.allTeams.removeAll()
        self.allTeams.append(contentsOf: teams)
        self.tableViewHeightLayout.constant = CGFloat(teams.count) * MyTeamDetailCell.heightCell
        self.layoutIfNeeded()
        self.tableView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func onCreate(_ sender: Any) {
        self.delegate?.onCreateNewTeam()
    }
}

extension MyTeamsCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MyTeamDetailCell.heightCell
    }
}

extension MyTeamsCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyTeamDetailCell", for: indexPath) as? MyTeamDetailCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.config(allTeams[indexPath.row])
        cell.lineView.isHidden = indexPath.row == allTeams.count - 1
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.onChooseTeam(allTeams[indexPath.row].id ?? 0)
    }
}
