//
//  ChooseSuccessorServices.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation
import UIKit

class ChooseSuccessorServices: BaseService {
    func successors(_ id: String, _ callBack: @escaping (_ reponse: AnyObject, _ status: Bool) -> Void) {
        let params = ["league_id" : id,
                      "per_page" : per_page] as [String : Any]
        
        self.request(type: LeagueTeamsData.self, method: .get, params: params, pathURL: CommonAPI.api_league_teams) { (response, status, code) in
            callBack(response, status)
        }
    }
}
