//
//  TeamLineupDraftService.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation

class TeamLineupDraftService: BaseService {
    func getTeams(_ model: TeamLineupDraftModel, _ callBack: @escaping (_ reponse: AnyObject, _ status: Bool) -> Void) {
        let params = ["league_id" : model.leagueId,
                      "per_page" : 20]
        
        self.request(type: LeagueTeamsData.self, method: .get, params: params, pathURL: CommonAPI.api_league_teams) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getPickHistory(_ model: TeamLineupDraftModel, _ callBack: @escaping (_ reponse: AnyObject, _ status: Bool) -> Void) {
        let params = ["page" : page,
                      "per_page" : 16]
        
        let url = String(format: CommonAPI.api_pick_history, model.leagueId)
        
        self.request(type: PickHistoryData.self, method: .get, params: params, pathURL: url) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func joinDraft(_ model: TeamLineupDraftModel, _ callBack: @escaping (_ reponse: AnyObject, _ status: Bool) -> Void) {
        let url = String(format: CommonAPI.api_join_draft, model.leagueId)
        
        print("Socket join draft API")
        
        self.request(type: LeagueTeamsData.self, method: .get, params: [:], pathURL: url) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func endCountDown(_ model: TeamLineupDraftModel, _ callBack: @escaping (_ reponse: AnyObject, _ status: Bool) -> Void) {
        let url = String(format: CommonAPI.api_end_countdown, model.leagueId)
        
        self.request(type: EndCountDownData.self, method: .get, params: [:], pathURL: url) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func endTurn(_ teamId: Int, data: TeamTurnData, _ callBack: @escaping (_ reponse: AnyObject, _ status: Bool) -> Void) {
        let params = ["pick_round" : data.pickTurn,
                      "pick_order" : data.pickOrder]
        
        let url = String(format: CommonAPI.api_end_turn, teamId)
        
        print("Socket end turn with params: \(params.description)")
        
        self.request(type: EndTurnData.self, method: .post, params: params, pathURL: url) { (response, status, code) in
            callBack(response, status)
        }
    }
}
