//
//  TransferGlobalPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation
import UIKit

protocol TransferGlobalView : BaseViewProtocol {
    func reloadView()
    func updateBudget()
    func completedTransfer(_ status: Bool, _ message: String)
    func reloadLineup()
    func alert(_ message: String)
}

class TransferGlobalPresenter: NSObject {
    
    weak private var view: TransferGlobalView?
    var playerLineupInfo = TeamPlayerInfo()
    var nextGameWeek = GameWeekInfo()
    var playersBegin = [Player]()
    
    var modelRequest = PlayerRequestModel()
    var modelRequestTransfer = TransferPlayerRequestModel()
    var teamID = 0
    var viewModel = TransferViewModel()
    
    var myTeam: MyTeamData?
    
    var fromListPlayerId = [Int]()
    var toListPlayerId = [Int]()
    
    var attackers = [Player?]()
    var midfielders = [Player?]()
    var defenders = [Player?]()
    var goalkeepers = [Player?]()
    
    var playerRemoves = [Player]()
    var transferStatus: Bool = false
    
    private let randomIndex = -1
    
    private var service = TransferGlobalService()
    var transferGlobalModel = TransferGlobalModel()
    
    var sumValueOfPlayer = 0
    var transferLeft = 0
    
    var isOverPositions: Bool {
        return (18 - playerLineupInfo.players.count) >= transferLeft && transferLeft > 0
    }
    
    func attachView(view: TransferGlobalView) {
        self.view = view
        initPlayersForPosition()
    }
    
    private func initPlayersForPosition() {
        attackers = [nil, nil, nil, nil]
        midfielders = [nil, nil, nil, nil, nil, nil]
        defenders = [nil, nil, nil, nil, nil, nil]
        goalkeepers = [nil, nil]
    }
    
