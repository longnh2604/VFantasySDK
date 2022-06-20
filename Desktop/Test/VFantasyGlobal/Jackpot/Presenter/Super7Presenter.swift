//
//  Super7Presenter.swift
//  PAN689
//
//  Created by Quang Tran on 12/27/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol Super7GlobalView: BaseViewProtocol {
    func updatedSuper7Team()
    func reloadSuper7Team()
    func reloadSuper7League()
    func reloadSuper7PitchView()
    func reloadPlayerList()
    func reloadSuper7DreamTeams()
}

class Super7Presenter: NSObject {
    weak private var superView: Super7GlobalView?
    
    private var service: Super7Service? = nil
    private var playerService: PlayerListService = PlayerListService()

    var playerRequest: PlayerRequestModel = PlayerRequestModel()
    var super7CreateModel: CreateSuper7Model = CreateSuper7Model()
    var super7Team: MyTeamData?
    var super7League: League?
    var super7PitchData: Super7PitchTeamData?
    var currentGW: GameWeek?
    var super7DreamTeams: [Super7DreamTeam] = []
    var players: [Player] = []
    var real_round_id: Int?
    var isLoading: Bool = false
    
    var matchRows: Int { return self.super7PitchData?.matches.count ?? 0 }
    var selectionPlayers: [Player] {
        if let matches = self.super7PitchData?.matches {
            return matches.filter({ return $0.selected_player != nil }).map({ return $0.selected_player! })
        }
        return []
    }
    var deadline: Date { return self.super7PitchData?.deadline ?? Date() }
    var isEndDeadline: Bool { return self.super7PitchData?.isEndDeadline ?? true }
    var teamId: Int { return self.super7Team?.id ?? 0 }
    
    func resetPlayerPage() {
        playerService.page = 1
        playerService.isFullData = false
    }
    
    init(service: Super7Service) {
        super.init()
        self.service = service
    }
    
    func attachView(view: Super7GlobalView) {
        self.superView = view
    }
    
    func updatePerpageForPlayer() {
        self.playerService.per_page = 40
    }
}

// MARK: - Super 7 Teams
extension Super7Presenter {
    func getInfoSuper7Team() {
        superView?.startLoading()
        service?.getSuper7MyTeam({ [weak self] (result, status) in
            self?.superView?.finishLoading()
            self?.handleSuper7TeamCallback(true, result, status)
        })
    }
    
    func createSuper7Team() {
        superView?.startLoading()
        service?.createSuper7Team(super7CreateModel, callBack: { [weak self] (result, status) in
            self?.superView?.finishLoading()
            self?.handleSuper7TeamCallback(false, result, status)
        })
    }
    
    func editSuper7Team() {
        superView?.startLoading()
        service?.editSuper7Team(super7CreateModel, callBack: { [weak self] (result, status) in
            self?.superView?.finishLoading()
            self?.handleSuper7TeamCallback(false, result, status)
        })
    }
    
    func getDetailSuper7Team(_ teamId: Int, _ real_round_id: Int) {
        superView?.startLoading()
        service?.getSuper7TeamDetail(teamId, real_round_id, { [weak self] (result, status) in
            self?.superView?.finishLoading()
            self?.handleSuper7TeamCallback(true, result, status)
        })
    }
    
    private func handleSuper7TeamCallback(_ isGetInfo: Bool, _ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleSuper7TeamResponse(isGetInfo, result)
        }
    }
    
    func handleSuper7TeamResponse(_ isGetInfo: Bool, _ response: AnyObject) {
        if let result = response as? Super7TeamModel {
            guard let meta = result.meta else { return }
            if meta.success == false {
                guard let message = meta.message else { return }
                superView?.alertMessage(message.localiz())
                return
            }
            
            if let data = result.response {
                self.super7Team = data
            }
            
            if isGetInfo {
                self.superView?.reloadSuper7Team()
            } else {
                self.superView?.updatedSuper7Team()
            }
        }
    }
}

// MARK: - Super 7 Leaguges
extension Super7Presenter {
    func getSuper7League() {
        service?.getSuper7League({ response, status in
            self.handleSuperLeagueCallback(response, status)
        })
    }
    
    private func handleSuperLeagueCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleSuperLeagueResponse(result)
        }
    }
    
    func handleSuperLeagueResponse(_ response: AnyObject) {
        if let result = response as? Super7LeagueModel {
            self.super7League = result.response
        }
        self.superView?.reloadSuper7League()
    }
}

