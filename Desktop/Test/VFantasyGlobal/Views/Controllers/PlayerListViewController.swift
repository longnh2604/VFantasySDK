//
//  PlayerListViewController.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/13/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class PlayerListViewController: UIViewController {

    @IBOutlet weak var tbView: CustomTableView!
    fileprivate var presenter = PlayerListPresenter(service: PlayerListService())
    
  
    var isFromHome: Bool = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if presenter.playerListType == .playerPool {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupPresenter()
        setupTableview()
        startGetData()
    }
    
    func setPickingPlayer(_ player: Player, _ option: GamePlay) {
        presenter.pickingPlayer = player
        presenter.transferPlayerRequestModel.gameplayOption = option
        
        if option == .Transfer {
            if let pos = player.mainPosition {
                presenter.modelRequest.position = "\(pos)"
            }
        }
    }
    
    func setPlayerListType(_ type: PlayerListType) {
        presenter.playerListType = type
    }
    
    func setTeamId(_ id: Int) {
        presenter.teamId = id
    }
    
    func setMyTeam(_ myTeam: MyTeamData?) {
        presenter.myTeam = myTeam
    }
    
    func setPosition(_ value: PlayerPositionType) {
        presenter.modelRequest.position = "\(value.rawValue)"
    }
    
    func setCurrentIndex(_ index: Int) {
        presenter.currentIndex = index
    }
    
    func setSelectedPlayers(_ value: [Player]) {
        presenter.selectedPlayers = value
    }
    
    func setBudgetTeam(_ value: Double) {
        presenter.budgetTeam = value
    }
    
    func setTeamID(_ id: Int) {
        presenter.transferPlayerRequestModel.teamId = id
    }
    
    func setLeagueID(_ id: Int) {
        presenter.modelRequest.leagueID = String(id)
    }
    
    func setAction(_ action: String) {
        presenter.modelRequest.action = action
    }
    
    func setupTableview() {
        tbView.estimatedRowHeight = 87
        tbView.rowHeight = UITableView.automaticDimension
    }
    
    func setupPresenter() {
        presenter.attackView(view: self)
    }
  
    func setupPlayerRemoves(_ players: [Player]) {
      presenter.playerRemoves.append(contentsOf: players)
    }
    
    func startGetData() {
        presenter.getCurrentSeason { (status) in
            if status == false {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.presenter.getPlayerList()
            }
        }
    }
    
    func setDeficiencyPlayers(_ amount: Int) {
        presenter.deficiencyPlayers = amount
    }
    
    func getListPlayer() {
        self.presenter.getPlayerList()
    }
    
    override func loadMore() {
        super.loadMore()
        
        getListPlayer()
    }
}

extension PlayerListViewController: PlayerListView {
    func finishedTransfering() {
        if presenter.deficiencyPlayers <= 0 {
            alertWithOk("added_player_success".localiz()) {
                NotificationCenter.default.post(name: NotificationName.transferredPlayer, object: nil)
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            for i in 0...presenter.players.count - 1 {
                let transferredPlayer = presenter.players[i]
                if transferredPlayer.id == presenter.transferPlayerRequestModel.toPlayerId {
                    transferredPlayer.selected = true
                    tbView.beginUpdates()
                    tbView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .automatic)
                    tbView.endUpdates()
                    break
                }
            }
        }
    }
    
    func reloadSection(section: Int) {
        self.tbView.beginUpdates()
        self.tbView.reloadSections(IndexSet.init(integer: section), with: .none)
        self.tbView.endUpdates()
    }
    
    func reloadView() {
        self.tbView.reloadData()
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

extension PlayerListViewController:UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == PlayListSection.search.rawValue {
            return 1
        }
        tbView.isShowNoResult(presenter.players.count)

        return presenter.players.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == PlayListSection.search.rawValue {
            return presenter.playerListType == .playerPool ? 180 : 250
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == PlayListSection.search.rawValue {
            return 0
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomViewHeaderPlayerList.instanceFromNib() as! CustomViewHeaderPlayerList
        header.delegate = self.presenter
        header.loadView(data:presenter.displays)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == PlayListSection.search.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellFilterPlayerList", for: indexPath) as! CustomCellFilterPlayerList
            cell.delegate = self.presenter
            cell.searchBar.delegate = self.presenter
            cell.updateUIFollowType(type: presenter.playerListType)
            cell.setBudgetTitle(value: presenter.budgetTeam)
            if presenter.pickingPlayer != nil || presenter.playerListType == .playerPool {
                cell.setTitle("player_pool".localiz())
            }
            cell.reloadView(seasons: self.presenter.seasons, current: presenter.currentSeason)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellPlayerList", for: indexPath) as! CustomCellPlayerList
        let model = presenter.players[indexPath.row]
        
        cell.playerListType = presenter.playerListType
        if presenter.playerListType == .playerPool {
            model.selected = presenter.selectedPlayers.filter({$0.id == model.id}).count > 0
        }
        
        cell.loadView(model: model)
        cell.loadData(displays: presenter.displays, model: model)
//        if presenter.isPickingPlayer() {
//            cell.addAddButton()
//        } else {
//            cell.removeAddButton()
//        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == PlayListSection.player.rawValue {
            let model = presenter.players[indexPath.row]
            if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
              
              if isFromHome {
                controller.setupPlayer(model.id)
                controller.setupTypePlayerStatistic(.statistic)
                controller.initBackView(title: "player_list".localiz())
                controller.delegate = self
              } else {
                let canPick = presenter.isPickingPlayer()
                controller.setupPlayer(model.id, canPick)
                controller.setupTypePlayerStatistic(.statistic)
                controller.initBackView(title: "player_list".localiz())
                controller.delegate = self
                controller.setGameplay(presenter.transferPlayerRequestModel.gameplayOption)
                controller.setFromView(presenter.pickingPlayer != nil ? .TeamPlayerList : .PlayerList)
                controller.setPlayerListType(presenter.playerListType)
                controller.setupTeamId(presenter.teamId)
                controller.setupMyTeam(presenter.myTeam)
              }
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

// MARK: - CustomCellPlayerListDelegate
extension PlayerListViewController: CustomCellPlayerListDelegate {
    func onRemove(_ cell: CustomCellPlayerList) {
        
    }
    
    func onAdd(_ cell: CustomCellPlayerList) {
        if let indexPath = tbView.indexPath(for: cell) {
            let player = presenter.players[indexPath.row]
            if let id = player.id {
                if presenter.playerListType == .playerPool {
                    let playerTransfer = presenter.playerTransfer[indexPath.row]
                    NotificationCenter.default.post(name: NotificationName.addPlayer, object: nil, userInfo: [NotificationKey.player : playerTransfer, NotificationKey.index: presenter.currentIndex])
                    self.navigationController?.popViewController(animated: true)
                } else {
                    presenter.transferPlayerRequestModel.toPlayerId = id
                    presenter.transferPlayer()
                }
            }
        }
    }
}

extension PlayerListViewController: PlayerDetailViewControllerDelegate {
    func onPick(_ id: Int) {
        presenter.transferPlayerRequestModel.toPlayerId = id
        presenter.transferPlayer()
    }
    
    func onPick(_ player: Player) {
        
    }
}