    func reloadPlayersForPosition() {
        initPlayersForPosition()
        
        let players = playerLineupInfo.players
        let count = players.count
        if count > 0 {
            for i in 0...count - 1 {
                let player = players[i]
                if let mainPos = player.mainPosition, let order = player.order {
                    //Check each Position,
                    //If order of player is random (picked from Android player list) -> order = -1 -> find available position for that player -> add to list
                    //Else if order != -1 (picked from iOS player list) -> add player to list
                    switch mainPos {
                    case PlayerPositionType.goalkeeper.rawValue:
                        if order == randomIndex {
                            if let newPos = VFantasyCommon.availablePositionIndex(goalkeepers) {
                                goalkeepers[newPos] = player
                            }
                        } else {
                            if order > 0 && order <= goalkeepers.count {
                                goalkeepers[order - 1] = player
                            }
                        }
                    case PlayerPositionType.defender.rawValue:
                        if order == randomIndex {
                            if let newPos = VFantasyCommon.availablePositionIndex(defenders) {
                                defenders[newPos] = player
                            }
                        } else {
                            if order > 0 && order <= defenders.count {
                                defenders[order - 1] = player
                            }
                        }
                    case PlayerPositionType.midfielder.rawValue:
                        if order == randomIndex {
                            if let newPos = VFantasyCommon.availablePositionIndex(midfielders) {
                                midfielders[newPos] = player
                            }
                        } else {
                            if order > 0 && order <= midfielders.count {
                                midfielders[order - 1] = player
                            }
                        }
                    default:
                        if order == randomIndex {
                            if let newPos = VFantasyCommon.availablePositionIndex(attackers) {
                                attackers[newPos] = player
                            }
                        } else {
                            if order > 0 && order <= attackers.count {
                                attackers[order - 1] = player
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Get data
    
    func getTransferPlayerList() {
        view?.startLoading()
        
        service.getTransferPlayerList(teamID, modelRequest) { [unowned self] (response, success) in
            if success {
                self.handleTransferPlayerListResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
    
    func handleTransferPlayerListResponseSuccess(_ response: AnyObject) {
        if let result = response as? TransferPlayerListData {
            guard let meta = result.meta else {
                view?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    view?.finishLoading()
                    return
                }
                view?.alertMessage(message.localiz())
                print("Mess:", message.localiz())
                return
            }
            
            if let response = result.response {
                handleLineupResponse(response)
                view?.finishLoading()
            }
            
            view?.finishLoading()
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
        
        if let injuredPlayers = response.injuredPlayers {
            viewModel.injuredPlayers = injuredPlayers
        }
        
        if let timeLeft = response.transferTimeLeft {
            viewModel.timeLeft = timeLeft
            let (h,m,_) = timeLeft.secondsToHoursMinutesSeconds()
            viewModel.timeLeftDisplay = "\(h)h\(m)"
        }
        
        if let playerLeft = response.transferPlayerLeftDisplay {
            viewModel.playerLeft = playerLeft
        }
        
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
        
        view?.finishLoading()
        view?.reloadView()
    }
    
    private func handleForPlayers(_ response: TransferPlayerListResponse) {
        if let transferPlayers = response.players {
            playerLineupInfo.players = transferPlayers
            playersBegin = transferPlayers
            calValuePlayers(players: playerLineupInfo.players)
            playerLineupInfo.statistic = getStatistic(players: transferPlayers)
        }
        reloadPlayersForPosition()
    }
    
    // MARK: - Remove player
    
    func removePlayer(_ player: Player) {
        guard let index = playerLineupInfo.players.firstIndex(of: player) else { return }
        
        if !playerLineupInfo.players[index].isAddNew {
            if transferLeft <= 0 {
                view?.alert("having_no_transfer_left".localiz())
                return
            } else if isOverPositions {
                view?.alert("over_positions".localiz())
                return
            }
        }
        
        if let topVC = UIApplication.getTopController() {
            topVC.alertWithTwoOptions("remove_player_title".localiz(), "Are you sure you want to remove this player from your team?".localiz()) {
                if self.playerLineupInfo.players[index].isAddNew {
                    self.transferLeft += 1
                }
                
                self.playerRemoves.append(self.playerLineupInfo.players[index])
                self.playerLineupInfo.players.remove(at: index)
                if self.playerLineupInfo.budget != nil {
                    self.playerLineupInfo.budget! += Double(player.transferValue ?? 0)
                }
                self.updateData(with: player)
                
                self.reloadPlayersForPosition()
                self.view?.reloadView()
            }
        }
    }
    
    private func updateData(with player: Player) {
        playerLineupInfo.statistic = getStatistic(players: playerLineupInfo.players)
        
        // Update budget
        calValuePlayers(players: playerLineupInfo.players)
    }
    
    // MARK: - Add player
    
    func addPlayer(_ player: Player) {
        let players: [Player] = playerLineupInfo.players.filter({ return $0.realClubID == player.realClubID })
        if players.count >= 3 {
            view?.alert("You cannot pick more than 3 players from the same club.".localiz())
            return
        }
        transferLeft -= 1
        playerLineupInfo.players.append(player)
        if playerLineupInfo.budget != nil {
            playerLineupInfo.budget! -= Double(player.transferValue ?? 0)
        }
        updateData(with: player)
        reloadPlayersForPosition()
        view?.reloadView()
    }
    
    func calValuePlayers(players: [Player]) {
        let listValueOfPlayer = players.map {$0.transferValue}
        var sum = 0
        for value in listValueOfPlayer {
            guard let value = value else {return}
            sum = sum + value
        }
        sumValueOfPlayer = sum
    }
    
    func getStatistic(players: [Player]) -> Statistic {
        let goalkeeper = players.filter({ $0.mainPosition == 0 }).count
        let defender = players.filter({ $0.mainPosition == 1 }).count
        let midfielder = players.filter({ $0.mainPosition == 2 }).count
        let attacker = players.filter({ $0.mainPosition == 3 }).count
        return Statistic(goalkeeper: goalkeeper, defender: defender, midfielder: midfielder, attacker: attacker)
    }
    
    // MARK: - Complete Transfer
    
    func handleTransfer() {
        modelRequestTransfer.fromListPlayerId = getFromPlayerList()
        modelRequestTransfer.toListPlayerId = getToPlayerList()
        modelRequestTransfer.teamId = teamID
        
        guard !modelRequestTransfer.fromListPlayerId.isEmpty,
              !modelRequestTransfer.toListPlayerId.isEmpty else {
                  return
              }
        
        view?.startLoading()
        
        service.transferPlayer(modelRequestTransfer) { [unowned self] (response, status) in
            if status {
                self.handleTransferPlayerResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
            self.view?.finishLoading()
        }
    }
    
    func handleTransferPlayerResponseSuccess(_ response: AnyObject) {
        if let result = response as? TransferResponse {
            guard let meta = result.meta else {
                view?.finishLoading()
                return
            }
            if meta.success == false {
                if let message = meta.message {
                    view?.finishLoading()
                    self.view?.completedTransfer(false, message)
                    return
                }
            }
            
            for index in 0..<playerLineupInfo.players.count {
                playerLineupInfo.players[index].isAddNew = false
            }
            
            view?.finishLoading()
            transferStatus = true
            self.view?.completedTransfer(true, "transfer_successfully")
        }
    }
    
    func getFromPlayerList() -> String {
        return fromListPlayerId.map{String($0)}.joined(separator: ",")
    }
    
    func getToPlayerList() -> String {
        return toListPlayerId.map{String($0)}.joined(separator: ",")
    }
    
    func setPlayerListFromTo() {
        for row in 0...3 {
            var col = 6
            if row == 0 {
                col = 2
            } else if row == 3 {
                col = 4
            }
            for index in 1...col {
                let fromPlayerId = getPlayer(position: row, index: index, list: playersBegin)?.id ?? 0
                let toPlayerId = getPlayer(position: row, index: index, list: playerLineupInfo.players)?.id ?? 0
                if fromPlayerId != toPlayerId {
                    fromListPlayerId.append(fromPlayerId)
                    toListPlayerId.append(toPlayerId)
                }
            }
        }
    }
    
    private func getPlayer(position: Int, index: Int, list: [Player]) -> Player? {
        return list.filter({ $0.mainPosition == position && $0.order == index }).first
    }
    
    func getMessageValidateForTransfer() -> String {
        if playerLineupInfo.players.count < MAX_PLAYERS {
            return "You are not able to access this screen because this team lineup is not completed yet"
        }
        if (playerLineupInfo.budget ?? 0.0) < 0.0 {
            return "current_budget_is_not_enough"
        }
        return ""
    }
}
