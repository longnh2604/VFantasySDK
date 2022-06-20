//
//  NewGlobalTransferPresenter.swift
//  PAN689
//
//  Created by Quang Tran on 8/12/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import Foundation
import UIKit

enum OrderProperty: String {
    case value, point, goals, assists, clean_sheet, duels_they_win, passes, shots, saves, yellow_cards, dribbles, turnovers, balls_recovered, fouls_committed
}

typealias SortPlayerInfo = (property: OrderProperty, sortType: SortType)

protocol NewGlobalTransferView: BaseViewProtocol {
    func updateData()
    func finishGetTransferData()
    func completedTransfer(_ status: Bool, _ message: String)
}

class NewGlobalTransferPresenter: NSObject {
    weak private var superView: NewGlobalTransferView?

    private var service: PlayerListService? = nil
    private var transferService = TransferGlobalService()
 
    var modelRequest: PlayerRequestModel = PlayerRequestModel()
    
    var position: PlayerPositionType = .all
    var teamId = 0
    var myTeam: MyTeamData?
    var pickingPlayer: Player?
    var players = [Player]()
    var gPlayers = [Player]()
    var dPlayers = [Player]()
    var mPlayers = [Player]()
    var aPlayers = [Player]()
    
    var pageAll = 1
    var pageGoalKeepers = 1
    var pageDeffenders = 1
    var pageMiddefields = 1
    var pageAttackers = 1
    
    var lastPageAll = 1
    var lastPageGoalKeepers = 1
    var lastPageDeffenders = 1
    var lastPageMiddefields = 1
    var lastPageAttackers = 1
    
    var allPlayers = 0
    var goalKeepersPlayers = 0
    var deffendersPlayers = 0
    var middefieldsPlayers = 0
    var attackersPlayers = 0
    
    var searchAllInfo: SortPlayerInfo = SortPlayerInfo(OrderProperty.value, SortType.desc)
    var searchGoalKeepersInfo: SortPlayerInfo = SortPlayerInfo(OrderProperty.value, SortType.desc)
    var searchDeffendersInfo: SortPlayerInfo = SortPlayerInfo(OrderProperty.value, SortType.desc)
    var searchMiddefieldsInfo: SortPlayerInfo = SortPlayerInfo(OrderProperty.value, SortType.desc)
    var searchAttackersInfo: SortPlayerInfo = SortPlayerInfo(OrderProperty.value, SortType.desc)
    
    func playerFor(position: PlayerPositionType) -> [Player] {
        switch position {
        case .attacker:
            return aPlayers
        case .defender:
            return dPlayers
        case .midfielder:
            return mPlayers
        case .goalkeeper:
            return gPlayers
        default:
            return players
        }
    }
    
    func currentPageFor(position: PlayerPositionType) -> Int {
        switch position {
        case .attacker:
            return pageAttackers
        case .defender:
            return pageDeffenders
        case .midfielder:
            return pageMiddefields
        case .goalkeeper:
            return pageGoalKeepers
        default:
            return pageAll
        }
    }
    
    func appendPlayer(player: Player) {
        switch position {
        case .attacker:
            aPlayers.append(player)
        case .defender:
            dPlayers.append(player)
        case .midfielder:
            mPlayers.append(player)
        case .goalkeeper:
            gPlayers.append(player)
        default:
            players.append(player)
        }
    }
    
    func increasePage() {
        switch position {
        case .attacker:
            pageAttackers += 1
        case .defender:
            pageDeffenders += 1
        case .midfielder:
            pageMiddefields += 1
        case .goalkeeper:
            pageGoalKeepers += 1
        default:
            pageAll += 1
        }
    }
    
    func updateLastPage(_ page: Int) {
        switch position {
        case .attacker:
            lastPageAttackers = page
        case .defender:
            lastPageDeffenders = page
        case .midfielder:
            lastPageMiddefields = page
        case .goalkeeper:
            lastPageGoalKeepers = page
        default:
            lastPageAll = page
        }
    }
    
    func isFullData() -> Bool {
        switch position {
        case .attacker:
            return pageAttackers > lastPageAttackers
        case .defender:
            return pageDeffenders > lastPageDeffenders
        case .midfielder:
            return pageMiddefields > lastPageMiddefields
        case .goalkeeper:
            return pageGoalKeepers > lastPageGoalKeepers
        default:
            return pageAll > lastPageAll
        }
    }
    
