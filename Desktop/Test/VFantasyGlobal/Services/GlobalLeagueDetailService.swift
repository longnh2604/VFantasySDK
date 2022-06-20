//
//  GlobalLeagueDetailService.swift
//  VFantasyGlobal
//
//  Created by User on 26/05/2022.
//

import UIKit

class GlobalLeagueDetailService: BaseService {

    func stopGlobalLeague(_ leagueId: Int, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = [String: Any]()
        let path = String(format: CommonAPI.api_global_delete_league, leagueId)
        self.request(type: GlobalLeagueModel.self,
                     method: .delete,
                     params: params,
                     pathURL: path) { (data, status, statusCode) in
            callBack(data, status)
        }
    }
    
    func leaveLeague(_ leagueID: Int, _ teamID: Int?, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        var params: [String: Any] = [:]
        if let teamID = teamID {
            params.updateValue(teamID, forKey: "team_id")
        }
        let url = String(format: CommonAPI.api_global_leave_league, leagueID)
        self.request(type: LeaveGlobalLeagueModel.self, method: .post, params: params, pathURL: url) { response, status, code in
            callBack(response, status)
        }
    }
}
