//
//  TeamPlayerListViewController.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/12/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol GlobalTeamPlayerListViewControllerDelegate: NSObjectProtocol {
    func onAddPlayer(_ player: Player)
}

class GlobalTeamPlayerListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultLabel: UILabel!
    
    weak var delegate: GlobalTeamPlayerListViewControllerDelegate?
    
    private var playerListHeader: GlobalPlayerListCollapseView!
    var presenter: GlobalCreateTeamInfoPresenter!
    var fixedPosition = PlayerPositionType.all
    var pickingIndex = 0
    var seasonId: Int = 0
    
    var currentCheckClub:[FilterData]?
    
    private var headerView: TeamPlayerListHeaderView?
    var isPopup = false
    var myTeam: MyTeamData?
    
    private var previousScrollOffset: CGFloat = 0.0
    private var maxHeaderHeight: CGFloat = 116
    private let minHeaderHeight: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add buget button
        let budgetButton = UIBarButtonItem(title: "bank".localiz() + ": " + (self.presenter.playerLineupInfo.budget?.priceDisplay ?? "")) {}
        self.navigationItem.leftBarButtonItem = budgetButton
        
        //call API sort Position, default value is ALL
        presenter.attachView(view: self)
        presenter.sortPosition(fixedPosition.rawValue)
        presenter.playerLineupInfo.seasonId = seasonId
        presenter.model.teamId = self.myTeam?.id ?? 0
        initTableView()
        
        if fixedPosition != .all {
            isPopup = true
        }
        presenter.refreshPlayerList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if fixedPosition != .all {
            self.maxHeaderHeight = 50
        }
    }
    
    // MARK: - Init
    private func initTableView() {
        playerListHeader = GlobalPlayerListCollapseView(frame: CGRect(x: 0, y: 0, width: UIScreen.SCREEN_WIDTH, height: 150))
        playerListHeader.presenter = presenter
        playerListHeader.delegate = self
        tableView.tableHeaderView = playerListHeader
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PlayerInfoCell", bundle: Bundle.sdkBundler()), forCellReuseIdentifier: "PlayerInfoCell")
        tableView.register(UINib(nibName: "TeamPlayerListHeaderCell", bundle: Bundle.sdkBundler()), forCellReuseIdentifier: "TeamPlayerListHeaderCell")
        tableView.register(UINib(nibName: GlobalPlayerNewCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: GlobalPlayerNewCell.identifierCell)
        
    }
    
    func reloadData() {
        if presenter.noPlayers() {
            presenter.refreshPlayerList()
        }
        if noResultLabel != nil, tableView != nil, playerListHeader != nil {
            noResultLabel.isHidden = !presenter.noPlayers()
            tableView.reloadData()
            playerListHeader.reloadData()
        }
    }
    
    // MARK: Reload & Load more
    func reloadSortedData() {
        tableView.reloadData()
    }
    
    func reloadSelectedCell() {
        presenter.refreshPlayerList()
    }
    
    func endEditing() {
        dismissKeyboard()
        playerListHeader.searchBar.tfSearch.resignFirstResponder()
    }
    
    func addPlayer(_ player: inout Player) {
        if presenter.playerLineupInfo.gameplay == .Transfer {
            //check if user has enough budget to add selected player
            if let playerValue = player.transferValue, let budget = presenter.playerLineupInfo.budget {
                if Double(playerValue) > budget {
                    self.showAlert(message: "current_budget_is_not_enough".localiz())
                } else {
                    //add player
                    if isPopup {
                        player.order = pickingIndex + 1
                        delegate?.onAddPlayer(player)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        //picking players continuously, can't define order,
                        //so that we have to find available orders left to fill player in
                        if let order = presenter.availablePositionIndexForPlayer(player) {
                            player.order = order + 1 //Valid order
                            delegate?.onAddPlayer(player)
                        } else {
                            showAlert(message: "no_vacancy_for_this_position".localiz())
                        }
                    }
                }
            }
        } else {
            //add player
            if isPopup {
                player.order = pickingIndex + 1
                delegate?.onAddPlayer(player)
                self.dismiss(animated: true, completion: nil)
            } else {
                //picking players continuously, can't define order,
                //so that we have to find available orders left to fill player in
                if let order = presenter.availablePositionIndexForPlayer(player) {
                    player.order = order + 1 //Valid order
                    delegate?.onAddPlayer(player)
                } else {
                    showAlert(message: "no_vacancy_for_this_position".localiz())
                }
            }
        }
    }
    
}

extension GlobalTeamPlayerListViewController: GlobalPlayerNewCellDelegate {
    func onAction(sender: GlobalPlayerNewCell, _ player: Player) {
        if let indexPath = tableView.indexPath(for: sender) {
            if presenter.canPickLineup {
                let players = presenter.playerListInfo.players
                if var player = players[safe: indexPath.row] {
                    let picked = player.isSelected ?? false
                    if !picked {
                        addPlayer(&player)
                    }
                }
                
            } else {
                let lineupInfo = presenter.playerLineupInfo
                if lineupInfo.gameplay == .Transfer {
                    showAlert(message: "cant_pick_after_setup_time".localiz())
                } else {
                    if lineupInfo.draftStatus == .waitingForStart || lineupInfo.draftStatus == .waitingForServer {
                        showAlert(message: "cant_pick_before_setup_time".localiz())
                    } else if lineupInfo.draftStatus == .finished {
                        showAlert(message: "alert_only_pick_in_draft_time".localiz())
                    }
                }
            }
        }
    }
}

