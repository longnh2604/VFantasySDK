//
//  GlobalStatsService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

class GlobalStatsService: BaseService {
    
    func getPlayerStats(type: PlayerStatsType, key: String = "", _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        var params = ["page" : page,
                      "per_page" : per_page] as [String : Any]
        params.updateValue(type.rawValue, forKey: "order_by")
        params.updateValue("desc", forKey: "sort_by")
        if !key.isEmpty {
            params.updateValue(key, forKey: "keyword")
        }
        
        self.request(type: PlayersStatsData.self, method: .get, params: params, pathURL: CommonAPI.api_global_players_stats) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
}
