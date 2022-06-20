//
//  PlayerListPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import UIKit
import MZFormSheetPresentationController

protocol PlayerListView: BaseViewProtocol {
    func reloadView()
    func reloadSection(section:Int)
    func finishedTransfering()
}

class PlayerListPresenter: NSObject {
    private var service: PlayerListService?
    weak private var playerListView: PlayerListView?
    
    var modelRequest: PlayerRequestModel = PlayerRequestModel()
    
    var players = [PlayerModelView]()
    var displays = [FilterData]()
    var seasons = [SeasonData]()
    
    var currentCheckPosition: [FilterData]?
    var currentCheckClub: [FilterData]?
    var currentSeason: SeasonData?
    
    var pickingPlayer: Player?
    var transferPlayerRequestModel = TransferPlayerRequestModel()
    var deficiencyPlayers = 0
    
    var playerListType = PlayerListType.playerList
    var budgetTeam = Double(0)
    var selectedPlayers = [Player]()
    var playerTransfer = [Player]()
    var currentIndex = 1
    var teamId = 0
    var myTeam: MyTeamData?
    
    var playerRemoves: [Player] = []
    
    // MARK: - setup view
    init(service: PlayerListService) {
        super.init()
        self.service = service
    }
    
    func attackView(view: PlayerListView) {
        self.playerListView = view
        self.updateDisplays(displays: initDataDisplay())
    }
    
    func detachView() {
        self.playerListView = nil
    }
    
    func isPickingFromTransfer() -> Bool {
        return transferPlayerRequestModel.gameplayOption == .Transfer && isPickingPlayer()
    }
    
    func isPickingPlayer() -> Bool {
        if modelRequest.canPickDueToSelectedCorrectSeason {
            return pickingPlayer != nil
        }
        return false
    }
    
    // MARK: - Setup Filter
    func initDataDisplay() -> [FilterData] {
        var data = [FilterData]()
        
        if transferPlayerRequestModel.gameplayOption == .Transfer {
            let value = FilterData()
            value.name = "value".localiz()
            value.key = DisplayKey.value
            data.append(value)
        }
        
        let position = FilterData()
        position.name = "point".localiz()
        position.key = DisplayKey.point
        data.append(position)
        
        let stat1 = FilterData()
        stat1.name = "goal".localiz()
        stat1.key = DisplayKey.goals
        data.append(stat1)
        
        return data
    }
    
    func resetService() {
        self.service?.page = 1
    }
    
    func resetData() {
        self.players.removeAll()
    }
    
    func updateDisplays(displays: [FilterData]) {
        self.displays = displays
    }
    
    func resetFilterData(_ key: String) {
        for index in 0 ..< self.displays.count {
            let current = self.displays[index]
            if current.key != key {
                current.isSelected = false
                current.direction = SortType.none
            } else {
                current.isSelected = true
            }
        }
    }
    
    // MARK: - Season
    func setCurrentSeason(_ id: String) {
        self.modelRequest.season_id = id
        currentSeason = seasons.first { $0.getIdValue() == id }
    }
    
    func getCurrentSeason(callBack: @escaping (_ status: Bool) -> Void) {
        SeasonService().getSeasonList { (response, status) in
            if status == false {
                callBack(false)
                return
            }
            
            if let data = response as? SeasonResponse {
                if let meta = data.meta {
                    if meta.success == false {
                        callBack(false)
                        return
                    }
                }
                
                if let response = data.response {
                    if let currentSeason = response.currentSeason, let seasons = response.data {
                        if let id = currentSeason.id {
                            self.modelRequest.current_season_id = id
                            self.setCurrentSeason(String(id))
                        }
                        seasons.forEach { (seasonData) in
                            self.seasons.append(seasonData)
                        }
                        callBack(true)
                    } else {
                        callBack(false)
                    }
                } else {
                    callBack(false)
                }
            } else {
                callBack(false)
            }
        }
    }
    
    // MARK: - Player list
    func getPlayerList() {
        self.playerListView?.startLoading()
        
        if let player = pickingPlayer {
            modelRequest.from_player_id = player.id
        }
        self.service?.getPlayerList(model: modelRequest, callBack: { (response, status) in
            self.playerListView?.finishLoading()
            
            if status, let data = response as? PlayerListData {
                self.handleSuccessResponse(response: data)
            } else {
                CommonResponse.handleResponseFail(response, self.playerListView)
            }
        })
    }
    
    func handleSuccessResponse(response:PlayerListData) {
        if response.meta?.success == false {
            if let message = response.meta?.message {
                self.playerListView?.alertMessage(message.localiz())
            }
            return
        }
        
        if let data = response.response?.data {
            self.playerTransfer.removeAll()
            data.forEach { (player) in
                // User when transfer player
                if !self.isExistRemovePlayers(player) {
                    self.playerTransfer.append(player)
                    
                    let modelView = PlayerListMappingData.mappingPlayerToPlayerModelView(player)
                    self.players.append(modelView)
                }
            }
            
            if let selectingSeasonId = Int(modelRequest.season_id) {
                modelRequest.canPickDueToSelectedCorrectSeason = modelRequest.current_season_id == selectingSeasonId
            }
            
            self.service?.page += 1
            self.playerListView?.reloadView()
        }
    }
    
