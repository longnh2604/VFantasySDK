//
//  NewGlobalController.swift
//  PAN689
//
//  Created by Quang Tran on 7/13/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

enum GlobalSelectType {
    case team, gw, formation, none
}

class NewGlobalController: UIViewController {

    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var headerView: GlobalHeaderInfoView!
    @IBOutlet weak var headerViewHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var pitchView: GlobalPitchView!
    @IBOutlet weak var pitchViewHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var bankView: GlobalBankPlayerView!
    @IBOutlet weak var bankViewHeightLayout: NSLayoutConstraint!

    var teamId: Int = 0
    var lastTeamId: Int = 0
    
    private var presenter = NewGlobalPresenter(service: GlobalServices())
    private var selectType: GlobalSelectType = .none
    private var timer: Timer?
    private var isResetTeamOTWeek: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mainContentView.roundCorners([.topLeft, .topRight], 16.0)
        self.bankView.roundCorners(.allCorners, 16.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.isResetTeamOTWeek {
            self.getCurrentTeam()
        }
        self.isResetTeamOTWeek = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopTimeline()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupPresenter()
    }
    
    func resetTeamOTWeekIfNeed() {
        if self.presenter.isTeamOTWeek {
            self.isResetTeamOTWeek = true
            self.presenter.isTeamOTWeek = false
            self.getCurrentTeam()
        } else {
            self.isResetTeamOTWeek = false
        }
    }
    
    func changeTeamId(_ teamId: Int) {
        if self.teamId == teamId {
            return
        }
        self.lastTeamId = self.teamId
        self.teamId = teamId
        if self.lastTeamId == 0 {
            self.lastTeamId = teamId
        }
        self.presenter.teamId = teamId
        self.presenter.model.realRoundId = nil
    }

    private func setupUI() {
        self.headerView.delegate = self
        self.mainContentView.backgroundColor = UIColor(hex: 0x10003F)

        let formationHeight: CGFloat = (UIScreen.SCREEN_WIDTH - 32) * 318.0/343.0
        let height = 100.0 + formationHeight + 72.0
        self.pitchViewHeightLayout.constant = height
        self.pitchView.delegate = self
        self.pitchView.playerDelegate = self
        
        self.headerViewHeightLayout.constant = KEY_WINDOW_SAFE_AREA_INSETS.top + 120.0
        
        self.bankView.onDetailPlayer = { player in
            self.onDetail(player, false)
        }
    }
    
    private func setupPresenter() {
        presenter.attachView(view: self)
        presenter.teamId = teamId
    }
    
    private func getCurrentTeam() {
        self.presenter.getInfoMyTeam()
    }
    
    private func getPitchTeamData() {
        self.presenter.getInfoPitchTeam()
    }

    private func getSquadTeamData() {
        self.presenter.getGlobalSquadInfo()
    }
    
