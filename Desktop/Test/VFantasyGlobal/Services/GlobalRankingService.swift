//
//  GlobalRankingService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

class GlobalRankingService: BaseService {
    
    func getLeagueRanking(_ mode: RankingMode, _ type: GlobalRankingType, _ model: GlobalRankingRequestModel, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        var path = String(format: CommonAPI.api_global_ranking, model.leagueId)
        if mode == .super7 {
            path = String(format: CommonAPI.api_super7_ranking, model.leagueId)
        }
        var params = ["type": type.getString(),
                      "page": page,
                      "limit": per_page,
                      "by_month": model.byMonth] as [String: Any]
        if model.byGameweek > 0 {
            params["by_gameweek"] = model.byGameweek
        }
        
        self.request(type: GlobalRankingModel.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func getRankingByRound(_ roundId: Int, _ leagueId: Int, _ teamId: Int, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        
        let path = String(format: CommonAPI.api_global_ranking_by_round, leagueId, roundId)
        let params = ["team_id": teamId,
                      "page": page,
                      "limit": per_page] as [String: Any]
        
        self.request(type: GlobalRankingModel.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
}
