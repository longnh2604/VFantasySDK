//
//  MatchResultsService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

class MatchResultsService: BaseService {
    func getMyMatchResults(callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = ["page" : page,
                      "per_page" : pageLimit]
        
        self.request(type: MatchResultsResponse.self, method: .get, params: params, pathURL: CommonAPI.api_my_match_results) { (response, status, statusCode) in
            callBack(response, status)
        }
    }

    func getRealMatchResults(round: String?, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        var params = ["page" : page,
                      "per_page" : per_page] as [String : Any]
        
        if let round = round  {
            if round.isNotEmpty {
                params.updateValue(round, forKey: "round")
            }
        }
        params.updateValue("start_at", forKey: "orderBy")
        params.updateValue("desc", forKey: "sortedBy")
        
        self.request(type: RealMatchData.self, method: .get, params: params, pathURL: CommonAPI.api_real_rounds) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
    
    func getFollowPlayDay(callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        self.request(type: RealMatchData.self, method: .get, params: [:], pathURL: CommonAPI.api_follow_play_day) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
    
    func getMaxRounds(callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        self.request(type: RealMatchData.self, method: .get, params: [:], pathURL: CommonAPI.api_max_round) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
    
    func getLatestRound(callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        self.request(type: LatestRoundData.self, method: .get, params: [:], pathURL: CommonAPI.api_latest_round) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
}
