//
//  PlayersStatsAllController.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class PlayersStatsAllController: UIViewController {

    @IBOutlet weak var navigationBar: GlobaNavigationBar!
    @IBOutlet weak var tbvList: UITableView!
    @IBOutlet weak var searchBar: SearchBar!
    
    var myTeam: MyTeamData?
    var type: PlayerStatsType = .goals
    var initinialPlayers: [Player] = []
    
    private var presenter = NewGlobalPresenter(service: GlobalServices())
    private var players: [Player] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initHeaderBar()
        self.setupTableView()
        self.setupPresenter()
        self.loadPlayersStats()
    }
    
    func initHeaderBar() {
        self.view.backgroundColor = UIColor(hex: 0x10003F)
        navigationBar.headerTitle = self.type.title.uppercased()
        navigationBar.delegate = self
        searchBar.delegate = self
        searchBar.tfSearch.placeholder(text: "Search name".localiz(), color: .white)
        searchBar.layer.cornerRadius = 16.0
        searchBar.layer.masksToBounds = true
    }
    
    func setupTableView() {
        self.tbvList.register(UINib(nibName: GlobalPlayerStatCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: GlobalPlayerStatCell.identifierCell)
    }
    
    private func setupPresenter() {
        presenter.attachView(view: self)
        presenter.myTeam = self.myTeam
        presenter.autoNextPageWhenViewAllStats()
    }
    
    private func loadPlayersStats() {
        self.players.append(contentsOf: self.initinialPlayers)
        self.tbvList.reloadData()
    }

    override func loadMore() {
        self.presenter.getPlayersStats(from: self.type, showHUD: true, isViewAll: true)
    }
}

extension PlayersStatsAllController: SearchBarDelegate {
    func onSearch(_ key: String) {
        self.players.removeAll()
        self.presenter.resetViewAllStats(key)
        self.presenter.getPlayersStats(from: self.type, showHUD: true, isViewAll: true)
    }
}

extension PlayersStatsAllController: GlobaNavigationBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationBar) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PlayersStatsAllController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GlobalPlayerStatCell.identifierCell) as? GlobalPlayerStatCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.updateData(players[indexPath.row])
        cell.contentToBottomLayout.constant = indexPath.row == players.count - 1 ? 0.0 : 1.0
        if indexPath.row == 0 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.topLeft, .topRight], 16.0)
        } else if indexPath.row == players.count - 1 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.bottomLeft, .bottomRight], 16.0)
        } else {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, .allCorners, 0.0)
        }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
}

extension PlayersStatsAllController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GlobalPlayerStatCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = self.players[indexPath.row]
        if let id = player.id {
            if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                controller.hidesBottomBarWhenPushed = true
                controller.setupPlayer(id)
                controller.initBackView(title: "Players Stats".localiz())
                controller.setPlayerListType(.playerPool)
                controller.setupTeamId(presenter.teamId)
                controller.setupTypePlayerStatistic(.statistic)
                controller.setupMyTeam(presenter.myTeam)
                controller.setupIsPlayerStatsGlobal(true)
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}


extension PlayersStatsAllController: NewGlobalView {
    func reloadTeamOTWeek(_ players: [Player]) {
        
    }
    
    func reloadStatsPlayers(_ type: PlayerStatsType, _ data: [Player]) {
        self.players.append(contentsOf: data)
        self.tbvList.reloadData()
    }
    
    func reloadHeader(_ isCompleted: Bool) {
    }
    
    func reloadPitchTeam() {
    }
    
    func reloadBankPlayers() {
    }
    
    func gotoFollowPlayDay() {
    }
    
    func startLoading() {
        startAnimation()
    }
    
    func finishLoading() {
        stopAnimation()
        
    }
    
    func alertMessage(_ message: String) {
        stopAnimation()
        showAlert(message: message)
    }
}

extension PlayersStatsAllController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
