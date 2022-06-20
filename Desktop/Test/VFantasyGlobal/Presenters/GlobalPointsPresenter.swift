//
//  GlobalPointsPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

protocol GlobalPointsView: BaseViewProtocol {
    func reloadPitchTeam()
    func reloadWeekView(_ data: [CheckBoxData])
    func errorGetPitchTeam()
}

class GlobalPointsPresenter: NSObject {
    
    private var service: GlobalPointsService? = nil
    weak private var pointsView: GlobalPointsView?
    
    var teamId: Int = 0
    var model: GlobalPointsRequestModel = GlobalPointsRequestModel()
    var data: PitchTeamData?
    var isShowPlayerDetail = true
    
    init(service: GlobalPointsService) {
        super.init()
        self.service = service
    }
    func attachView(view: GlobalPointsView) {
        self.pointsView = view
    }
    
    func getDataFormation() -> [CheckBoxData] {
        let formations: [FormationTeam] = [.team_442, .team_433, .team_352, .team_343, .team_532, .team_541]
        return formations.map { (formation) -> CheckBoxData in
            return CheckBoxData(formation.rawValue, formation.rawValue, formation.rawValue)
        }
    }
    
    //MARK: Pitch team
    func getInfoPitchTeam() {
        pointsView?.startLoading()
        service?.getPitchTeamInfo(teamId, model, callback: { (result, status) in
            self.handlePitchTeamCallback(result, status)
        })
    }
    
    func getInfoPoints() {
        pointsView?.startLoading()
        service?.getPoints(teamId, model, callback: { (result, status) in
            self.handlePitchTeamCallback(result, status)
        })
    }
    
    private func handlePitchTeamCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, pointsView)
        } else {
            self.handlePitchTeamResponseSuccess(result)
        }
    }
    
    private func handlePitchTeamResponseSuccess(_ response: AnyObject) {
        if let result = response as? PitchTeamModel {
            guard let meta = result.meta else {
                pointsView?.errorGetPitchTeam()
                pointsView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    pointsView?.errorGetPitchTeam()
                    pointsView?.finishLoading()
                    return
                }
                pointsView?.errorGetPitchTeam()
                pointsView?.alertMessage(message.localiz())
                return
            }
            data = result.response
        } else {
            pointsView?.errorGetPitchTeam()
        }
        pointsView?.finishLoading()
        pointsView?.reloadPitchTeam()
    }
    
    //MARK: Gameweek List
    func getListGameweek(params: [String: Any]) {
        pointsView?.startLoading()
        service?.getGameweekList(params: params, callback: { (result, status) in
            self.handleGameweekListCallback(result, status)
        })
    }
    
    private func handleGameweekListCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, pointsView)
        } else {
            self.handleGameweekResponseSuccess(result)
        }
    }
    
    private func handleGameweekResponseSuccess(_ response: AnyObject) {
        if let result = response as? GlobalGameWeekModel {
            guard let meta = result.meta else {
                pointsView?.finishLoading()
                pointsView?.reloadWeekView([])
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    pointsView?.finishLoading()
                    pointsView?.reloadWeekView([])
                    return
                }
                pointsView?.alertMessage(message.localiz())
                return
            }
            if let data = result.response?.data {
                pointsView?.reloadWeekView(convertData(from: data))
            } else {
                pointsView?.reloadWeekView([])
            }
        } else {
            pointsView?.reloadWeekView([])
        }
        pointsView?.finishLoading()
        
    }
    
    func getListGameweekForTeamID() {
        pointsView?.startLoading()
        service?.getGameweekList(teamId, callback: { (result, status) in
            self.handleGameweekForTeamListCallback(result, status)
        })
    }
    
    private func handleGameweekForTeamListCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, pointsView)
        } else {
            self.handleGameweekForTeamResponseSuccess(result)
        }
    }
    
    private func handleGameweekForTeamResponseSuccess(_ response: AnyObject) {
        if let result = response as? GameWeekModel {
            guard let meta = result.meta else {
                pointsView?.finishLoading()
                pointsView?.reloadWeekView([])
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    pointsView?.finishLoading()
                    pointsView?.reloadWeekView([])
                    return
                }
                pointsView?.alertMessage(message.localiz())
                return
            }
            if let data = result.response {
                pointsView?.reloadWeekView(convertData(from: data))
            } else {
                pointsView?.reloadWeekView([])
            }
        } else {
            pointsView?.reloadWeekView([])
        }
        pointsView?.finishLoading()
        
    }
    
    private func convertData(from weeks: [GameWeek]) -> [CheckBoxData] {
        return weeks.map { (week) -> CheckBoxData in
            return CheckBoxData("\(week.id ?? 0)", "\(week.round ?? 0)", week.title ?? "")
        }
    }
    
    //MARK: Added Player Line up
    func addPlayer(from: Player?, to: Player, to position: PositionPlayer, _ completion: (() -> Void)? = nil) {
        pointsView?.startLoading()
        service?.addPlayer(teamId, from: from, to: to, position, data?.team?.round ?? 0, callback: { (result, status) in
            self.handlePitchTeamCallback(result, status)
            completion?()
        })
    }
    
    //MARK: Change formation
    func changeFormation(formation: String) {
        let players: [Player] = self.data?.players ?? []
        pointsView?.startLoading()
        service?.changeFormation(teamId, formation, data?.team?.round ?? 0, callback: { (result, status) in
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
}
