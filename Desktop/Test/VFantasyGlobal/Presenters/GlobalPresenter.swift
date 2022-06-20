//
//  NewGlobalPresenter.swift
//  PAN689
//
//  Created by Quang Tran on 7/14/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import Foundation
import UIKit

protocol NewGlobalView: BaseViewProtocol {
    func reloadHeader(_ isCompleted: Bool)
    func reloadPitchTeam()
    func reloadBankPlayers()
    func gotoFollowPlayDay()
    func reloadStatsPlayers(_ type: PlayerStatsType, _ data: [Player])
    func reloadTeamOTWeek(_ players: [Player])
}

class NewGlobalPresenter: NSObject {
    weak private var superView: NewGlobalView?

    private var service: GlobalServices? = nil
    private var pointService: GlobalPointsService = GlobalPointsService()
    private var squadService: GlobalSquadService = GlobalSquadService()
    private var matchService: MatchResultsService = MatchResultsService()
    private var statsService: GlobalStatsService = GlobalStatsService()

    var keyword: String = ""
    var isTeamOTWeek: Bool = false
    var teamId: Int = 0
    var allTeams: [MyTeamData] = []
    var myTeam: MyTeamData?
    var pitchData: PitchTeamData?
    var model: GlobalPointsRequestModel = GlobalPointsRequestModel()
    var players: [Player] = []
    var playersOTWeek: [Player] = []
    var currentGW: GameWeek?
    
    var matchModel: MatchResultsModel = MatchResultsModel()
    var realMatchesDisplay = [MatchGroup]()
    private var realMatches = [String : [RealMatch]]()

    init(service: GlobalServices) {
        super.init()
        self.service = service
    }
    
    func attachView(view: NewGlobalView) {
        self.superView = view
    }
    
    func autoNextPageWhenViewAllStats() {
        self.statsService.page += 1
        self.statsService.isFullData = false
    }
    
    func resetViewAllStats(_ keyword: String) {
        self.statsService.page = 1
        self.statsService.isFullData = false
        self.keyword = keyword
    }
}

//MARK: - All my teams
extension NewGlobalPresenter {
    func getAllMyTeams(_ completion: @escaping (_ data: [MyTeamData]) -> Void) {
        self.superView?.startLoading()
        service?.getMyTeams({ (result, status) in
            self.superView?.finishLoading()
            if !status {
                CommonResponse.handleResponseFail(result, self.superView)
                if let myTeam = self.myTeam {
                    completion([myTeam])
                } else {
                    completion([])
                }
            } else {
                self.allTeams.removeAll()
                if let result = result as? GlobalMyTeams {
                    self.allTeams = result.response?.data ?? []
                }
                completion(self.allTeams)
            }
        })
    }
}

//MARK: - Info My Team
extension NewGlobalPresenter {
    func getInfoMyTeam() {
        superView?.startLoading()
        service?.getDetailTeam(self.teamId, self.model.realRoundId, callBack: { (result, status) in
            self.handleMyTeamCallback(result, status)
        })
    }
    
    private func handleMyTeamCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleMyTeamResponseSuccess(result)
        }
    }
    
    private func handleMyTeamResponseSuccess(_ response: AnyObject) {
        superView?.finishLoading()
        var isCompletedTeam = false
        if let result = response as? GlobalMyTeam {
            self.myTeam = result.response
            if let isCompleted = self.myTeam?.isCompleted, isCompleted == true {
                isCompletedTeam = true
            }
        }
        superView?.reloadHeader(isCompletedTeam)
    }
}

//MARK: - Gameweek
extension NewGlobalPresenter {
    func getListGameweekForTeamID(_ completion: @escaping (_ data: [GameWeek]) -> Void) {
        superView?.startLoading()
        pointService.getGameweekList(self.teamId, callback: { (result, status) in
            self.superView?.finishLoading()
            if !status {
                CommonResponse.handleResponseFail(result, self.superView)
            } else {
                if let result = result as? GameWeekModel {
                    completion(result.response ?? [])
                } else {
                    completion([])
                }
            }
        })
    }
}

//MARK: - Change formation
extension NewGlobalPresenter {
    func changeFormation(formation: String) {
        let players: [Player] = self.pitchData?.players ?? []
        superView?.startLoading()
        pointService.changeFormation(self.teamId, formation, pitchData?.team?.round ?? 0, callback: { (result, status) in
            self.handlePitchTeamCallback(result, status)
            self.autoMappingOldFormation(players, formation)
        })
    }
    
