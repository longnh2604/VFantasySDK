//
//  PlayerListService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

class PlayerListService: BaseService {
    func getPlayerList(model: PlayerRequestModel, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        
        var params = [String:Any]()
        params.updateValue(self.page, forKey: "page")
        params.updateValue(self.per_page, forKey: "per_page")
        
        if model.keyword.isNotEmpty {
            params.updateValue(model.keyword, forKey: "keyword")
        }
        
        if model.position.isNotEmpty {
            params.updateValue(model.position, forKey: "main_position")
        }
        
        if model.clubID.isNotEmpty {
            params.updateValue(model.clubID, forKey: "real_club_id")
        }
        
        if model.order.isNotEmpty {
            params.updateValue(model.order, forKey: "sort")
        }
        
        if model.season_id.isNotEmpty {
            params.updateValue(model.season_id, forKey: "season_id")
        }
        
        if let pickingPlayerId = model.from_player_id {
            params.updateValue(pickingPlayerId, forKey: "transfer_player_id")
        }
        
        if model.leagueID.isNotEmpty {
            params.updateValue(model.leagueID, forKey: "league_id")
        }
        
        if model.action.isNotEmpty {
            params.updateValue(model.leagueID, forKey: "action")
        }
        
        self.request(type: PlayerListData.self, method: .get, params: params, pathURL: CommonAPI.api_player_list) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
    
    func transferPlayer(model: TransferPlayerRequestModel, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        var params = [String : Any]()
        
        params.updateValue(model.fromPlayerId, forKey: "from_player_id")
        params.updateValue(model.toPlayerId, forKey: "to_player_id")
        if model.withTeamId != 0 {
            params.updateValue(model.withTeamId, forKey: "with_team_id")
        }
        params.updateValue(model.gameplayOption.rawValue, forKey: "gameplay_option")
        
        let url = String(format: CommonAPI.api_transfer_player, model.teamId)
        
        self.request(type: PlayerListData.self, method: .post, params: params, pathURL: url) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
}
