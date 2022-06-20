//
//  TeamLineupDraftPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation
import UIKit

enum DraftStatus {
    case waitingForStart, waitingForServer
    case started, finished
    case inactive
}

protocol TeamLineupDraftView: NSObjectProtocol {
    func reloadData()
    func beginLoading()
    func stopLoading()
    func alertMessage(_ message: String)
    func changeContentViewController(_ type: LineupDraft)
    func updateTeamList(_ teams: [Team])
    func updatePickHistory()
    func joinedDraft()
    func endedCountDown()
}

class TeamLineupDraftPresenter: NSObject {
    private var serviceTeamListTeam = TeamLineupDraftService()
    private var serviceTeamListPick = TeamLineupDraftService()
    
    weak private var view: TeamLineupDraftView?
    
    var modelRequest = TeamLineupDraftModel()
    var typeView: LineupDraft = .lineup
    
    var draftStatus: DraftStatus = .waitingForStart
    var timeLeft = 0
    
    var socketPickingPlayer: Player? //Track selecting player in a specific turn
    
    //MARK:- init TeamList
    var pickHistory = [PickHistory]()
    
    func attachView(view: TeamLineupDraftView) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    //MARK: Utils
    func userIsPicking() -> Bool {
        if let current = modelRequest.socketTurnReceiveData?.getCurrentTeam() {
            return current.id == modelRequest.teamId
        }
        return false
    }
    
    func updateSocketResponse(_ response: TurnReceiveData) {
        modelRequest.socketTurnReceiveData = response
    }
    
    // MARK: - Team List
    func getTeamList() {
        view?.beginLoading()
        serviceTeamListTeam.getTeams(modelRequest) { response, success in
            if success {
                self.handleGetTeamSuccess(response)
            } else {
                self.handleResponseFail(response)
            }
        }
    }
    
    private func handleResponseFail(_ response: AnyObject) {
        if let message = response as? String {
            view?.alertMessage(message.localiz())
        } else if let error = response as? NSError, error.domain == NSURLErrorDomain {
            view?.alertMessage("no_internet".localiz())
        }
    }
    
    private func handleGetTeamSuccess(_ response: AnyObject) {
        if let response = response as? LeagueTeamsData {
            if let meta = response.meta {
                guard (meta.success ?? false) else {
                    if let message = meta.message {
                        self.view?.alertMessage(message.localiz())
                    }
                    return
                }
                
                if let data = response.response {
                    if let newData = data.data {
                        if newData.count > 0 {
                            view?.updateTeamList(newData)
                        }
                    }
                }
            }
        }
        
        view?.stopLoading()
    }
    
    // MARK: - Pick history
    func refreshPickHistory() {
        serviceTeamListPick.page = 1
        pickHistory.removeAll()
        
        getPickHistory()
    }
    
    func loadMorePickHistory() {
        if modelRequest.canLoadMorePickHistory {
            getPickHistory()
        }
    }
    
    func getPickHistory() {
        view?.beginLoading()
        serviceTeamListPick.getPickHistory(modelRequest) { (response, success) in
            if success {
                self.handlePickHistoryRequestSuccess(response)
            } else {
                self.handleResponseFail(response)
            }
        }
    }
    
    private func handlePickHistoryRequestSuccess(_ response: AnyObject) {
        if let response = response as? PickHistoryData {
            if let meta = response.meta {
                guard (meta.success ?? false) else {
                    if let message = meta.message {
                        self.view?.alertMessage(message.localiz())
                    }
                    return
                }
                
                if let data = response.response {
                    modelRequest.canLoadMorePickHistory = data.nextPageURL != nil
                    
                    if let newData = data.data {
                        pickHistory += newData
                        serviceTeamListPick.page += 1
                    }
                }
            }
        }
        
        view?.updatePickHistory()
        view?.stopLoading()
    }
    
    // MARK: - Call API End Countdown to get time left
    func getTimeLeft() {
        TeamLineupDraftService().endCountDown(modelRequest) { (response, success) in
            if success {
                if let response = response as? EndCountDownData {
                    if let meta = response.meta {
                        guard (meta.success ?? false) else {
                            if let message = meta.message {
                                self.view?.alertMessage(message.localiz())
                            }
                            return
                        }
                        
                        if let timeLeft = response.response?.draftTimeLeft {
                            self.timeLeft = timeLeft
                        }
                        self.view?.endedCountDown()
                    }
                }
                self.view?.stopLoading()
            }
        }
    }
    
    // MARK: - End turn
    func endTurn() {
        if let current = modelRequest.socketTurnReceiveData?.getCurrentTeam() {
            serviceTeamListPick.endTurn(modelRequest.teamId, data: current) { (response, success) in
                if success {
                    self.handleEndTurnRequestSuccess(response)
                } else {
                    self.handleResponseFail(response)
                }
            }
        }
    }
    
    private func handleEndTurnRequestSuccess(_ response: AnyObject) {
        if let response = response as? EndTurnData {
            if let meta = response.meta {
                guard (meta.success ?? false) else {
                    if let message = meta.message {
                        self.view?.alertMessage(message.localiz())
                    }
                    return
                }
            }
        }
    }
    
    // MARK: - Add/Remove Player
    func addPlayer(with player: Player) {
        if socketPickingPlayer != nil { return }
        socketPickingPlayer = player
//        guard let data = modelRequest.socketTurnReceiveData else { return }
//        SocketIOManager.sharedInstance.emitEventAddPlayer(with: data, and: player)
    }
    
    func removePlayer(with player: Player) {
//        guard let data = modelRequest.socketTurnReceiveData else { return }
//        SocketIOManager.sharedInstance.emitEventRemovePlayer(with: data, and: player)
    }
}

// MARK: - delegate CustomPageContol
extension TeamLineupDraftPresenter: CustomPageControlDelegate {
    func currentIndex(indexPath: IndexPath) {
        switch indexPath.row {
        case LineupDraft.lineup.rawValue:
            self.typeView = .lineup
        case LineupDraft.player_list.rawValue:
            self.typeView = .player_list
        case LineupDraft.team_list.rawValue:
            self.typeView = .team_list
        default:
            break
        }
        self.view?.changeContentViewController(self.typeView)
    }
}
