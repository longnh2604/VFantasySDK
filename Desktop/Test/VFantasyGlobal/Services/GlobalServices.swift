//
//  GlobalServices.swift
//  PAN689
//
//  Created by AgileTech on 12/11/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit
class GlobalServices: BaseService {
    func myLeagues( callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = ["page": 1,
                      "limit": 1000] as [String: Any]
        self.request(type: LeagueData.self, method: .get, params: params, pathURL: CommonAPI.api_global_my_league) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getDetailTeam(_ teamId: Int, _ real_round_id: Int? = nil, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_detailTeam, teamId)
        var params = [String: Any]()
        if let real_round_id = real_round_id {
            params["real_round_id"] = real_round_id
        }
        
        self.request(type: GlobalMyTeam.self, method: .get, params: params, pathURL: path) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
    
    func getMyTeam(_ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = [String: Any]()
        
        self.request(type: GlobalMyTeam.self, method: .get, params: params, pathURL: CommonAPI.api_global_myteam) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getMyTeams(_ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = [String: Any]()
        
        self.request(type: GlobalMyTeams.self, method: .get, params: params, pathURL: CommonAPI.api_global_myteams) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func createGlobalTeam(_ model: CreateTeamModel, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        uploadLogo(model.logo) { (logo) in
            var params = [String:Any]()
            params.updateValue(model.name ?? "", forKey: "name")
            params.updateValue(model.desc ?? "", forKey: "description")
            if let logo = logo {
                params.updateValue(logo, forKey: "logo")
            }
            self.request(type: GlobalTeamModel.self, method: .post, params: params, pathURL: CommonAPI.api_global_createTeam) { (response, status, statusCode) in
                callBack(response, status)
            }
        }
    }
    
    func editGlobalTeam(_ model:CreateTeamModel, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_editTeam, model.teamId!)
        uploadLogo(model.logo) { (logo) in
            var params = [String:Any]()
            params.updateValue(model.name ?? "", forKey: "name")
            params.updateValue(model.desc ?? "", forKey: "description")
            if let logo = logo {
                params.updateValue(logo, forKey: "logo")
            }
            self.request(type: GlobalTeamModel.self, method: .post, params: params, pathURL: path) { (response, status, statusCode) in
                callBack(response, status)
            }
        }
    }
    
    private func uploadLogo(_ image: UIImage?, _ completion: @escaping (_ path: String?) -> Void) {
        if let image = image {
            let request = RequestUploadFile(filreName: "logoGlobal.png", storage: StorageKey.team, imageLocal: image)
            UploadFileService().uploadFile(request) { (response, status) in
                if status == true {
                    if let data = response as? UploadFileData {
                        completion(data.response?.fileMachineName)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    func redeemToJoin(_ code: String, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_redeem_join_league, code)
        
        self.request(type: RedeemData.self, method: .get, params: [:], pathURL: path) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getDetailLeague(_ id: Int, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_global_update_league, id)
        
        self.request(type: GlobalLeagueModel.self, method: .get, params: [:], pathURL: path) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getValidateTransfer(teamID: Int, real_round_id: Int? = nil, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_validate_transfer_deadline, teamID)
        var params = [String:Any]()
        if let real_round_id = real_round_id {
            params["real_round_id"] = real_round_id
        }
        self.request(type: GlobalTransferDeadline.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getTeamOfTheWeek(roundId: Int, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = ["real_round_id": roundId]
        
        self.request(type: GlobalTeamOTWeek.self, method: .get, params: params, pathURL: CommonAPI.api_global_team_of_the_week) { (response, status, code) in
            callBack(response, status)
        }
    }
}
