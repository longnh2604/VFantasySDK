//
//  GlobalLeaguePointPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation
import SwiftDate

protocol GlobalLeaguePointView: BaseViewProtocol {
    func reloadView()
}

class GlobalLeaguePointPresenter: NSObject {
    
    private var service = GlobalRankingService()
    weak private var view: GlobalLeaguePointView?
        
    var users = [LeaguePointModelView]()
    var teamData: MyTeamData?
    
    var requestModel = GlobalRankingRequestModel()
    var displays = [LeaguePointFilterData]()
    
    var filterKey = ""
    var leagueId = 0
    var league: LeagueDatum?
    
    func attachView(view: GlobalLeaguePointView) {
        self.view = view
    }
    
    func loadMorePoint() {
        getLeaguePoint()
    }
    
    func getLeaguePoint() {
        requestModel.leagueId = leagueId
        if let round = Int(filterKey) {
            requestModel.byGameweek = round
            requestModel.byMonth = ""
        } else {
            requestModel.byGameweek = 0
            requestModel.byMonth = filterKey
        }
        view?.startLoading()
        service.getLeagueRanking(.global, .none, requestModel) { response, status in
            if status {
                self.handleLeaguePointResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
    
    private func handleLeaguePointResponseSuccess(_ response: AnyObject) {
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
           
            if let res = result.response {
                let data = res.data ?? [RankingData]()
                for item in data {
                    let modelView = GlobalLeaguePointMappingData.mappingLeaguePointDataToModelView(item)
                    users.append(modelView)
                }
                teamData = res.team
            }

            service.page += 1
           
            updateDisplays(displays: getDataDisplay())
        }
        
        view?.finishLoading()
        view?.reloadView()
    }
    
    // MARK: - Setup Filter
    
    func getDataDisplay() -> [LeaguePointFilterData] {
        var data = [LeaguePointFilterData]()
        var titleName = ""
        
        if filterKey.isEmpty {
            titleName = "GW\(users.first?.gameweek?.round ?? 0)".localiz()
        } else{
            titleName = Int(filterKey) != nil ? "From GW\(filterKey)" : "From \(getMonthName(filterKey))"
        }
        let point = LeaguePointFilterData()
        point.name = titleName.localiz()
        point.key = "point"
        data.append(point)
        
        if filterKey.isEmpty {
            let totalPoint = LeaguePointFilterData()
            totalPoint.name = "Total".localiz()
            totalPoint.key = "totalPoint"
            data.append(totalPoint)
        }
        
        return data
    }
    
    private func getMonthName(_ dateString: String) -> String {
        let startDate = dateString.toDateComponents(DateFormat.kyyyyMM)
        let month = startDate.month ?? 0
        let monthNumber = month > 0 ? month - 1 : 0
        return Month(rawValue: monthNumber)?.description ?? ""
    }
    
    func updateDisplays(displays: [LeaguePointFilterData]) {
        self.displays = displays
    }
}
