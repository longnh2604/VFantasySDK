//
//  GlobalRankingViewController.swift
//  PAN689
//
//  Created by Quang Tran on 1/7/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit

enum RankingSection: Int {
    case header
    case user
}

class GlobalRankingViewController: UIViewController {

    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var teamRankLabel: UILabel!
    @IBOutlet weak var teamRankImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var totalPointLabel: UILabel!
    
    var presenter = GlobalRankingPresenter()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBackView(title: "Global league".localiz())
        presenter.attachView(view: self)
        presenter.getLeagueRanking()
    }
    
    func updateData() {
        updateTeamRankUI(presenter.teamData?.rank ?? 0)
        teamNameLabel.text = presenter.teamData?.name
        totalPointLabel.text = presenter.teamData?.name != nil ? String(presenter.teamData?.totalPoint ?? 0) : ""
    }
    
    private func updateTeamRankUI(_ index: Int) {
        teamRankLabel.text = presenter.teamData?.name != nil ? String(index) : ""
        teamRankImageView.isHidden = presenter.teamData?.name == nil || index > 3
        if index == 1 {
            teamRankImageView.image = VFantasyCommon.image(named: "ic_one")
        }
        if index == 2 {
            teamRankImageView.image = VFantasyCommon.image(named: "ic_two")
        }
        if index == 3 {
            teamRankImageView.image = VFantasyCommon.image(named: "ic_three")
        }
    }
    
    private func getTitle() -> String {
        switch presenter.rankingType {
        case .city:
          return "city_ranking".localiz() //presenter.myTeam?.globalRanking?.city?.name ?? ""
        case .country:
          return "country_ranking".localiz() //presenter.myTeam?.globalRanking?.country?.name ?? ""
        case .club:
          return "club_ranking".localiz() //presenter.myTeam?.globalRanking?.club?.name ?? ""
        default:
            return presenter.myTeam?.globalRanking?.global?.name ?? ""
        }
    }
    
    override func loadMore() {
        super.loadMore()
        presenter.loadMoreFriends()
    }
}

// MARK: - UITableViewDataSource

extension GlobalRankingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == RankingSection.header.rawValue {
            return 1
        }

        return presenter.users.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = RankingViewHeader.instanceFromNib() as? RankingViewHeader
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == RankingSection.header.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalRankingHeaderCell", for: indexPath) as! GlobalRankingHeaderCell
            cell.setTitle(getTitle())
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalRankingCell", for: indexPath) as! GlobalRankingCell
        let color: UIColor = indexPath.row % 2 == 0 ? UIColor(hexString: "#F6F6F6") : .white
        cell.updateData(data: presenter.users[indexPath.row], index: indexPath.row, color: color)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = presenter.users[indexPath.row]
        let myTeam = MyTeamData(id: user.id, createdAt: nil, updatedAt: nil, currentBudget: nil, description: nil, formation: nil, league: nil, isCompleted: nil, isOwner: user.isOwner, logo: nil, name: user.name, pickOrder: nil, rank: user.rank, totalPlayers: user.totalPlayers, user: user.user, totalPoint: user.totalPoint, globalRanking: nil, currentGW: presenter.myTeam?.currentGW)
        VFantasyCommon.gotoPointTeam(myTeam, from: self)
    }
}

// MARK: - UITableViewDelegate

extension GlobalRankingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == RankingSection.header.rawValue {
            return 0
        }
        return 26
    }
}

// MARK: - RankingGlobalView

extension GlobalRankingViewController: RankingGlobalView {
    
    func reloadView() {
        updateData()
        self.tableView.reloadData()
    }
    
    func startLoading() {
        self.startAnimation()
    }
    
    func finishLoading() {
        self.stopAnimation()
    }
    
    func alertMessage(_ message: String) {
        self.showAlert(message: message)
    }
}

extension GlobalRankingViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
