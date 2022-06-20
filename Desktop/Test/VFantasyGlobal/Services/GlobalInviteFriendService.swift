//
//  GlobalInviteFriendService.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation

class GlobalInviteFriendService: BaseService {
    
    func leagueGlobalInviteFriends(_ model: LeagueFriendModel, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_league_friends)
        let params = ["league_id": model.leagueID, "keyword" :  model.keyword] as [String: Any]
        
        self.request(type: LeagueFriendData.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func inviteFriend(_ model: InviteFriendModel, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = ["league_id" : model.leagueID,
                      "sender_id" : model.userID,
                      "receiver_id" : model.friendID] as [String : Any]
        
        self.request(type: InviteFriendData.self, method: .post, params: params, pathURL: CommonAPI.api_global_invite_friend) { response, status, code in
            callBack(response, status)
        }
    }
}
