//
//  PlayerDetailService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

class PlayerDetailService: BaseService {
    func getPlayerStatisticWithTeam(_ playerModel:PlayerDataModel, callBack: @escaping(_ response:AnyObject,_ status:Bool) -> Void) {
        let path = String(format: CommonAPI.api_player_statistic_with_team, playerModel.playerId!, playerModel.teamId!)
        let params = ["filter": playerModel.filter!]
        
        if playerModel.keyFilter == PlayerFilterKey.points_per_round {
            self.request(type: PlayerStatisticsResponse.self, method: .get, params: params, pathURL: path) { (response, status, code) in
                callBack(response, status)
            }
        } else {
            self.request(type: PlayerStatisticsObjectResponse.self, method: .get, params: params, pathURL: path) { (response, status, code) in
                callBack(response, status)
            }
        }
    }
    
    func getPlayerStatistic(_ playerModel:PlayerDataModel, callBack: @escaping(_ response:AnyObject,_ status:Bool) -> Void) {
        let path = String(format: CommonAPI.api_player_statistic, playerModel.playerId!)
        let params = ["filter":playerModel.filter!]
        
        if playerModel.keyFilter == PlayerFilterKey.points_per_round {
            self.request(type: PlayerStatisticsResponse.self, method: .get, params: params, pathURL: path) { (response, status, code) in
                callBack(response, status)
            }
        } else {
            self.request(type: PlayerStatisticsObjectResponse.self, method: .get, params: params, pathURL: path) { (response, status, code) in
                callBack(response, status)
            }
        }
    }
    
    func getPlayerDetail(_ playerModel: PlayerDataModel, callBack: @escaping(_ response:AnyObject, _ status:Bool) -> Void) {
        let path = String(format: CommonAPI.api_player_detail, playerModel.playerId ?? 0)
        
        self.request(type: PlayerDetailResponse.self, method: .get, params: [:], pathURL: path) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getGameweekList(callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_all_gameweek)
        self.request(type: GlobalGameWeekModel.self, method: .get, params: [:], pathURL: path) { (response, status, code) in
            callback(response, status)
        }
    }

}