// MARK: - Super 7 Pitchview
extension Super7Presenter {
    func getSuper7PitchData() {
        self.superView?.startLoading()
        service?.getSuper7PitchData(self.teamId, real_round_id, { response, status in
            self.superView?.finishLoading()
            self.handleSuper7PitchTeamCallback(response, status)
        })
    }
    
    private func handleSuper7PitchTeamCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleSuper7PitchTeamResponse(result)
        }
    }
    
    func handleSuper7PitchTeamResponse(_ response: AnyObject) {
        if let result = response as? Super7PitchTeamModel {
            self.super7PitchData = result.response
            self.currentGW = result.response?.currentGW
        } else {
            self.super7PitchData = nil
        }
        self.superView?.reloadSuper7PitchView()
    }
    
    func updateSuper7PitchView(_ player: Player, _ match_id: Int) {
        self.superView?.startLoading()
        service?.updateSuper7PitchData(self.teamId, self.super7PitchData?.transferRound?.round ?? 0, player, match_id, { response, status in
            self.superView?.finishLoading()
            self.handleSuper7PitchTeamCallback(response, status)
        })
    }
}

// MARK: - Super 7 Players
extension Super7Presenter {
    func loadMorePlayers() {
        if self.playerService.isFullData {
            return
        }
        self.getPlayerList()
    }
    
    func getPlayerList() {
        if self.playerService.isFullData { return }
        superView?.startLoading()
        playerService.getPlayerList(model: playerRequest) { response, status in
            self.superView?.finishLoading()
            if status {
                self.handlePlayersListResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.superView)
            }
        }
    }
    
    private func handlePlayersListResponseSuccess(_ response: AnyObject) {
        if let result = response as? PlayerListData {
            if playerService.page == 1 {
                players.removeAll()
            }
            
            if let res = result.response {
                let data = res.data ?? [Player]()
                players += data
                playerService.isFullData = res.nextPageURL == nil
            } else {
                playerService.isFullData = true
            }
            playerService.page += 1
        }
        self.superView?.reloadPlayerList()
    }
}

// MARK: - Super 7 Auto pick
extension Super7Presenter {
    func autoPickPlayers() {
        superView?.startLoading()
        service?.autoPickPlayers(self.teamId) { (response, success) in
            self.superView?.finishLoading()
            if success {
                self.handleAutoPickPlayersResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.superView)
            }
        }
    }
    
    func handleAutoPickPlayersResponseSuccess(_ response: AnyObject) {
        if let _ = response as? AutoPickPlayersData {
            self.getSuper7PitchData()
        }
    }
}

//MARK: - Super 7 Gameweeks
extension Super7Presenter {
    func getListGlobalGameweeks(_ completion: @escaping (_ data: [GameWeek]) -> Void) {
        superView?.startLoading()
        service?.per_page = 50
        service?.getGlobalGameweekList(callback: { response, status in
            self.superView?.finishLoading()
            if !status {
                CommonResponse.handleResponseFail(response, self.superView)
            } else {
                if let result = response as? GlobalGameWeekModel {
                    completion(result.response?.data ?? [])
                } else {
                    completion([])
                }
            }
        })
    }
    
    func getListSuper7Gameweeks(_ completion: @escaping (_ data: [GameWeek]) -> Void) {
        superView?.startLoading()
        service?.per_page = 50
        service?.getSuper7GameweekList(callback: { response, status in
            self.superView?.finishLoading()
            if !status {
                CommonResponse.handleResponseFail(response, self.superView)
            } else {
                if let result = response as? GlobalGameWeekModel {
                    completion(result.response?.data ?? [])
                } else {
                    completion([])
                }
            }
        })
    }
}

// MARK: - Super 7 Pitchview
extension Super7Presenter {
    func getSuper7DreamTeams(real_round_id: Int, showHUD: Bool) {
        if isLoading {
            return
        }
        isLoading = true
        if showHUD {
            self.superView?.startLoading()
        }
        service?.getSuper7DreamTeams(real_round_id, callback: { response, status in
            if showHUD {
                self.superView?.finishLoading()
            }
            self.handleSuper7DreamTeamsCallback(response, status)
        })
    }
    
    private func handleSuper7DreamTeamsCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleSuper7DreamTeamsResponse(result)
        }
    }
    
    func handleSuper7DreamTeamsResponse(_ response: AnyObject) {
        if let result = response as? Super7DreamTeamsModel {
            print("Winnerrrs: \(result.response?.winners.count ?? 0)")
            if let dreamTeam = result.response {
                self.super7DreamTeams.append(dreamTeam)
            }
        }
        self.superView?.reloadSuper7DreamTeams()
        self.isLoading = false
    }
}
