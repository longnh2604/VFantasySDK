//
//  GlobalLeaguePointViewController.swift
//  PAN689
//
//  Created by Quang Tran on 1/10/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit

class GlobalLeaguePointViewController: UIViewController {
    
    @IBOutlet weak var tableView: CustomTableView!
    
    var presenter = GlobalLeaguePointPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        presenter.attachView(view: self)
        presenter.loadMorePoint()
    }
    
    override func loadMore() {
        super.loadMore()
        presenter.loadMorePoint()
    }
    
    func setLeagueId(_ id: Int) {
        presenter.leagueId = id
    }
    
    func setLeague(_ league: LeagueDatum?) {
        presenter.league = league
    }
}

// MARK: - UITableViewDataSource

extension GlobalLeaguePointViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.users.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = GlobalLeaguePointViewHeader.instanceFromNib() as? GlobalLeaguePointViewHeader
        header?.loadView(data: presenter.displays)
        header?.updateUI(isFiltered: !presenter.filterKey.isEmpty)
        header?.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalLeaguePointCell", for: indexPath) as! GlobalLeaguePointCell
        var color: UIColor = indexPath.row % 2 == 0 ? UIColor(hexString: "#F6F6F6") : .white
        let user = presenter.users[safe: indexPath.row]
        if presenter.teamData?.id == user?.id {
            color = UIColor(hexString: "#FAC453")
        }
        cell.updateData(data: user, index: indexPath.row, color: color)
        cell.loadData(displays: presenter.displays, model: user ?? LeaguePointModelView())
        return cell
    }
}

// MARK: - UITableViewDelegate

extension GlobalLeaguePointViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = presenter.users[safe: indexPath.row]
        let myTeam = MyTeamData(id: user?.id, createdAt: nil, updatedAt: nil, currentBudget: nil, description: nil, formation: nil, league: nil, isCompleted: nil, isOwner: nil, logo: nil, name: user?.name, pickOrder: nil, rank: nil, totalPlayers: nil, user: nil, totalPoint: nil, globalRanking: nil, currentGW: user?.gameweek)
        VFantasyCommon.gotoPointTeam(myTeam, from: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
}

// MARK: - GlobalLeaguePointView

extension GlobalLeaguePointViewController: GlobalLeaguePointView {
    
    func reloadView() {
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

// MARK: - GlobalLeaguePointViewHeaderDelegate

extension GlobalLeaguePointViewController: GlobalLeaguePointViewHeaderDelegate {
    
    func didFilter() {
        if let filterVC = instantiateViewController(storyboardName: .global, withIdentifier: "GlobalLeagueFilterPointViewController") as? GlobalLeagueFilterPointViewController {
            filterVC.delegate = self
            filterVC.setLeagueId(presenter.leagueId)
            filterVC.setLeague(presenter.league)
            filterVC.filterKey = presenter.filterKey
            navigationController?.pushViewController(filterVC, animated: true)
        }
    }
}

// MARK: - GlobalLeagueFilterPointViewControllerDelegate

extension GlobalLeaguePointViewController: GlobalLeagueFilterPointViewControllerDelegate {
    
    func onApplyFilter(key: String) {
        presenter.filterKey = key
        presenter.loadMorePoint()
    }
}

extension GlobalLeaguePointViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
