//
//  FilterClubService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

class FilterClubService: BaseService {
    func getListClub(callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = ["page" : self.page,
                      "per_page" : 100]
        
        self.request(type: ClubObjectResponse.self, method: .get, params: params, pathURL: CommonAPI.api_list_club) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
}