extension GlobalTeamPlayerListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GlobalPlayerNewCell.identifierCell) as? GlobalPlayerNewCell else { return UITableViewCell() }
        if presenter.playerListInfo.isRefreshing {
            return cell
        }
        cell.selectionStyle = .none
        cell.delegate = self
        cell.contentToBottomLayout.constant = indexPath.row == 9 - 1 ? 0.0 : 1.0
        if indexPath.row == 0 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.topLeft, .topRight], 16.0)
        } else if indexPath.row == presenter.playerListInfo.players.count - 1 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.bottomLeft, .bottomRight], 16.0)
        } else {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, .allCorners, 0.0)
        }
        let info = presenter.playerListInfo
        let player = info.players[indexPath.row]
        cell.updateData(player)
        cell.lblValue.text = "€\(VFantasyCommon.budgetDisplay(player.transferValue))"
        if VFantasyManager.shared.isVietnamese() {
            cell.lblValue.text = "\(VFantasyCommon.budgetDisplay(player.transferValue))"
        }
        
        cell.btnAdd.isHidden = false
        if player.isSelected != true {
            if (!presenter.isAllowPickPlayer(player: player) || !presenter.isAllowPickClup(realClupID: player.realClubID ?? -1)) {
                cell.btnAdd.isHidden = true
            } else {
                cell.btnAdd.setImage(VFantasyCommon.image(named: "global_ic_add_transfer"), for: .normal)
                cell.btnAdd.isUserInteractionEnabled = true
            }
        } else {
            cell.btnAdd.isUserInteractionEnabled = true
            cell.btnAdd.setImage(VFantasyCommon.image(named: "ic_lineup_player_added"), for: .normal)
        }
        
        cell.delegate = self
        
        if indexPath.row == info.players.count - 1 {
            presenter.morePlayers()
        }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.playerListInfo.players.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let players = presenter.playerListInfo.players
            let player = players[indexPath.row]
            guard let playerId = player.id, let gameplay = presenter.playerLineupInfo.gameplay else {
                return
            }
            if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                controller.setupPlayer(playerId, presenter.canPickLineup)
                controller.setPickingPlayer(player)
                controller.delegate = self
                controller.setupTypePlayerStatistic(.statistic)
                controller.setFromView(.TeamPlayerList)
                controller.initBackView(title: "player_list".localiz())
                controller.setGameplay(gameplay)
                
                controller.setPlayerListType(.playerPool)
                controller.setupTeamId(myTeam?.id)
                controller.setupMyTeam(myTeam)
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GlobalPlayerNewCell.heightCell
    }
}

extension GlobalTeamPlayerListViewController : TeamPlayerListHeaderCellDelegate {
    func onChangeSort() {
        presenter.refreshPlayerList(true)
    }
}

extension GlobalTeamPlayerListViewController : FilterClubViewControllerDelegate {
    func didClickBack(position: [FilterData], club: [FilterData]) {
        self.currentCheckClub = club
        
        var clubIds = [String]()
        club.forEach { (filterData) in
            clubIds.append(filterData.key)
        }
        
        presenter.model.clubID = clubIds.joined(separator: ",")
        presenter.refreshPlayerList()
    }
}

extension GlobalTeamPlayerListViewController : GlobalPlayerListCollapseViewDelegate {
    func onFilter() {
        showFilter()
    }
    
    func showFilter() {
        if let controller = UIApplication.getTopController() {
            if let filterVC = instantiateViewController(storyboardName: .player, withIdentifier: "FilterClubViewController") as? FilterClubViewController {
                filterVC.delegate = self
                filterVC.setCurrentCheck(position: nil, club: self.currentCheckClub)
                filterVC.showPosition = false
                filterVC.initBackView(title: "player_list".localiz())
                controller.navigationController?.pushViewController(filterVC, animated: true)
            }
        }
    }
    
    func toggleSort() {
        onChangeSort()
    }
}

extension GlobalTeamPlayerListViewController: PlayerDetailViewControllerDelegate {
    func onPick(_ player: Player) {
        var pickedPlayer = player
        addPlayer(&pickedPlayer)
    }
    
    func onPick(_ id: Int) {
        
    }
}
extension GlobalTeamPlayerListViewController: GlobalCreateTeamInfoView {
    func didSelectPageControl(_ pos: Int) {
        
    }
    
    func onChangedSort() {
        
    }
    
    func updateBudget() {
        
    }
    
    func completeLineup() {
        
    }
    
    func updateGameWeek(gameWeek: GameWeekInfo) {
        
    }
    
    func updatePlayerInfo() {
        presenter.refreshPlayerList()
        reloadData()
    }
    func reloadView(_ index: Int) {
        reloadData()
    }
    
    func reloadLineup() {
        
    }
    
    func startLoading() {
        if let parent = self.parent as? GlobalCreateTeamInfoController {
            parent.startLoading()
        }
    }
    
    func finishLoading() {
        if let parent = self.parent as? GlobalCreateTeamInfoController {
            parent.finishLoading()
        }
    }
    
    func alertMessage(_ message: String) {
        stopAnimation()
        showAlert(message: message)
    }
}

extension GlobalTeamPlayerListViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
