//
//  SeasonService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

class SeasonService: BaseService {
    func getSeasonList(callBack:@escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = ["page" : self.page,
                      "per_page" : self.per_page]
        
        self.request(type: SeasonResponse.self, method: .get, params: params, pathURL: CommonAPI.api_list_season) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
}
