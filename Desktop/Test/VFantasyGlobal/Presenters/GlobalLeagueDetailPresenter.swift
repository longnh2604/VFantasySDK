//
//  GlobalLeagueDetailPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 26/05/2022.
//

import Foundation
import UIKit

protocol GlobalLeagueDetailView: BaseViewProtocol {
    func finishStopLeague(isLeave: Bool)
    func leftLeague()
    func participantLeftLeague()
}

class GlobalLeagueDetailPresenter: NSObject {

    var leagueModel = GlobalLeagueModelView()
    var teamId = 0
    var leagueId = 0
    var service = GlobalLeagueDetailService()
    var superView: GlobalLeagueDetailView?
    
    var league: LeagueDatum?
    
    init(league: GlobalLeagueModelView) {
        self.leagueModel = league
    }
    
    func attachView(view: GlobalLeagueDetailView) {
        self.superView = view
    }
    
    func stopLeague(isLeave: Bool) {
        superView?.startLoading()
        service.stopGlobalLeague(leagueId) { [weak self] (result, status) in
            self?.handleStopLeagueCallback(result, status, isLeave)
        }
    }
    
    private func handleStopLeagueCallback(_ result: AnyObject, _ status: Bool, _ isLeave: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleStopLeagueResponseSuccess(result, isLeave: isLeave)
        }
    }
    
    private func handleStopLeagueResponseSuccess(_ response: AnyObject, isLeave: Bool) {
        if let result = response as? GlobalLeagueModel {
            guard let meta = result.meta else {
                superView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    superView?.finishLoading()
                    return
                }
                superView?.alertMessage(message.localiz())
                return
            }
            
            superView?.finishStopLeague(isLeave: isLeave)
        }
    }
}

extension GlobalLeagueDetailPresenter {
    
    // MARK: - Leave league
    func leaveLeague(_ successorID: Int?) {
        superView?.startLoading()
        
        service.leaveLeague(leagueModel.id, successorID) { response, status in
            if status {
                if successorID != nil {
                    self.handleLeaveLeagueResponseSuccess(response)
                } else {
                    self.handleParticipantLeaveLeagueResponseSuccess(response)
                }
            } else {
                CommonResponse.handleResponseFail(response, self.superView)
            }
        }
    }
    
    func handleLeaveLeagueResponseSuccess(_ response: AnyObject) {
        if let result = response as? LeaveGlobalLeagueModel {
            guard let meta = result.meta else {
                superView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    superView?.finishLoading()
                    return
                }
                superView?.alertMessage(message.localiz())
                return
            }
            
            // reload list my league in home view controller
//            NotificationCenter.default.post(name: NotificationName.reloadMyLeaguesHomeScreen, object: nil)
            
            superView?.leftLeague()
            superView?.finishLoading()
        }
    }
    
    func handleParticipantLeaveLeagueResponseSuccess(_ response: AnyObject) {
        if let result = response as? LeaveGlobalLeagueModel {
            guard let meta = result.meta else {
                superView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    superView?.finishLoading()
                    return
                }
                superView?.alertMessage(message.localiz())
                return
            }
            
            superView?.participantLeftLeague()
            superView?.finishLoading()
        }
    }
}
