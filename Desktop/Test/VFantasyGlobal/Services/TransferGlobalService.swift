//
//  TransferGlobalService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

class TransferGlobalService: BaseService {
    
    func getTransferPlayerList(_ teamID: Int, _ model: PlayerRequestModel, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_transfer_player_list, teamID)
        let sort = VFantasyCommon.validSortType([TransferPlayerListRequestModel(property: "value", direction: "asc")])
        let params = ["gameplay_option": model.gameplayOption.rawValue, "sort": sort] as [String: Any]
        
        self.request(type: TransferPlayerListData.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func transferPlayer(_ model: TransferPlayerRequestModel, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_transfer_player, model.teamId)
        var params = [String: Any]()
        
        params.updateValue(model.fromListPlayerId, forKey: "from_player_id")
        params.updateValue(model.toListPlayerId, forKey: "to_player_id")
        params.updateValue(model.gameplayOption.rawValue, forKey: "gameplay_option")
        
        self.request(type: TransferResponse.self, method: .post, params: params, pathURL: path) { (response, status, code) in
            callBack(response, status)
        }
    }
}
