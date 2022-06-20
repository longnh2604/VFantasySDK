//
//  GlobalLeagueInfoPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 26/05/2022.
//

import Foundation
import UIKit

protocol GlobalLeagueInfoView: BaseViewProtocol {
    func finishLoadingGameweeks()
    func getDetailLeague(_ league: LeagueDatum?)
}

class GlobalLeagueInfoPresenter: NSObject {

    var service: GlobalNewLeagueService?
    var superView: GlobalLeagueInfoView?
    var gameweeks = [GameWeek]()
    var leagueModel = GlobalLeagueModelView()
    var teamId = 0
    
    init(league: GlobalLeagueModelView) {
        self.leagueModel = league
        self.service = GlobalNewLeagueService()
    }
    
    func attachView(view: GlobalLeagueInfoView) {
        self.superView = view
    }
    
    func getGameweeks() {
        superView?.startLoading()
      service?.getAllGameweekList(callback: { (result, status) in
        self.handleGameweekCallback(result, status)
      })
    }
    
    private func handleGameweekCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleGameweeksResponseSuccess(result)
        }
    }
    
    private func handleGameweeksResponseSuccess(_ response: AnyObject) {
        if let result = response as? GlobalGameWeekModel {
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
            
            self.gameweeks = result.response?.data ?? []
            superView?.finishLoadingGameweeks()
        }
    }
    
    func detailLeague(leagueId: Int) {
        superView?.startLoading()
        service?.detailLeague(leagueId, callBack: { (result, status) in
            self.handleDetailLeagueCallback(result, status)
        })
    }
    
    private func handleDetailLeagueCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleLeagueDetailResponseSuccess(result)
        }
    }
    
    private func handleLeagueDetailResponseSuccess(_ response: AnyObject) {
        if let result = response as? LeagueGlobalDetailModel {
            guard let meta = result.meta else {
                superView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    superView?.finishLoading()
                    return
                }
                superView?.getDetailLeague(nil)
                superView?.alertMessage(message.localiz())
                return
            }
            superView?.getDetailLeague(result.response)
            superView?.finishLoading()
        }
    }
}