    func orderInfo() -> SortPlayerInfo {
        switch position {
        case .attacker:
            return searchAttackersInfo
        case .defender:
            return searchDeffendersInfo
        case .midfielder:
            return searchMiddefieldsInfo
        case .goalkeeper:
            return searchGoalKeepersInfo
        default:
            return searchAllInfo
        }
    }
    
    func updateOrderInfo(_ info: SortPlayerInfo) {
        switch position {
        case .attacker:
            searchAttackersInfo = info
        case .defender:
            searchDeffendersInfo = info
        case .midfielder:
            searchMiddefieldsInfo = info
        case .goalkeeper:
            searchGoalKeepersInfo = info
        default:
            searchAllInfo = info
        }
    }
    
    func updateAllPlayers(_ total: Int) {
        switch position {
        case .attacker:
            attackersPlayers = total
        case .defender:
            deffendersPlayers = total
        case .midfielder:
            middefieldsPlayers = total
        case .goalkeeper:
            goalKeepersPlayers = total
        default:
            allPlayers = total
        }
    }
    
    func getTotalPlayers() -> Int {
        switch position {
        case .attacker:
            return attackersPlayers
        case .defender:
            return deffendersPlayers
        case .midfielder:
            return middefieldsPlayers
        case .goalkeeper:
            return goalKeepersPlayers
        default:
            return allPlayers
        }
    }
    
    //Transfer old data
    var playerLineupInfo = TeamPlayerInfo()
    var transferGlobalModel = TransferGlobalModel()
    var nextGameWeek = GameWeekInfo()
    var playersBegin = [Player]()
    var transferLeft = 0
    var sumValueOfPlayer = 0
    
    //Transfer player
    var modelRequestTransfer = TransferPlayerRequestModel()
    var fromPlayers: [Player] = []
    var toPlayers: [Player] = []
    
    //Mapping
    var playerRemoves: [Player] = []
    var selectedPlayers: [Player] = []
    
    //Filter
    var currentCheckPosition: [FilterData]?
    var currentCheckClub: [FilterData]?
    
    var deadline_time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.kyyyyMMdd_hhmmss
        guard let date = dateFormatter.date(from: transferGlobalModel.timeDeadline) else { return "" }
        dateFormatter.dateFormat = "dd/MM/yyyy - hh:mm a"
        let stringDate = dateFormatter.string(from: date)
        
        return stringDate.uppercased()
    }
    
    init(service: PlayerListService) {
        super.init()
        self.service = service
    }
    
    func attackView(view: NewGlobalTransferView) {
        self.superView = view
    }
    
    func detachView() {
        self.superView = nil
    }
    
    func resetService() {
        self.pageAll = 1
        self.pageAttackers = 1
        self.pageDeffenders = 1
        self.pageMiddefields = 1
        self.pageGoalKeepers = 1
        self.service?.isFullData = false
    }
    
    func resetData() {
        self.players.removeAll()
        self.aPlayers.removeAll()
        self.dPlayers.removeAll()
        self.mPlayers.removeAll()
        self.gPlayers.removeAll()
    }
    
    func didClickFilter() {
        if let controller = UIApplication.getTopController() {
            if let filterVC = instantiateViewController(storyboardName: .player, withIdentifier: "FilterClubViewController") as? FilterClubViewController {
                filterVC.delegate = self
                filterVC.setCurrentCheck(position: self.currentCheckPosition, club: self.currentCheckClub)
                filterVC.initBackView(title: "Player list".localiz())
                filterVC.showPosition = false
                controller.navigationController?.pushViewController(filterVC, animated: true)
            }
        }
    }
    
    func didClickSort(_ key: OrderProperty, _ direction: SortType) {
        self.updateOrderInfo(SortPlayerInfo(key, direction))
        switch position {
        case .all:
            self.pageAll = 1
            self.players.removeAll()
        case .attacker:
            self.pageAttackers = 1
            self.aPlayers.removeAll()
        case .defender:
            self.pageDeffenders = 1
            self.dPlayers.removeAll()
        case .midfielder:
            self.pageMiddefields = 1
            self.mPlayers.removeAll()
        case .goalkeeper:
            self.pageGoalKeepers = 1
            self.gPlayers.removeAll()
        }
        self.getPlayerList()
    }
}