    func onDetail(_ player: Player, _ isStats: Bool) {
        if let id = player.id {
            if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                controller.hidesBottomBarWhenPushed = true
                controller.setupPlayer(id)
                controller.initBackView(title: "Global".localiz())
                controller.setPlayerListType(.playerPool)
                controller.setupTeamId(presenter.teamId)
                controller.setupTypePlayerStatistic(.statistic)
                controller.setupMyTeam(presenter.myTeam)
                controller.setupIsPlayerStatsGlobal(isStats)
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func startTimeline() {
        stopTimeline()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(onTik(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTimeline() {
        timer?.invalidate()
        timer = nil
    }

    @objc func onTik(_ sender: Any) {
        self.pitchView.update(data: self.presenter.pitchData, formation: self.presenter.model.formationTeam)
    }
}

extension NewGlobalController: GlobalPlayerViewDelegate {
    func onSelectPlayer(_ sender: GlobalPlayerView) {
        if self.presenter.isTeamOTWeek {
            guard let player = sender.player else { return }
            self.onDetail(player, false)
            return
        }
        if sender.isHiddenLock {
            guard let players = presenter.pitchData?.morePlayers.filter({ return $0.mainPosition == sender.position.type.position }) else { return }
            guard let window = UIApplication.shared.windows.last else { return }
            let popup = PopupSelectPlayerView(frame: window.bounds)
            popup.players = players
            popup.data = presenter.pitchData
            popup.show(in: window, true)
            popup.pickCompletion = { result in
                self.presenter.addPlayer(from: sender.player, to: result, to: sender.position)
            }
        } else {
            self.alertMessage("This player has been locked because his real match has started.".localiz())
        }
    }
}

//MARK: - Presenter
extension NewGlobalController: NewGlobalView {
    func reloadTeamOTWeek(_ players: [Player]) {
        if let GW = presenter.currentGW {
            self.pitchView.lblGameWeek.text = GW.title
            if self.presenter.model.realRoundId != GW.id {
                self.presenter.model.realRoundId = GW.id
                self.presenter.getInfoMyTeam()
            }
        } else {
            self.pitchView.lblGameWeek.text = nil
        }
        self.presenter.isTeamOTWeek = true
        self.stopTimeline()
        self.pitchView.updateTeamOTWeek(formation: self.presenter.model.formationTeam, players)
    }
    
    func reloadStatsPlayers(_ type: PlayerStatsType, _ data: [Player]) {
    }
    
    func reloadHeader(_ isCompleted: Bool) {
        if isCompleted {
            self.headerView.updateData(self.presenter.myTeam)
            if !self.presenter.isTeamOTWeek {
                self.getPitchTeamData()
            }
        } else {
            self.moveToHomeScreen(self.presenter.teamId)
        }
    }
    
    func reloadPitchTeam() {
        if let GW = presenter.currentGW {
            self.pitchView.lblGameWeek.text = GW.title
        } else {
            self.pitchView.lblGameWeek.text = nil
        }
        self.startTimeline()
        self.pitchView.update(data: self.presenter.pitchData, formation: self.presenter.model.formationTeam)
    }
    
    func reloadBankPlayers() {
        let separateIndex: Int? = self.presenter.pitchData?.players.count ?? nil
        let numberRows: Int = self.presenter.players.isEmpty ? 2 : self.presenter.players.count + 1
        let totalHeight = CGFloat(numberRows) * GlobalBankPlayerCell.heightCell + (self.presenter.players.isEmpty ? 0.0 : 70.0)
        self.bankViewHeightLayout.constant = totalHeight + (separateIndex != nil ? 5.0 : 0.0)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.bankView.isHidden = self.presenter.players.isEmpty
        self.bankView.update(self.presenter.players, separateIndex)
    }
    
    func gotoFollowPlayDay() {
        if self.presenter.realMatchesDisplay.isEmpty {
            self.alertMessage("No matches is available now".localiz())
            return
        }
        guard let window = UIApplication.shared.windows.last else { return }
        let popup = GlobalFollowPlayDayView(frame: window.bounds)
        popup.group = self.presenter.realMatchesDisplay
        popup.show(root: window)
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

//MARK: - GlobalHeaderInfoViewDelegate
extension NewGlobalController: GlobalHeaderInfoViewDelegate {
    func onSelectedWeekScore(_ sender: GlobalHeaderInfoView) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewGlobalWeekScoreController") as? NewGlobalWeekScoreController else { return }
        vc.hidesBottomBarWhenPushed = true
        vc.leagueId = presenter.myTeam?.league?.id ?? 0
        vc.teamId = presenter.myTeam?.id ?? 0
        vc.currentGW = presenter.currentGW?.id ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onSelectedTotalScore(_ sender: GlobalHeaderInfoView) {
        
    }
    
    func onSelectedRanking(_ sender: GlobalHeaderInfoView) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewGlobalRankingController") as? NewGlobalRankingController else { return }
        vc.hidesBottomBarWhenPushed = true
        vc.leagueId = presenter.myTeam?.league?.id ?? 0
        vc.myTeam = presenter.myTeam
        vc.currentGW = presenter.currentGW?.id ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onSelectedBudget(_ sender: GlobalHeaderInfoView) {
        
    }
}

//MARK: - GlobalPitchViewDelegate
extension NewGlobalController : CheckBoxViewControllerDelegate {
    private func showPopupMenu(_ data: [CheckBoxData], _ selected: CheckBoxData?) {
        if let controller = UIApplication.getTopController() {
            if let vc = instantiateViewController(storyboardName: .common, withIdentifier: "CheckBoxViewController") as? CheckBoxViewController {
                vc.delegate = self
                vc.updateItems(data, selected)
                
                let formSheetController = MZFormSheetPresentationViewController(contentViewController: vc)
                formSheetController.presentationController?.contentViewSize = CGSize(width:controller.view.frame.size.width - 40, height: vc.getHeight())
                formSheetController.presentationController?.shouldCenterVertically = true
                formSheetController.presentationController?.shouldCenterHorizontally = true
                formSheetController.contentViewControllerTransitionStyle = .fade
                formSheetController.presentationController?.didTapOnBackgroundViewCompletionHandler = {location in
                    formSheetController.dismiss(animated: true, completion: nil)
                }
                formSheetController.allowDismissByPanningPresentedView = true
                formSheetController.contentViewCornerRadius = 20
                formSheetController.willPresentContentViewControllerHandler = { vc in
                    
                }
                controller.present(formSheetController, animated: true) {
                    vc.scrollToSelectedItem()
                }
            }
        }
    }
    
    func didClickApply(_ item: CheckBoxData) {
        if self.selectType == .formation {
            if self.presenter.isTeamOTWeek {
                let newFormation = FormationTeam(rawValue: item.key!) ?? .team_442
                if newFormation != self.pitchView.currentFormation {
                    self.pitchView.updateTeamOTWeek(formation: newFormation, self.presenter.playersOTWeek)
                }
                return
            }
            self.presenter.changeFormation(formation: item.key!)
        } else if self.selectType == .team {
            if let teamId = Int(item.key ?? ""), teamId != 0, teamId != self.presenter.teamId {
                self.changeTeamId(teamId)
                self.getCurrentTeam()
            }
        } else if self.selectType == .gw {
            let round = Int(item.key ?? "") ?? 0
            if self.presenter.isTeamOTWeek {
                self.presenter.getTeamOTWeek(roundId: round)
            } else {
                self.presenter.model.realRoundId = round
                self.presenter.getInfoMyTeam()
            }
        }
        self.selectType = .none
    }
}

extension NewGlobalController: GlobalPitchViewDelegate {
    func onChangeGW() {
        self.presenter.getListGameweekForTeamID { (data) in
            if !data.isEmpty {
                self.selectType = .gw
                let availableGWs: [CheckBoxData] = data.map({ return CheckBoxData("\($0.id ?? 0)", "\($0.round ?? 0)", $0.title ?? "") })
                var selectedGW: CheckBoxData?
                if let gw = self.presenter.currentGW {
                    selectedGW = CheckBoxData("\(gw.id ?? 0)", "\(gw.round ?? 0)", gw.title ?? "")
                }
                self.showPopupMenu(availableGWs, selectedGW)
            }
        }
    }
    
    func onChangeTeam() {
        if self.presenter.isTeamOTWeek {
            return
        }
        self.presenter.getAllMyTeams { (data) in
            if !data.isEmpty {
                self.selectType = .team
                let availableTeams: [CheckBoxData] = data.map({ return CheckBoxData("\($0.id ?? 0)", $0.name ?? "", $0.name ?? "") })
                var selectedTeam: CheckBoxData?
                if let team = self.presenter.myTeam {
                    selectedTeam = CheckBoxData("\(team.id ?? 0)", team.name ?? "", team.name ?? "")
                }
                self.showPopupMenu(availableTeams, selectedTeam)
            }
        }
    }
    
    func onChangeFormation() {
        if let isLockFormation = presenter.pitchData?.isLockFormation, isLockFormation, !self.presenter.isTeamOTWeek {
          showAlert(message: "This round already started so you cannot change the formation of the team.".localiz())
          return
        }
        self.selectType = .formation
        let availabelFormation: [FormationTeam] = [.team_442, .team_433, .team_424, .team_352, .team_343, .team_532, .team_541]
        let data: [CheckBoxData] = availabelFormation.map({ return CheckBoxData($0.rawValue, $0.rawValue, $0.rawValue) })
        let currentFormation: FormationTeam = self.pitchView.currentFormation
        let selectedData = CheckBoxData(currentFormation.rawValue, currentFormation.rawValue, currentFormation.rawValue)
        self.showPopupMenu(data, selectedData)
    }
    
    func gotoHomeScreen() {
        self.moveToHomeScreen(self.presenter.teamId)
    }
    
    private func moveToHomeScreen(_ teamId: Int) {
        guard let globalVC = instantiateViewController(storyboardName: .global, withIdentifier: GlobalViewController.className) as? GlobalViewController else { return }
        globalVC.isFromNewGlobal = true
        globalVC.teamId = teamId
        globalVC.newGlobal = self
        self.navigationController?.pushViewController(globalVC, animated: true)
    }
    
    func gotoTransferScreen() {
        self.presenter.validateTransfer { (status, message) in
            if status {
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewGlobalTransferController") as? NewGlobalTransferController else { return }
                vc.hidesBottomBarWhenPushed = true
                vc.myTeam = self.presenter.myTeam
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showAlert(message: message)
            }
        }
    }
    
    func gotoPlayerStatsScreen() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayersStatsController") as? PlayersStatsController else { return }
        vc.hidesBottomBarWhenPushed = true
        vc.myTeam = self.presenter.myTeam
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoTeamOTWeek() {
        if self.presenter.isTeamOTWeek {
            self.presenter.isTeamOTWeek = false
            self.presenter.model.realRoundId = nil
            self.getCurrentTeam()
        } else {
            self.presenter.getTeamOTWeek(roundId: self.presenter.currentGW?.id ?? 0)
        }
    }
    
    func gotoPlayDay() {
        self.presenter.getRealMatch()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