    func autoMappingOldFormation(_ oldPlayer: [Player], _ newFormation: String) {
        guard let formation = FormationTeam(rawValue: newFormation) else { return }
        guard let data = ShadowData.getFormations(key: formation.rawValue) else { return }
        let positions: [PositionType] = [.GK, .CB, .CM, .CF]
        var updatedData: [DataFormationChange] = []
        for indexPosition in 0..<positions.count {
            let position = positions[indexPosition]
            var olds = oldPlayer.filter({ return $0.position == position.position })
            olds = olds.sorted(by: { (player1, player2) -> Bool in
                return (player1.order ?? 0) < (player2.order ?? 0)
            })
            if olds.isEmpty {
                continue
            }
            guard let positionData = data[position.rawValue] as? [Point] else { continue }
            let count = min(olds.count, positionData.count)
            for index in 0..<count {
                updatedData.append(DataFormationChange(player: olds[index], position: PositionPlayer(type: position, index: index + 1)))
            }
        }
        self.callAPI(0, updatedData)
    }
    
    func callAPI(_ index: Int, _ updatedData: [DataFormationChange]) {
        if index == updatedData.count || updatedData.isEmpty {
            return
        }
        self.addPlayer(from: nil, to: updatedData[index].player, to: updatedData[index].position) {
            self.callAPI(index + 1, updatedData)
        }
    }
    
    func addPlayer(from: Player?, to: Player, to position: PositionPlayer, _ completion: (() -> Void)? = nil) {
        superView?.startLoading()
        pointService.addPlayer(teamId, from: from, to: to, position, pitchData?.team?.round ?? 0, callback: { (result, status) in
            self.handlePitchTeamCallback(result, status)
            completion?()
        })
    }
}

//MARK: - Pitch team
extension NewGlobalPresenter {
    func getInfoPitchTeam() {
        guard let teamId = self.myTeam?.id else { return }
        superView?.startLoading()
        pointService.getPitchTeamInfo(teamId, model, callback: { (result, status) in
            self.handlePitchTeamCallback(result, status)
            self.getGlobalSquadInfo()
        })
    }
    
    private func handlePitchTeamCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handlePitchTeamResponseSuccess(result)
        }
    }
    
    private func handlePitchTeamResponseSuccess(_ response: AnyObject) {
        if let result = response as? PitchTeamModel {
            self.pitchData = result.response
            self.currentGW = self.pitchData?.currentGW
            self.model.formation = self.pitchData?.team?.formation ?? FormationTeam.team_442.rawValue
        }
        superView?.finishLoading()
        superView?.reloadPitchTeam()
        self.sortSquadView()
    }
}

//MARK: - Squad
extension NewGlobalPresenter {
    func getGlobalSquadInfo() {
        guard let team = self.myTeam else { return }
        superView?.startLoading()
        squadService.getGlobalSquad(teamId: team.id ?? 0, roundId: self.currentGW?.id ?? 0, { [weak self] (result, status) in
            self?.handleSquadCallback(result, status)
        })
    }

    private func handleSquadCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
            self.players.removeAll()
            superView?.reloadBankPlayers()
        } else {
            self.handleSquadResponseSuccess(result)
        }
    }

    private func handleSquadResponseSuccess(_ response: AnyObject) {
        self.players.removeAll()
        superView?.finishLoading()
        if let result = response as? SquadData {
            self.players = result.response?.players ?? []
            self.players = self.players.sorted(by: { ($0.mainPosition ?? 0) > ($1.mainPosition ?? 0) })
        }
        self.sortSquadView()
    }
    
    private func sortSquadView() {
        //PAN-138
        let teamIds: [Int] = (self.pitchData?.players ?? []).map({ return $0.id ?? -1 }).filter({ return $0 != -1 })
        let existPlayers: [Player] = self.players.filter({ return teamIds.contains($0.id ?? 0) })
        let notExistPlayers: [Player] = self.players.filter({ return !teamIds.contains($0.id ?? 0) })
        self.players.removeAll()
        self.players.append(contentsOf: existPlayers)
        self.players.append(contentsOf: notExistPlayers)
        superView?.reloadBankPlayers()
    }
}

