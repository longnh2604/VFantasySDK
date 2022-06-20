//
//  GlobalViewController.swift
//  PAN689
//
//  Created by AgileTech on 11/30/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit
import Foundation

enum GlobalGroupType {
    case header, infoGW, myTeams, myLeagues
    
    var title: String {
        switch self {
        case .myTeams:
            return "My Teams".localiz()
        case .myLeagues:
            return "My Leagues".localiz()
        default:
            return ""
        }
    }
}

class GlobalViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblHeaderInfo: UILabel!
    @IBOutlet weak var ivAvatarTeam: UIImageView!
    @IBOutlet weak var headerViewToTopLayout: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeightLayout: NSLayoutConstraint!
    
    var presenter = GlobalLeaguePresenter(service: GlobalServices())
    var createPopup: GlobalLeagueCreateTeamPopup?
    var pickPopup: GlobalLeaguePickTeamPopup?
    var newGlobal: NewGlobalController?
    var isReplacement: Bool = false
    var isFromNewGlobal: Bool = false
    var isCompletedTeam: Bool = false
    var teamId: Int = 0
    var types: [GlobalGroupType] = [/*.header, .infoGW,*/.myTeams, .myLeagues]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isCompletedTeam {
            presenter.getInfoMyTeam(true)
            isCompletedTeam = false
        } else {
            presenter.getInfoMyTeam()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mainView.roundCorners([.topLeft, .topRight], 16.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTableView()
        setupPresenter()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let rankNib = UINib(nibName: "MyTeamsCell", bundle: Bundle.sdkBundler())
        tableView.register(rankNib, forCellReuseIdentifier: "MyTeamsCell")
        let myLeagueNib = UINib(nibName: "MyLeagueCell", bundle: Bundle.sdkBundler())
        tableView.register(myLeagueNib, forCellReuseIdentifier: "MyLeagueCell")
        tableView.register(HeaderFollowPlayDayCell.nib, forHeaderFooterViewReuseIdentifier: HeaderFollowPlayDayCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        self.mainView.isHidden = true
        self.footerView.isHidden = true
        self.showHideHeaderInfo(false)
        self.footerView.backgroundColor = UIColor(hex: 0x10003F)
        self.btnBack.isHidden = !isFromNewGlobal
        self.lblHeader.textColor = .white
        self.lblHeader.font = UIFont(name: FontName.blackItalic, size: 24)
        self.lblHeader.text = "Global league".localiz().uppercased()
    }
    
    func changeTeamId(_ teamId: Int) {
        self.teamId = teamId
        self.presenter.teamId = teamId
    }
    
    private func setupPresenter() {
        presenter.attachView(view: self)
        presenter.teamId = teamId
    }
    
    func setupMyTeam(_ data: MyTeamData?) {
        if let data = data {
            ivAvatarTeam.setPlayerAvatar(with: data.logo)
            lblHeaderInfo.text = data.name
            showHideHeaderInfo(true)
        } else {
            showHideHeaderInfo(false)
        }
    }
    
    func showHideHeaderInfo(_ show: Bool) {
        self.headerView.isHidden = !show
        self.headerViewToTopLayout.constant = show ? 24.0 : 0.0
        self.headerViewHeightLayout.constant = show ? 64.0 : 0.0
        if show && self.presenter.isCompletedTeam {
            pickPopup?.removeFromSuperview()
            pickPopup = nil
            createPopup?.removeFromSuperview()
            createPopup = nil
        }
    }
    
    @IBAction func onEditTeam(_ sender: Any) {
        gotoCreateGlobal(true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        if let newGlobal = self.newGlobal {
            if self.presenter.myTeam?.isCompleted ?? false {
                newGlobal.changeTeamId(self.teamId)
            } else {
                newGlobal.changeTeamId(newGlobal.lastTeamId)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension GlobalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension GlobalViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.isCompletedTeam ? types.count : 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.isCompletedTeam ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if presenter.isCompletedTeam {
            let type = self.types[indexPath.section]
            if type == .myTeams {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyTeamsCell", for: indexPath) as? MyTeamsCell else {
                    return UITableViewCell()
                }
                cell.setupCell(teams: self.presenter.allTeams)
                cell.delegate = self
                return cell
            }
            if type == .myLeagues {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyLeagueCell", for: indexPath) as? MyLeagueCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                cell.setupCell(leagues: presenter.leagues)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func gotoCreateGlobal(_ isEdit: Bool) {
        guard let vc = instantiateViewController(storyboardName: .global, withIdentifier: CreateYourGlobalTeamViewController.className) as? CreateYourGlobalTeamViewController else {
            return
        }
        vc.isEdit = isEdit
        vc.teamId = self.presenter.teamId
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFollowPlayDayCell.identifier) as? HeaderFollowPlayDayCell else {
            return UIView()
        }
        let type = self.types[section]
        headerView.lblTitle.text = type.title
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HeaderFollowPlayDayCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

extension GlobalViewController: CreateYourGlobalTeamViewControllerDelegate {
    func onCreateNewTeamSuccessful(_ teamId: Int) {
        self.changeTeamId(teamId)
    }
}

extension GlobalViewController: MyTeamsCellDelegate {
    func onCreateNewTeam() {
        self.gotoCreateGlobal(false)
    }
    
    func onChooseTeam(_ teamId: Int) {
        if teamId == 0 {
            return
        }
        if teamId != self.presenter.teamId {
            self.changeTeamId(teamId)
            self.presenter.getInfoMyTeam(true)
        } else {
            self.onBack(self)
        }
    }
}

//MARK: MyLeagueCellDelegate
extension GlobalViewController: MyLeagueCellDelegate {
    func onCreateLeague() {
        guard let vc = instantiateViewController(storyboardName: .global, withIdentifier: "GlobalCreateNewLeagueViewController") as? GlobalCreateNewLeagueViewController else {
            return
        }
        
        let service = GlobalNewLeagueService()
        vc.presenter = GlobalCreateNewLeaguePresenter(service: service)
        vc.presenter.teamId = presenter.myTeam?.id ?? 0
        vc.presenter.globalLeagueMode = .new
        vc.hidesBottomBarWhenPushed = true
        vc.isCreate = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onRedeemCode() {
        self.tabBarController?.tabBar.isHidden = true
        let popup = PopupRedeemCodeLeague(frame: self.view.bounds)
        popup.show(in: self.view, true)
        popup.closedCompletion = {
            self.tabBarController?.tabBar.isHidden = false
        }
        popup.redeemCompletion = { code in
            if !code.isEmpty {
                self.presenter.redeemCodeToJoinLeague(code)
            }
        }
    }
    
    func onDetailLeague(_ league: LeagueDatum) {
        guard let vc = instantiateViewController(storyboardName: .global, withIdentifier: "GlobalLeagueDetailViewController") as? GlobalLeagueDetailViewController else {
            return
        }
        
        let leagueModel = GlobalLeagueModelView(league: league)
        vc.presenter = GlobalLeagueDetailPresenter(league: leagueModel)
        vc.presenter.teamId = presenter.myTeam?.id ?? 0
        vc.presenter.leagueId = league.id ?? 0
        vc.presenter.league = league
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: HeaderCellDelegate
extension GlobalViewController: HeaderCellDelegate {
    func onEdit() {
        gotoCreateGlobal(true)
    }
}

//MARK: GlobalLeagueCreateTeamPopupDelegate
extension GlobalViewController: GlobalLeagueCreateTeamPopupDelegate {
    func onCreateTeam() {
        gotoCreateGlobal(false)
    }
}

//MARK: GlobalLeaguePickTeamPopupDelegate
extension GlobalViewController: GlobalLeaguePickTeamPopupDelegate {
    func onPickTeam() {
        if self.isReplacement {
            guard let vc = instantiateViewController(storyboardName: .transferGlobal, withIdentifier: TransferGlobalViewController.className) as? TransferGlobalViewController else { return }
            vc.presenter.teamID = self.presenter.myTeam?.id ?? 0
            vc.presenter.myTeam = self.presenter.myTeam
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let vc = instantiateViewController(storyboardName: .global, withIdentifier: "GlobalCreateTeamInfoController") as? GlobalCreateTeamInfoController else { return }
            vc.presenter.teamID = presenter.myTeam?.id ?? 0
            vc.presenter.leagueID = presenter.myTeam?.league?.id ?? 0
            vc.myTeam = presenter.myTeam
            vc.setId(leagueID: vc.presenter.leagueID, teamID: vc.presenter.teamID)
            vc.canPickLineup(true)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: GlobalLeagueView
extension GlobalViewController: GlobalLeagueView {
    func goBackGlobal(_ teamId: Int) {
        
    }
    
    func gotoTransferPlayer(_ deletedPlayer: [Player]) {
        var names: String = ""
        var totalRefund: Int = 0
        for index in 0..<deletedPlayer.count {
            let player = deletedPlayer[index]
            totalRefund += player.transferValue ?? 0
            let namePlayer = player.getNameDisplay() ?? ""
            if index == 0 {
                names = namePlayer
            } else if index == deletedPlayer.count - 1 {
                names = "\(names) and \(namePlayer)"
            } else {
                names = "\(names), \(namePlayer)"
            }
        }
        createPopup?.removeFromSuperview()
        createPopup = nil
        isReplacement = true
        if pickPopup == nil {
            
            pickPopup = GlobalLeaguePickTeamPopup(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            pickPopup?.contentImageView.image = VFantasyCommon.image(named: "A01I1422")
            if VFantasyManager.shared.isVietnamese() {
                pickPopup?.contentImageView.image = VFantasyCommon.image(named: "bg_pickteam")
            }
            pickPopup?.btnAction.setTitle("Select replacement".localiz(), for: .normal)
            pickPopup?.delegate = self
            
            self.view.addSubview(pickPopup!)
            
            pickPopup?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pickPopup!.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 150),
                pickPopup!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                pickPopup!.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                pickPopup!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
        pickPopup?.lblNote.text = String(format: "%@ have left this league. You have a refund of %@. Please select replacements to have a team of 18 players", names, VFantasyCommon.budgetDisplay(totalRefund, suffixMillion: "mio_suffix".localiz()))
        
        self.reloadData()
    }
    
    func gotoPickPlayers() {
        createPopup?.removeFromSuperview()
        createPopup = nil
        isReplacement = false
        if pickPopup == nil {
            
            pickPopup = GlobalLeaguePickTeamPopup(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            pickPopup?.contentImageView.image = VFantasyCommon.image(named: "A01I3338")
            if VFantasyManager.shared.isVietnamese() {
                pickPopup?.contentImageView.image = VFantasyCommon.image(named: "bg_pickteam")
            }
            pickPopup?.delegate = self
            pickPopup?.setup(presenter.myTeam)
            
            self.view.addSubview(pickPopup!)
            
            pickPopup?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pickPopup!.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 150),
                pickPopup!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                pickPopup!.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                pickPopup!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        } else {
            pickPopup!.setup(presenter.myTeam)
        }
        
        self.reloadData()
    }
    
    func reloadMyTeams() {
        guard let index = self.types.firstIndex(where: { return $0 == .myTeams }) else { return }
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: index), with: .none)
        }
    }
    
    func reloadMyLeagues() {
        guard let index = self.types.firstIndex(where: { return $0 == .myLeagues }) else { return }
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: index), with: .none)
        }
    }
    
    func reloadData() {
        self.mainView.isHidden = !self.presenter.isCompletedTeam
        self.footerView.isHidden = !self.presenter.isCompletedTeam
        self.tableView.reloadData()
        self.setupMyTeam(presenter.myTeam)
        if self.presenter.isCompletedTeam {
            self.presenter.requestMyLeagueList()
            self.presenter.getAllMyTeams()
        }
    }
    
    func gotoCreateTeam() {
        pickPopup?.removeFromSuperview()
        pickPopup = nil
        if createPopup == nil {
            
            createPopup = GlobalLeagueCreateTeamPopup(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            createPopup?.contentImageView.image = VFantasyCommon.image(named: "A01I6626")
            if VFantasyManager.shared.isVietnamese() {
                createPopup?.contentImageView.image = VFantasyCommon.image(named: "bg_createteam")
            }
            createPopup?.delegate = self
            
            self.view.addSubview(createPopup!)
            
            createPopup?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                createPopup!.topAnchor.constraint(equalTo: self.view.topAnchor, constant: HeaderCell.heightCell + 10),
                createPopup!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                createPopup!.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                createPopup!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
        
    }
    
    func forwardToNewGlobal() {
        guard let globalVC = instantiateViewController(storyboardName: .newGlobal, withIdentifier: NewGlobalController.className) as? NewGlobalController else { return }
        globalVC.changeTeamId(teamId)
        DispatchQueue.main.async {
            self.navigationController?.pushAndReplaceTopViewController(globalVC, animated: true)
        }
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
    
    func reloadGlobalTeam(_ isSwitchTeam: Bool) {
        self.reloadData()
        if (!self.isFromNewGlobal || isSwitchTeam) && (self.presenter.myTeam?.isCompleted ?? false) {
            self.forwardToNewGlobal()
        }
    }
    
    func redeemLeague(_ data: LeagueDatum?) {
        guard let data = data else { return }
        let alert = UIAlertController(title: nil, message: "Joined the league successfully".localiz(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localiz(), style: .default, handler: { (action) in
            self.onDetailLeague(data)
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: - MyRankingCellDelegate

extension GlobalViewController: MyRankingCellDelegate {
    
    func onMyRanking(_ index: Int) {
        guard let vc = instantiateViewController(storyboardName: .global, withIdentifier: "GlobalRankingViewController") as? GlobalRankingViewController else { return }
        vc.presenter.rankingType = GlobalRankingType(rawValue: index) ?? .global
        vc.presenter.leagueId = presenter.myTeam?.league?.id ?? 0
        vc.presenter.myTeam = presenter.myTeam
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension GlobalViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
