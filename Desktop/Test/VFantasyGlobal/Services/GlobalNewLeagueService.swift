//
//  GlobalNewLeagueService.swift
//  VFantasyGlobal
//
//  Created by User on 26/05/2022.
//

import UIKit

class GlobalNewLeagueService: BaseService {

    func createNewLeague(_ model: GlobalLeagueModelView, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = ["name" : model.name,
                      "logo" : model.avatar,
                      "description" : model.desc,
                      "real_round_id": model.gameweekId] as [String : Any]
        
        self.request(type: GlobalLeagueModel.self, method: .post, params: params, pathURL: CommonAPI.api_global_create_league) { (data, status, statusCode) in
            callBack(data, status)
        }
    }
    
    func detailLeague(_ leagueId: Int, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_league_detail, leagueId)
        self.request(type: LeagueGlobalDetailModel.self, method: .get, params: [:], pathURL: path) { (data, status, statusCode) in
            callBack(data, status)
        }
    }
    
    func getGameweekList(_ teamID: Int, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_gameweek_list, teamID)
        self.request(type: GameWeekModel.self, method: .get, params: [:], pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
  
    func getAllGameweekList(callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        self.request(type: GlobalGameWeekModel.self, method: .get, params: [:], pathURL: CommonAPI.api_global_all_gameweek) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func updateGlobalLeague(_ model: GlobalLeagueModelView, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        var params = ["name" : model.name,
                      "description" : model.desc,
                      "real_round_id": model.gameweekId] as [String : Any]
        if !model.avatar.isEmpty {
            params["logo"] = model.avatar
        }
        
        let path = String(format: CommonAPI.api_global_update_league, model.id)
        self.request(type: GlobalLeagueModel.self,
                     method: .put,
                     params: params,
                     pathURL: path) { (data, status, statusCode) in
            callBack(data, status)
        }
    }
}
