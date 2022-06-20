//
//  GlobalSquadService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

class GlobalSquadService: BaseService {

    func getGlobalSquad(teamId: Int, roundId: Int, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params: [String: Any] = ["real_round_id": roundId]
        let path = String(format: CommonAPI.api_global_squad, teamId)
        self.request(type: SquadData.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callBack(response, status)
        }
    }
}
