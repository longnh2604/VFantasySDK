//
//  GlobalRankingPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

protocol RankingGlobalView: BaseViewProtocol {
    func reloadView()
}

enum RankingMode {
    case global, super7
}

class GlobalRankingPresenter: NSObject {
    
    private var service = GlobalRankingService()
    weak private var view: RankingGlobalView?
    
    var rankingType = GlobalRankingType.global
    var leagueId = 0
    
    var requestModel = GlobalRankingRequestModel()

    var users = [RankingData]()
    var teamData: MyTeamData?
    var myTeam: MyTeamData?
    var mode: RankingMode = .global
    
    func attachView(view: RankingGlobalView) {
        self.view = view
    }
    
    func filterByGW(_ gwId: Int) {
        requestModel.byGameweek = gwId
    }
    
    func resetPage() {
        service.page = 1
    }
    
    func loadMoreFriends() {
        if self.service.isFullData {
            return
        }
        getLeagueRanking()
    }
    
    func getLeagueRanking() {
        requestModel.leagueId = leagueId
        view?.startLoading()
        service.getLeagueRanking(mode, rankingType, requestModel) { response, status in
            if status {
                self.handleLeagueRankingResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
    
    private func handleLeagueRankingResponseSuccess(_ response: AnyObject) {
        if let result = response as? GlobalRankingModel {
            guard let meta = result.meta else {
                view?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    view?.finishLoading()
                    return
                }
                view?.alertMessage(message.localiz())
                return
            }
            
            if service.page == 1 {
                users.removeAll()
            }
            
            if let res = result.response {
                let data = res.data ?? [RankingData]()
                users += data
                if let team = res.team {
                    teamData = team
                }
                service.isFullData = res.nextPageURL == nil
            } else {
                service.isFullData = true
            }
            service.page += 1
        }
        
        view?.finishLoading()
        view?.reloadView()
    }
    
    //Get ranking by round
    func loadMoreRankingByRound(_ roundId: Int, _ leagueId: Int, _ teamId: Int) {
        if self.service.isFullData {
            return
        }
        getLeagueRankingByRound(roundId, leagueId, teamId)
    }
    
    func getLeagueRankingByRound(_ roundId: Int, _ leagueId: Int, _ teamId: Int) {
        view?.startLoading()
        service.getRankingByRound(roundId, leagueId, teamId) { (response, status) in
            if status {
                self.handleLeagueRankingResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
}