//MARK: - Follow
extension NewGlobalPresenter {
    func getRealMatch() {
        matchService.page = 1
        matchModel.round = ""
        superView?.startLoading()
        matchService.getFollowPlayDay { [unowned self] (response, success) in
            if success {
                self.handleRealResultsSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.superView)
            }
        }
    }
    
    func handleRealResultsSuccess(_ res: AnyObject) {
        superView?.finishLoading()
        realMatches.removeAll()
        realMatchesDisplay.removeAll()
        if let response = res as? RealMatchData {
            if let meta = response.meta {
                guard (meta.success ?? false) else {
                    if let message = meta.message {
                        self.superView?.alertMessage(message.localiz())
                    }
                    superView?.gotoFollowPlayDay()
                    return
                }
                
                if let data = response.response {
                    if let matches = data.data {
                        if matches.count == 0 {
                            superView?.gotoFollowPlayDay()
                            return
                        } else {
                            if let round = data.round {
                                matchModel.round = String(round)
                            }
                            groupRealMatches(matches)
                            matchModel.canLoadMoreRealResults = data.nextPageURL != nil
                            matchService.page += 1
                        }
                    }
                }
            }
        }
        superView?.gotoFollowPlayDay()
    }
    
    func groupRealMatches(_ input: [RealMatch]) {
        //Create dictionary with:
        //- key: endAt date
        //- value: RealMatch array
        let dictInput = input.reduce(into: [String : [RealMatch]]()) {
            $0[$1.getStartTime(), default: []].append($1)
        }
        //Append new values to realMatches dictionary
        dictInput.forEach { (key, values) in
            if realMatches[key] == nil {
                realMatches.updateValue(values, forKey: key)
            } else {
                realMatches[key]! += values
            }
        }
        for (key, value) in realMatches {
            realMatches[key] = value.sorted(by: { (match1, match2) -> Bool in
                return match1.delayStartAt?.toDate ?? Date() < match2.delayStartAt?.toDate ?? Date()
            })
        }
        //Sort dictionary to MatchGroup array for display
        realMatchesDisplay = realMatches.sorted(by: { $0.0.timeToDate! < $1.0.timeToDate! })
    }
}

//MARK: - Stats
extension NewGlobalPresenter {
    func getPlayersStats(from type: PlayerStatsType, showHUD: Bool, isViewAll: Bool) {
        if isViewAll && statsService.isFullData {
            return
        }
        if showHUD {
            self.superView?.startLoading()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        statsService.getPlayerStats(type: type, key: self.keyword) { (result, status) in
            self.handlePlayersStatsCallback(result, status, type, isViewAll)
        }
    }

    private func handlePlayersStatsCallback(_ result: AnyObject, _ status: Bool, _ type: PlayerStatsType, _ isViewAll: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if !status {
            CommonResponse.handleResponseFail(result, superView)
            self.superView?.reloadStatsPlayers(type, [])
        } else {
            self.handlePlayersStatsResponseSuccess(result, type, isViewAll)
        }
        self.superView?.finishLoading()
    }

    private func handlePlayersStatsResponseSuccess(_ response: AnyObject, _ type: PlayerStatsType, _ isViewAll: Bool) {
        if let response = response as? PlayersStatsData {
            if let data = response.response {
                let players = data.data ?? []
                if isViewAll {
                    self.statsService.isFullData = data.nextPageURL == nil
                    self.statsService.page += 1
                }
                self.superView?.reloadStatsPlayers(type, players)
            } else {
                if isViewAll {
                    self.statsService.isFullData = true
                }
                self.superView?.reloadStatsPlayers(type, [])
            }
        } else {
            if isViewAll {
                self.statsService.isFullData = true
            }
        }
    }
}

// MARK: - Check transfer
extension NewGlobalPresenter {
    func validateTransfer(_ complete: @escaping (Bool, String) -> Void) {
        superView?.startLoading()
        service?.getValidateTransfer(teamID: self.myTeam?.id ?? 0, real_round_id: self.currentGW?.id, { (response, status) in
            self.superView?.finishLoading()
            if !status {
                if let message = response as? String {
                    complete(false, message)
                } else if let error = response as? NSError, error.domain == NSURLErrorDomain {
                    complete(false, "no_internet".localiz())
                }
            } else {
                if let result = response as? GlobalTransferDeadline {
                    if let meta = result.meta {
                        if meta.success == true {
                            complete(true, meta.message?.localiz() ?? "")
                        } else {
                            complete(false, meta.message?.localiz() ?? "")
                        }
                    }
                } else {
                    complete(false, "")
                }
            }
        })
    }
}

//MARK: - Team O/T Week
extension NewGlobalPresenter {
    func getTeamOTWeek(roundId: Int) {
        superView?.startLoading()
        service?.getTeamOfTheWeek(roundId: roundId, { (result, status) in
            self.handleTeamOTWeekCallback(result, status)
        })
    }
    
    private func handleTeamOTWeekCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleTeamOTWeekResponseSuccess(result)
        }
    }
    
    private func handleTeamOTWeekResponseSuccess(_ response: AnyObject) {
        superView?.finishLoading()
        if let result = response as? GlobalTeamOTWeek {
            self.currentGW = result.response?.gameweek
            self.playersOTWeek = result.response?.players ?? []
        } else {
            self.playersOTWeek = []
        }
        superView?.reloadTeamOTWeek(self.playersOTWeek)
    }
}
