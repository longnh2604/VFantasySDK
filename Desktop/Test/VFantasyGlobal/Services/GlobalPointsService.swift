//
//  GlobalPointsService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

class GlobalPointsService: BaseService {

    func getPoints(_ teamID: Int, _ model: GlobalPointsRequestModel, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_points, teamID)
        var params: [String: Any] = ["property" : "formation",
                                     "rela":"team_round",
                                     "operator": "eq",
                                     "value": model.formation]
        
        if model.realRoundId != nil {
            params.updateValue(model.realRoundId!, forKey: "real_round_id")
        }
        
        self.request(type: PitchTeamModel.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
  
    func getPitchTeamInfo(_ teamID: Int, _ model: GlobalPointsRequestModel, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_pitchTeam, teamID)
        var params: [String: Any] = ["property" : "formation",
                                     "rela":"team_round",
                                     "operator": "eq",
                                     "value": model.formation]
        
        if model.realRoundId != nil {
            params.updateValue(model.realRoundId!, forKey: "real_round_id")
        }
        
        self.request(type: PitchTeamModel.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func getGameweekList(params: [String: Any] = [:], callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        self.request(type: GlobalGameWeekModel.self, method: .get, params: params, pathURL: CommonAPI.api_global_all_gameweek) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func getGameweekList(_ teamID: Int, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_gameweek_list, teamID)

        self.request(type: GameWeekModel.self, method: .get, params: [:], pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func addPlayer(_ teamID: Int, from: Player?, to: Player, _ position: PositionPlayer, _ round: Int, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_pitchTeam, teamID)
        let params: [String: Any] = ["from_player_id": from?.id ?? 0,
                                     "to_player_id": to.id ?? 0,
                                     "round": round,
                                     "order": position.index,
                                     "position": position.type.position]
        self.request(type: PitchTeamModel.self, method: .post, params: params, pathURL: path) { (response, status, code) in
            callback(response, status)
        }

    }
    
    func changeFormation(_ teamID: Int, _ formation: String, _ round: Int, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_pitchTeam_changeFormation, teamID)
        let params: [String: Any] = ["formation": formation,
                                     "round": round]
        self.request(type: PitchTeamModel.self, method: .post, params: params, pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
}