// MARK: - Season
extension NewGlobalTransferPresenter {
    func setCurrentSeason(_ id: String) {
        self.modelRequest.season_id = id
    }
    
    func getCurrentSeason(callBack: @escaping (_ status: Bool) -> Void) {
        self.superView?.startLoading()
        SeasonService().getSeasonList { (response, status) in
            self.superView?.finishLoading()
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
                    if let currentSeason = response.currentSeason {
                        if let id = currentSeason.id {
                            self.modelRequest.current_season_id = id
                            self.setCurrentSeason(String(id))
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
}

// MARK: - Player list
extension NewGlobalTransferPresenter {
    
    func searchPlayers(_ key: String) {
        if key == modelRequest.keyword {
            return
        }
        modelRequest.keyword = key
        
        self.resetService()
        self.resetData()
        self.getPlayerList()
    }
    
    func loadMorePlayerList() {
        if isFullData() {
            return
        }
        self.getPlayerList()
    }
    
    func getPlayerList() {
        self.superView?.startLoading()
        
        if let player = pickingPlayer {
            modelRequest.from_player_id = player.id
        }
        modelRequest.position = self.position.positionSearch
        let orderInfo = self.orderInfo()
        let transferRequestModel = TransferRequestModel(property: orderInfo.property.rawValue, direction: orderInfo.sortType.rawValue)
        modelRequest.order = VFantasyCommon.validSortType([transferRequestModel])
        
        self.service?.page = self.currentPageFor(position: self.position)
        self.service?.getPlayerList(model: modelRequest, callBack: { (response, status) in
            self.superView?.finishLoading()
            
            if status, let data = response as? PlayerListData {
                self.handleSuccessResponse(response: data)
            } else {
                CommonResponse.handleResponseFail(response, self.superView)
            }
        })
    }
    
    func handleSuccessResponse(response: PlayerListData) {
        if response.meta?.success == false {
            if let message = response.meta?.message {
                self.superView?.alertMessage(message.localiz())
            }
            return
        }
        
        if let data = response.response?.data {
            data.forEach { (player) in
                // User when transfer player
                var newPlayer = player
                newPlayer.isAddNew = !self.isExistTransferPlayers(player)
                newPlayer.isEnoughMoneyForTransfer = self.isEnoughMoneyFor(player: player)
                if !self.isExistRemovePlayers(player) {
                    self.appendPlayer(player: newPlayer)
                }
            }
            
            if let selectingSeasonId = Int(modelRequest.season_id) {
                modelRequest.canPickDueToSelectedCorrectSeason = modelRequest.current_season_id == selectingSeasonId
            }
            
            self.increasePage()
        }
        self.updateAllPlayers(response.response?.total ?? 0)
        self.updateLastPage(response.response?.lastPage ?? 0)
        self.superView?.updateData()
    }
    
    func isExistRemovePlayers(_ player: Player) -> Bool {
        let exists = self.playerRemoves.filter({ return $0.id == player.id })
        return !exists.isEmpty
    }
    
    func isExistTransferPlayers(_ player: Player) -> Bool {
        let exists = self.playerLineupInfo.players.filter({ return $0.id == player.id })
        return !exists.isEmpty
    }
}

extension NewGlobalTransferPresenter: FilterClubViewControllerDelegate {
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
        self.modelRequest.clubID = clubIds.joined(separator: ",")
        
        self.resetService()
        self.resetData()
        self.getPlayerList()
    }
}

// MARK: - Get transfer data
extension NewGlobalTransferPresenter {
    func getTransferPlayerList() {
        self.superView?.startLoading()
        
        transferService.getTransferPlayerList(self.teamId, modelRequest) { [unowned self] (response, success) in
            if success {
                self.handleTransferPlayerListResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.superView)
            }
        }
    }
    
    func handleTransferPlayerListResponseSuccess(_ response: AnyObject) {
        superView?.finishLoading()
        if let result = response as? TransferPlayerListData {
            guard let meta = result.meta else { return }
            if meta.success == false {
                guard let message = meta.message else { return }
                superView?.alertMessage(message.localiz())
                print("Mess:", message.localiz())
                return
            }
            
            if let response = result.response {
                handleLineupResponse(response)
            }
            superView?.finishGetTransferData()
        }
    }
    
    private func handleLineupResponse(_ response: TransferPlayerListResponse) {
        if let gameWeek = response.nextGameWeek {
            nextGameWeek.id = gameWeek.id
            nextGameWeek.round = gameWeek.round
            nextGameWeek.startAt = gameWeek.startAt
            nextGameWeek.endAt = gameWeek.endAt
            nextGameWeek.title = gameWeek.title
        }
        
        if let transferDeadline = response.transferDeadline {
            self.transferGlobalModel.timeDeadline = transferDeadline
        }

//        if let injuredPlayers = response.injuredPlayers {
//            viewModel.injuredPlayers = injuredPlayers
//        }
//
//        if let timeLeft = response.transferTimeLeft {
//            viewModel.timeLeft = timeLeft
//            let (h,m,_) = timeLeft.secondsToHoursMinutesSeconds()
//            viewModel.timeLeftDisplay = "\(h)h\(m)"
//        }
//
//        if let playerLeft = response.transferPlayerLeftDisplay {
//            viewModel.playerLeft = playerLeft
//        }

        if let budget = response.team?.currentBudget {
            self.playerLineupInfo.budget = budget
        }

        if let maxTransferPlayer = response.maxTransferPlayer {
            self.transferGlobalModel.maxTransferPlayer = maxTransferPlayer
        }

        if let currentTransferPlayer = response.currentTransferPlayer {
            self.transferGlobalModel.currentTransferPlayer = currentTransferPlayer
        }

        transferLeft = transferGlobalModel.maxTransferPlayer - transferGlobalModel.currentTransferPlayer
        
        handleForPlayers(response)
        
        superView?.finishLoading()
    }
    
    private func handleForPlayers(_ response: TransferPlayerListResponse) {
        if let transferPlayers = response.players {
            playerLineupInfo.players = transferPlayers
            playersBegin = transferPlayers
            calValuePlayers(players: playerLineupInfo.players)
            playerLineupInfo.statistic = getStatistic(players: transferPlayers)
        }
    }
    
    private func calValuePlayers(players: [Player]) {
        let listValueOfPlayer = players.map {$0.transferValue}
        var sum = 0
        for value in listValueOfPlayer {
            guard let value = value else {return}
            sum = sum + value
        }
        sumValueOfPlayer = sum
    }
    
    private func getStatistic(players: [Player]) -> Statistic {
        let goalkeeper = players.filter({ $0.mainPosition == 0 }).count
        let defender = players.filter({ $0.mainPosition == 1 }).count
        let midfielder = players.filter({ $0.mainPosition == 2 }).count
        let attacker = players.filter({ $0.mainPosition == 3 }).count
        return Statistic(goalkeeper: goalkeeper, defender: defender, midfielder: midfielder, attacker: attacker)
    }
    
    func isEnoughMoneyFor(player: Player) -> Bool {
        let players = self.playerLineupInfo.players.filter({ return $0.mainPosition == player.mainPosition && ((Double($0.transferValue ?? 0) + (self.playerLineupInfo.budget ?? 0)) >= Double(player.transferValue ?? 0)) })
        return !players.isEmpty
    }
}

// MARK: - Complete Transfer
extension NewGlobalTransferPresenter {
    func transferPlayers(from old: [Player], to new: [Player]) {
        self.fromPlayers = old
        self.toPlayers = new
        modelRequestTransfer.fromListPlayerId = getFromPlayerList(old.map({ return $0.id ?? 0 }))
        modelRequestTransfer.toListPlayerId = getFromPlayerList(new.map({ return $0.id ?? 0 }))
        modelRequestTransfer.teamId = teamId
        
        guard !modelRequestTransfer.fromListPlayerId.isEmpty,
            !modelRequestTransfer.toListPlayerId.isEmpty else {
            return
        }
        
        superView?.startLoading()
        
        transferService.transferPlayer(modelRequestTransfer) { [unowned self] (response, status) in
            if status {
                self.handleTransferPlayerResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.superView)
            }
            self.superView?.finishLoading()
        }
    }
    
    func handleTransferPlayerResponseSuccess(_ response: AnyObject) {
        if let result = response as? TransferResponse {
            guard let meta = result.meta else {
                superView?.finishLoading()
                return
            }
            if meta.success == false {
                if let message = meta.message {
                    superView?.finishLoading()
                    self.superView?.completedTransfer(false, message)
                    return
                }
            }
            superView?.finishLoading()
            self.superView?.completedTransfer(true, "transfer_successfully")
        } else {
            superView?.finishLoading()
        }
    }
    
    func getFromPlayerList(_ playerIds: [Int]) -> String {
        return playerIds.map{String($0)}.joined(separator: ",")
    }
    
    func completedTransfer() {
        self.transferLeft -= self.fromPlayers.count
        
        let oldIds = self.fromPlayers.map({ return $0.id ?? 0 })
        let newIds = self.toPlayers.map({ return $0.id ?? 0 })
        self.playerLineupInfo.players.append(contentsOf: self.toPlayers)
        let exactPlayers = self.playerLineupInfo.players.filter({ return !oldIds.contains($0.id ?? 0) })
        self.playerLineupInfo.players = exactPlayers
        self.calValuePlayers(players: exactPlayers)
        self.playerLineupInfo.statistic = getStatistic(players: exactPlayers)
        
        //Update bank value
        var totalMoneyIn: Double = 0.0
        var totalMoneyOut: Double = 0.0
        for player in self.fromPlayers {
            totalMoneyIn += Double(player.transferValue ?? 0)
        }
        for player in self.toPlayers {
            totalMoneyOut += Double(player.transferValue ?? 0)
        }
        var budget = self.playerLineupInfo.budget ?? 0.0
        budget += totalMoneyIn
        budget -= totalMoneyOut
        self.playerLineupInfo.budget = budget
        
        //Update players
        for index in 0..<self.players.count {
            var player = self.players[index]
            let isEnough = self.isEnoughMoneyFor(player: player)
            player.setIsEnoughMoney(isEnough)
            self.players[index] = player
        }
        for index in 0..<self.aPlayers.count {
            var player = self.aPlayers[index]
            let isEnough = self.isEnoughMoneyFor(player: player)
            player.setIsEnoughMoney(isEnough)
            self.aPlayers[index] = player
        }
        for index in 0..<self.dPlayers.count {
            var player = self.dPlayers[index]
            let isEnough = self.isEnoughMoneyFor(player: player)
            player.setIsEnoughMoney(isEnough)
            self.dPlayers[index] = player
        }
        for index in 0..<self.mPlayers.count {
            var player = self.mPlayers[index]
            let isEnough = self.isEnoughMoneyFor(player: player)
            player.setIsEnoughMoney(isEnough)
            self.mPlayers[index] = player
        }
        for index in 0..<self.gPlayers.count {
            var player = self.gPlayers[index]
            let isEnough = self.isEnoughMoneyFor(player: player)
            player.setIsEnoughMoney(isEnough)
            self.gPlayers[index] = player
        }
        
        for id in oldIds {
            if let index = self.players.firstIndex(where: { return $0.id == id }) {
                self.players[index].isAddNew = true
            }
            switch self.position {
            case .attacker:
                if let index = self.aPlayers.firstIndex(where: { return $0.id == id }) {
                    self.aPlayers[index].isAddNew = true
                }
            case .midfielder:
                if let index = self.mPlayers.firstIndex(where: { return $0.id == id }) {
                    self.mPlayers[index].isAddNew = true
                }
            case .defender:
                if let index = self.dPlayers.firstIndex(where: { return $0.id == id }) {
                    self.dPlayers[index].isAddNew = true
                }
            case .goalkeeper:
                if let index = self.gPlayers.firstIndex(where: { return $0.id == id }) {
                    self.gPlayers[index].isAddNew = true
                }
            default:
                break
            }
        }
        
        for id in newIds {
            if let index = self.players.firstIndex(where: { return $0.id == id }) {
                self.players[index].isAddNew = false
            }
            switch self.position {
            case .attacker:
                if let index = self.aPlayers.firstIndex(where: { return $0.id == id }) {
                    self.aPlayers[index].isAddNew = false
                }
            case .midfielder:
                if let index = self.mPlayers.firstIndex(where: { return $0.id == id }) {
                    self.mPlayers[index].isAddNew = false
                }
            case .defender:
                if let index = self.dPlayers.firstIndex(where: { return $0.id == id }) {
                    self.dPlayers[index].isAddNew = false
                }
            case .goalkeeper:
                if let index = self.gPlayers.firstIndex(where: { return $0.id == id }) {
                    self.gPlayers[index].isAddNew = false
                }
            default:
                break
            }
        }
        
        self.fromPlayers.removeAll()
        self.toPlayers.removeAll()
        
        self.superView?.updateData()
    }
}
