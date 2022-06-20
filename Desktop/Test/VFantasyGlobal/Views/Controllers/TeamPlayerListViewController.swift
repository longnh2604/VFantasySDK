//
//  TeamPlayerListViewController.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/12/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol TeamPlayerListViewControllerDelegate: NSObjectProtocol {
    func onAddPlayer(_ player: Player)
}

class TeamPlayerListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var playerListHeader: PlayerListCollapseView!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    weak var delegate: TeamPlayerListViewControllerDelegate?
    
    var presenter: CreateTeamInfoPresenter! 
    var fixedPosition = PlayerPositionType.all
    var pickingIndex = 0
    
    var currentCheckClub:[FilterData]?
    
    private var headerView: TeamPlayerListHeaderView?
    private var isPopup = false
    
    private var previousScrollOffset: CGFloat = 0.0
    private var maxHeaderHeight: CGFloat = 116
    private let minHeaderHeight: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add buget button
        let budgetButton = UIBarButtonItem(title: "bank".localiz() + ": " + (self.presenter.playerLineupInfo.budget?.priceDisplay ?? "")) {}
        self.navigationItem.leftBarButtonItem = budgetButton
        
        initTableView()
        
        //call API sort Position, default value is ALL
        presenter.sortPosition(fixedPosition.rawValue)
        
        playerListHeader.presenter = presenter
        playerListHeader.delegate = self
        
        if fixedPosition != .all {
            playerListHeader.removePositionSelectionView()
            isPopup = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if fixedPosition != .all {
            self.maxHeaderHeight = 50
        }
        self.headerHeight.constant = self.maxHeaderHeight
        updateHeader()
    }
    
    // MARK: - Init
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PlayerInfoCell", bundle: Bundle.sdkBundler()), forCellReuseIdentifier: "PlayerInfoCell")
        tableView.register(UINib(nibName: "TeamPlayerListHeaderCell", bundle: Bundle.sdkBundler()), forCellReuseIdentifier: "TeamPlayerListHeaderCell")
        
        tableView.estimatedRowHeight = 40
        tableView.separatorStyle = .none
    }
    
    func reloadData() {
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
        playerListHeader.stopEditing()
    }
    
    // MARK: - ScrollView Delegates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        if canAnimateHeader(scrollView) {
            // Calculate new header height
            var newHeight = self.headerHeight.constant
            
            // Get touch scrolling point
            let translation = scrollView.panGestureRecognizer.translation(in: scrollView)
            if translation.y < 0 {
                //scroll up
                newHeight = max(self.minHeaderHeight, self.headerHeight.constant - abs(scrollDiff))
            } else {
                newHeight = min(self.maxHeaderHeight, self.headerHeight.constant + abs(scrollDiff))
            }
            
            // Header needs to animate
            if newHeight != self.headerHeight.constant {
                self.headerHeight.constant = newHeight
                self.updateHeader()
                self.setScrollPosition(self.previousScrollOffset)
            }
            
            self.previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeight.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeight.constant - minHeaderHeight

        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeight.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeight.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func setScrollPosition(_ position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
    
    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeight.constant - self.minHeaderHeight
        let percentage = openAmount / range
        
        self.playerListHeader.updateHeader(openAmount, percentage)
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

extension TeamPlayerListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamPlayerListHeaderCell") as! TeamPlayerListHeaderCell
            cell.delegate = self
            cell.updateSort(presenter.currentSortType)
            if presenter.playerLineupInfo.gameplay == .Draft {
                cell.hideSort()
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerInfoCell") as! PlayerInfoCell
        if presenter.playerListInfo.isRefreshing { return cell }
        
        let info = presenter.playerListInfo
        let player = info.players[indexPath.row]
        cell.updateData(player)
        if presenter.playerLineupInfo.gameplay == .Draft {
            cell.hidePrice()
        }
        
        if player.transferValue == 100000000 && player.isSelected == false {
            print(player)
        }
        
        if player.isSelected != true {
            if (!presenter.isAllowPickPlayer(player: player) || !presenter.isAllowPickClup(realClupID: player.realClubID ?? -1)) {
                cell.statusButton.setImage(VFantasyCommon.image(named: "ic_add_player_gray"), for: .normal)
                cell.statusButton.isUserInteractionEnabled = false
            } else {
                cell.statusButton.setImage(VFantasyCommon.image(named: "ic_add_player"), for: .normal)
                cell.statusButton.isUserInteractionEnabled = true
            }
        } else {
            cell.statusButton.isUserInteractionEnabled = true
            cell.statusButton.setImage(VFantasyCommon.image(named: "ic_added_player.png"), for: .normal)
        }
        
        cell.delegate = self
        
        if indexPath.row == info.players.count - 1 {
            presenter.morePlayers()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return presenter.playerListInfo.players.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
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
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 40
        }
        return UITableView.automaticDimension
    }
}

extension TeamPlayerListViewController : TeamPlayerListHeaderCellDelegate {
    func onChangeSort() {
        presenter.refreshPlayerList(true)
    }
}

extension TeamPlayerListViewController : FilterClubViewControllerDelegate {
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

extension TeamPlayerListViewController : PlayerInfoCellDelegate {
    func onPick(_ cell: PlayerInfoCell) {
        if let indexPath = tableView.indexPath(for: cell) {
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

extension TeamPlayerListViewController : PlayerListCollapseViewDelegate {
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
}

extension TeamPlayerListViewController: PlayerDetailViewControllerDelegate {
    func onPick(_ player: Player) {
        var pickedPlayer = player
        addPlayer(&pickedPlayer)
    }
    
    func onPick(_ id: Int) {
        
    }
}

extension TeamPlayerListViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