    func isExistRemovePlayers(_ player: Player) -> Bool {
        let exists = self.playerRemoves.filter({ return $0.id == player.id })
        return !exists.isEmpty
    }
    
    // MARK: - Transfer Player
    func transferPlayer() {
        if let pickingId = pickingPlayer?.id {
            playerListView?.startLoading()
            
            transferPlayerRequestModel.fromPlayerId = pickingId
            
            PlayerListService().transferPlayer(model: transferPlayerRequestModel) { [unowned self] (response, success) in
                if success {
                    self.handleTransferResponseSuccess(response)
                } else {
                    CommonResponse.handleResponseFail(response, self.playerListView)
                }
            }
        }
    }
    
    func handleTransferResponseSuccess(_ response: AnyObject) {
        playerListView?.finishLoading()
        if let data = response as? PlayerListData {
            if let meta = data.meta {
                if meta.success == false {
                    if let message = meta.message {
                        self.playerListView?.alertMessage(message.localiz())
                    }
                    return
                }
            }
        }
        if deficiencyPlayers > 0 {
            deficiencyPlayers -= 1
        }
        playerListView?.finishedTransfering()
    }
}

extension PlayerListPresenter: FilterClubViewControllerDelegate {
    func didClickBack(position: [FilterData], club: [FilterData]) {
        self.currentCheckPosition = position
        self.currentCheckClub = club
        
        var positionIds = [String]()
        position.forEach { (filterData) in
            positionIds.append(filterData.key)
        }
        
        var clubIds = [String]()
        club.forEach { (filterData) in
            clubIds.append(filterData.key)
        }
        
        if playerListType != .playerPool {
            self.modelRequest.position = positionIds.joined(separator: ",")
        }
        self.modelRequest.clubID = clubIds.joined(separator: ",")
        
        self.resetService()
        self.resetData()
        self.getPlayerList()
    }
}

//MARK:- DisplayViewControllerDelegate
extension PlayerListPresenter: DisplayViewControllerDelegate {
    func didClickDisplay(_ display: [FilterData]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // change 2 to desired number of seconds
            self.displays = display
            self.updateDisplays(displays: self.displays)
            self.playerListView?.reloadSection(section: PlayListSection.player.rawValue)
        }
    }
}

//MARK:- delegate CustomCellFilterPlayerList
extension PlayerListPresenter: CustomCellFilterPlayerListDelegate {
    func didClickSection(_ id: String) {
        self.setCurrentSeason(id)
        self.resetService()
        self.resetData()
        
        self.getPlayerList()
    }
    
    func didClickFilter() {
        if let controller = UIApplication.getTopController() {
            if let filterVC = instantiateViewController(storyboardName: .player, withIdentifier: "FilterClubViewController") as? FilterClubViewController {
                filterVC.delegate = self
                filterVC.setCurrentCheck(position: self.currentCheckPosition, club: self.currentCheckClub)
                filterVC.initBackView(title: "Player list".localiz())
                if playerListType == .playerPool {
                    filterVC.showPosition = false
                } else {
                    filterVC.showPosition = !isPickingFromTransfer()
                }
                controller.navigationController?.pushViewController(filterVC, animated: true)
            }
        }
    }
    
    func didClickDisplay() {
        if let controller = UIApplication.getTopController() {
            if let displayVC = instantiateViewController(storyboardName: .player, withIdentifier: "DisplayViewController") as? DisplayViewController {
                displayVC.delegate = self
                displayVC.setCurrentDisplay(self.displays)
                if transferPlayerRequestModel.gameplayOption == .Draft {
                    displayVC.hideValueFilter()
                }
                controller.navigationController?.pushViewController(displayVC, animated: true)
            }
        }
    }
}

//MARK:- CustomViewHeaderPlayerListDelegate
extension PlayerListPresenter: CustomViewHeaderPlayerListDelegate {
    func didClickSort(_ key: String, _ direction: String) {
        for display in displays {
            if display.key == key {
                display.direction = SortType.fromHashValue(hashValue: direction)
            }
        }
        self.resetFilterData(key)
        
        let transferRequestModel = TransferRequestModel(property: key, direction: direction)
        modelRequest.order = VFantasyCommon.validSortType([transferRequestModel])
        
        self.resetService()
        self.resetData()
        self.getPlayerList()
    }
}

//MARK:- search delegte
extension PlayerListPresenter:UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        modelRequest.keyword = searchBar.text!
        
        self.resetService()
        self.resetData()
        self.getPlayerList()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let controller = UIApplication.getTopController() {
            controller.view.endEditing(true)
        }
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let controller = UIApplication.getTopController() {
            controller.view.endEditing(true)
        }
        searchBar.text = ""
        searchBar.showsCancelButton = false
        
        modelRequest.keyword = ""
        self.resetService()
        self.resetData()
        self.getPlayerList()
    }
}
