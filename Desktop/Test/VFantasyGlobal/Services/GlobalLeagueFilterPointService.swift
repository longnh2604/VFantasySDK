//
//  GlobalLeagueFilterPointService.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation

class GlobalLeagueFilterPointService: BaseService {
    
    func getGameweekList(_ leagueId: Int, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_all_gameweek)
        let params = ["league_id": leagueId,
                      "page": page,
                      "limit": per_page] as [String: Any]
        self.request(type: GlobalGameWeekModel.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
}
