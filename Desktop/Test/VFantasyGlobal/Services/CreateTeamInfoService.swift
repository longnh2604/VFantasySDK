//
//  CreateTeamInfoService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import UIKit

class CreateTeamInfoService: BaseService {
    func getLineup(_ teamID: Int, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_team_lineup, teamID)
        
        print("Socket lineup API")
        
        self.request(type: LineupData.self, method: .get, params: [:], pathURL: path) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
    
    func getPlayerList(_ model: PlayerRequestModel, callBack: @escaping (_ response: AnyObject, _ status:
        Bool) -> Void) {
        if pendingRequest { return }
        pendingRequest = true
        
        var params = ["league_id" : model.leagueID,
                      "keyword" : model.keyword,
                      "sort" : model.order,
                      "per_page" : per_page,
                      "season_id" : model.season_id,
                      "team_id" : model.teamId,
                      "page" : page] as [String : Any]
        
        if model.position > "\(PlayerPositionType.all.rawValue)" {
            //search specific position type
            //all positions is -1
            params.updateValue(model.position, forKey: "main_position")
        }
        
        if model.clubID.isNotEmpty {
            params.updateValue(model.clubID, forKey: "real_club_id")
        }
        
        self.request(type: PlayerListData.self, method: .get, params: params, pathURL: CommonAPI.api_player_list) { (response, status, statusCode) in
            self.pendingRequest = false
            callBack(response, status)
        }
    }
    
    func addPlayer(_ playerID: Int, _ teamID: Int, _ order: Int, currentResponse: TurnReceiveData? = nil, callBack:@escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        var params = ["player_id" : playerID,
                      "order" : order]
        if let current = currentResponse?.getCurrentTeam() {
            params.updateValue(current.pickOrder, forKey: "pick_order")
            params.updateValue(current.pickTurn, forKey: "pick_round")
        }
        print("Socket Add player params: \(params.description)")
        
        let url = String(format: CommonAPI.api_add_player, teamID)
        self.request(type: AddPlayerData.self, method: .post, params: params, pathURL: url) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
    
    func removePlayer(_ playerID: Int, _ teamID: Int, currentResponse: TurnReceiveData? = nil, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        var params = ["player_id" : playerID]
        if let current = currentResponse?.getCurrentTeam() {
            params.updateValue(current.pickOrder, forKey: "pick_order")
            params.updateValue(current.pickTurn, forKey: "pick_round")
        }
        
        let url = String(format: CommonAPI.api_remove_player, teamID)
        
        print("Socket Remove player with params: \(params.description)")
        
        self.request(type: AddPlayerData.self, method: .post, params: params, pathURL: url) { (response, status, statusCode) in
            callBack(response, status)
            
            print("Socket Done Remove player with params: \(params.description)")
        }
    }
    
    func getLeagueTeams(_ leagueID: Int, _ callBack: @escaping (_ reponse: AnyObject, _ status: Bool) -> Void) {
        let params = ["league_id" : leagueID,
                      "per_page" : per_page]
        
        self.request(type: LeagueTeamsData.self, method: .get, params: params, pathURL: CommonAPI.api_league_teams) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func completeLineup(_ teamID: Int, _ callBack: @escaping (_ reponse: AnyObject, _ status: Bool) -> Void) {
        let url = String(format: CommonAPI.api_global_complete_lineup, teamID)
        
        self.request(type: LeagueTeamsData.self, method: .post, params: [:], pathURL: url) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func autoPickPlayers(_ teamID: Int, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_auto_pick_players, teamID)
        
        self.request(type: AddPlayerData.self, method: .post, params: [:], pathURL: path) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
    
    func removeAutoPickPlayers(_ teamID: Int, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_remove_auto_pick_players, teamID)
        
        self.request(type: AddPlayerData.self, method: .post, params: [:], pathURL: path) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
}
