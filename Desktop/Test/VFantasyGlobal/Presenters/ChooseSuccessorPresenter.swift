//
//  ChooseSuccessorPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation
import UIKit

protocol ChooseSuccessorView: BaseViewProtocol {
    func reloadView()
}

class ChooseSuccessorPresenter: NSObject {
    private var service = ChooseSuccessorServices()
    weak private var viewSuccessor: ChooseSuccessorView?
    
    var leagueID = ""
    var successors = [Team]()
    var isShowFromDetailGlobalLeague = false
    
    func attachView(_ view: ChooseSuccessorView) {
        self.viewSuccessor = view
    }
    
    func detachView() {
        self.viewSuccessor = nil
    }
    
    // MARK: - List Successor
    func listSuccessor() {
        self.viewSuccessor?.startLoading()
        
        service.successors(self.leagueID) { response, status in
            if status {
                self.handleListResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.viewSuccessor)
            }
        }
    }
    
    func handleListResponseSuccess(_ response: AnyObject) {
        if let result = response as? LeagueTeamsData {
            guard let meta = result.meta else {
                viewSuccessor?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    viewSuccessor?.finishLoading()
                    return
                }
                viewSuccessor?.alertMessage(message.localiz())
                return
            }
            
            if let res = result.response {
                if let teams = res.data {
                    for team in teams {
                        if isShowFromDetailGlobalLeague {
                            if let user = team.user {
                                if !user.isLoggedIn {
                                    successors.append(team)
                                }
                            }
                        } else {
                            if let isOwner = team.isOwner {
                                if !isOwner {
                                    successors.append(team)
                                }
                            }
                        }
                    }
                }
            }
            
            viewSuccessor?.finishLoading()
            viewSuccessor?.reloadView()
        }
    }
}
