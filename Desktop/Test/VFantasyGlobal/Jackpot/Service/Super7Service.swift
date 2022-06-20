//
//  Super7Service.swift
//  PAN689
//
//  Created by Quang Tran on 12/27/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class Super7Service: BaseService {

    func createSuper7Team(_ model: CreateSuper7Model, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        uploadLogo(model.logo) { (logo) in
            var params = [String:Any]()
            params.updateValue(model.name ?? "", forKey: "name")
            params.updateValue(model.desc ?? "", forKey: "description")
            if let logo = logo {
                params.updateValue(logo, forKey: "logo")
            }
            self.request(type: Super7TeamModel.self, method: .post, params: params, pathURL: CommonAPI.api_super7_createteam) { (response, status, statusCode) in
                callBack(response, status)
            }
        }
    }
    
    func editSuper7Team(_ model: CreateSuper7Model, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_super7_editteam, model.teamId!)
        uploadLogo(model.logo) { (logo) in
            var params = [String:Any]()
            params.updateValue(model.name ?? "", forKey: "name")
            params.updateValue(model.desc ?? "", forKey: "description")
            if let logo = logo {
                params.updateValue(logo, forKey: "logo")
            } else if let logo = model.avatar {
                params.updateValue(logo, forKey: "logo")
            }
            self.request(type: Super7TeamModel.self, method: .post, params: params, pathURL: path) { (response, status, statusCode) in
                callBack(response, status)
            }
        }
    }
    
    private func uploadLogo(_ image: UIImage?, _ completion: @escaping (_ path: String?) -> Void) {
        if let image = image {
            let request = RequestUploadFile(filreName: "logoSuper7.png", storage: StorageKey.team, imageLocal: image)
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
    
    func getSuper7MyTeam(_ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = [String: Any]()

        self.request(type: Super7TeamModel.self, method: .get, params: params, pathURL: CommonAPI.api_super7_myteam) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getSuper7TeamDetail(_ teamId: Int, _ real_round_id: Int, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_super7_detailteam, teamId)
        self.request(type: Super7TeamModel.self, method: .get, params: ["real_round_id": real_round_id], pathURL: path) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getSuper7League(_ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let params = [String: Any]()

        self.request(type: Super7LeagueModel.self, method: .get, params: params, pathURL: CommonAPI.api_super7_current_league) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func getSuper7PitchData(_ teamId: Int, _ real_round_id: Int? = nil, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_super7_pitchview, teamId)
        var params = [String: Any]()
        if let real_round_id = real_round_id {
            params["real_round_id"] = real_round_id
        }

        self.request(type: Super7PitchTeamModel.self, method: .get, params: params, pathURL: path) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func updateSuper7PitchData(_ teamId: Int, _ round: Int, _ player: Player, _ match_id: Int, _ callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_super7_pitchview, teamId)
        var params = [String: Any]()
        params["from_player_id"] = player.id ?? 0
        params["position"] = player.mainPosition ?? 0
        params["round"] = round
        params["match_id"] = match_id
        params["order"] = 1
        params["to_player_id"] = 0

        self.request(type: Super7PitchTeamModel.self, method: .post, params: params, pathURL: path) { (response, status, code) in
            callBack(response, status)
        }
    }
    
    func autoPickPlayers(_ teamID: Int, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_super7_autopick, teamID)
        
        self.request(type: AutoPickPlayersData.self, method: .post, params: [:], pathURL: path) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
    
    func getGlobalGameweekList(params: [String: Any] = [:], callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        self.request(type: GlobalGameWeekModel.self, method: .get, params: params, pathURL: CommonAPI.api_global_all_gameweek) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func getSuper7GameweekList(params: [String: Any] = [:], callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        self.request(type: GlobalGameWeekModel.self, method: .get, params: params, pathURL: CommonAPI.api_super7_all_gameweek) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func getSuper7DreamTeams(_ real_round_id: Int?, callback: @escaping(_ response: AnyObject, _ status: Bool) -> Void) {
        var params = [String: Any]()
        params["options[include_players]"] = 0
        if let real_round_id = real_round_id {
            params["real_round_id"] = real_round_id
        }
        self.request(type: Super7DreamTeamsModel.self, method: .get, params: params, pathURL: CommonAPI.api_super7_dream_teams) { (response, status, code) in
            callback(response, status)
        }
    }
    
    func claimThePrize(_ teamID: Int, _ real_round_id: Int, _ model: Super7ClaimModel, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        let path = String(format: CommonAPI.api_super7_claim_prize, teamID)
        var params = [String: Any]()
        params["real_round_id"] = real_round_id
        params["first_name"] = model.firstName
        params["last_name"] = model.lastName
        params["email"] = model.email
        params["phone"] = model.phone

        self.request(type: Super7ClaimPrizeData.self, method: .post, params: params, pathURL: path) { (response, status, statusCode) in
            callBack(response, status)
        }
    }
}
