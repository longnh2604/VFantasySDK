//
//  PlayersStatsController.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

enum PlayerStatsType: String {
    case point, goals, assists, clean_sheet, duels_they_win, passes, shots, saves, yellow_cards, dribbles, turnovers, balls_recovered, fouls_committed
    
    var title: String {
        switch self {
        case .point:
            return "points".localiz()
        case .goals:
            return "goals".localiz()
        case .assists:
            return "assists".localiz()
        case .clean_sheet:
            return "clean_sheet".localiz()
        case .duels_they_win:
            return "duels_they_win".localiz()
        case .passes:
            return "passes".localiz()
        case .shots:
            return "shots".localiz()
        case .saves:
            return "saves".localiz()
        case .yellow_cards:
            return "yellow_cards".localiz()
        case .dribbles:
            return "dribbles".localiz()
        case .turnovers:
            return "red cards".localiz()
        case .balls_recovered:
            return "ball_recovered".localiz()
        case .fouls_committed:
            return "fouls_committed".localiz()
        }
    }
}

let MAXIMUM_PLAYERS_STATS_NUMBER            =   3

class PlayersStatsController: UIViewController {

    @IBOutlet weak var navigationBar: GlobaNavigationBar!
    @IBOutlet weak var pointsStatView: GlobalPlayerStatsView!
    @IBOutlet weak var goalsStatView: GlobalPlayerStatsView!
    @IBOutlet weak var assistsStatView: GlobalPlayerStatsView!
    @IBOutlet weak var cleanSheetStatView: GlobalPlayerStatsView!
    @IBOutlet weak var duelsWonStatView: GlobalPlayerStatsView!
    @IBOutlet weak var passesStatView: GlobalPlayerStatsView!
    @IBOutlet weak var shotsStatView: GlobalPlayerStatsView!
    @IBOutlet weak var savesStatView: GlobalPlayerStatsView!
    @IBOutlet weak var yellowCardsStatView: GlobalPlayerStatsView!
    @IBOutlet weak var dribblesStatView: GlobalPlayerStatsView!
    @IBOutlet weak var turnOversStatView: GlobalPlayerStatsView!
    @IBOutlet weak var ballRecoveredStatView: GlobalPlayerStatsView!
    @IBOutlet weak var foulsStatView: GlobalPlayerStatsView!
    
    var myTeam: MyTeamData?
    
    private var indexType: Int = 0
    private var types: [PlayerStatsType] = [.point, .goals, .assists, .clean_sheet, .duels_they_win, .passes, .shots, .saves, .yellow_cards, .dribbles, .turnovers, .balls_recovered, .fouls_committed]
    private var presenter = NewGlobalPresenter(service: GlobalServices())
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initHeaderBar()
        self.setupPresenter()
        self.loadPlayersStats()
    }
    
    func initHeaderBar() {
        navigationBar.headerTitle = "Players Stats".localiz().uppercased()
        navigationBar.delegate = self
    }
    
    private func setupPresenter() {
        presenter.attachView(view: self)
        presenter.myTeam = self.myTeam
    }
    
    private func loadPlayersStats() {
        if indexType < self.types.count {
            self.presenter.getPlayersStats(from: self.types[indexType], showHUD: self.types[indexType] == .point, isViewAll: false)
        }
    }
    
    func getStatsView(from type: PlayerStatsType) -> GlobalPlayerStatsView {
        switch type {
        case .point:
            return pointsStatView
        case .goals:
            return goalsStatView
        case .assists:
            return assistsStatView
        case .clean_sheet:
            return cleanSheetStatView
        case .duels_they_win:
            return duelsWonStatView
        case .passes:
            return passesStatView
        case .shots:
            return shotsStatView
        case .saves:
            return savesStatView
        case .yellow_cards:
            return yellowCardsStatView
        case .dribbles:
            return dribblesStatView
        case .turnovers:
            return turnOversStatView
        case .balls_recovered:
            return ballRecoveredStatView
        case .fouls_committed:
            return foulsStatView
        }
    }
}

extension PlayersStatsController: GlobalPlayerStatsViewDelegate {
    func onViewAll(_ sender: GlobalPlayerStatsView) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayersStatsAllController") as? PlayersStatsAllController else { return }
        vc.hidesBottomBarWhenPushed = true
        vc.myTeam = self.myTeam
        vc.type = sender.type
        vc.initinialPlayers = sender.players
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onDetail(_ playerId: Int) {
        if playerId > 0 {
            if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                controller.hidesBottomBarWhenPushed = true
                controller.setupPlayer(playerId)
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

extension PlayersStatsController: GlobaNavigationBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationBar) {
        self.indexType = self.types.count
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension PlayersStatsController: NewGlobalView {
    func reloadTeamOTWeek(_ players: [Player]) {
        
    }
    
    func reloadStatsPlayers(_ type: PlayerStatsType, _ data: [Player]) {
        let rows = min(MAXIMUM_PLAYERS_STATS_NUMBER, data.count)
        let totalHeight = 58.0 + CGFloat(rows) * GlobalPlayerStatCell.heightCell
        let statsView = self.getStatsView(from: type)
        statsView.isHidden = rows == 0
        statsView.updateData(type, data)
        statsView.changeHeight(to: rows > 0 ? totalHeight : 0.0)
        
        self.indexType += 1
        self.loadPlayersStats()
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

extension PlayersStatsController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
