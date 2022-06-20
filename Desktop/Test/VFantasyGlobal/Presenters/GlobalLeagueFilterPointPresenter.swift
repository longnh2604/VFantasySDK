//
//  GlobalLeagueFilterPointPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation
import SwiftDate

class LeaguePointFilterSection: NSObject {
    var name = ""
    var data = [LeaguePointFilterData]()
}

protocol LeagueFilterPointView: BaseViewProtocol {
    func reloadView()
}

class GlobalLeagueFilterPointPresenter: NSObject {
    
    private var service = GlobalLeagueFilterPointService()
    weak private var view: LeagueFilterPointView?
    
    var filtersSection = [LeaguePointFilterSection]()
    
    var gameweeks = [GameWeek]()
    var leagueId = 0
    var league: LeagueDatum?
    var startMonths = [String]()
    
    func attackView(view: LeagueFilterPointView) {
        self.view = view
        self.setupByMonths()
    }
    
    func getGameweekList() {
        view?.startLoading()
        service.getGameweekList(leagueId) { response, status in
            if status {
                self.handleResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
    
    private func handleResponseSuccess(_ response: AnyObject) {
        if let result = response as? GlobalGameWeekModel {
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
                let data = res.data ?? [GameWeek]()
                gameweeks = data
                loadData()
            }

            service.page += 1
        }
        
        view?.finishLoading()
        view?.reloadView()
    }
    
    // MARK: - Load data
    
    private func loadData() {
        guard !gameweeks.isEmpty else { return }
        
        // By gameweek section
        var dataByGW = [LeaguePointFilterData]()
        let sectionByGW = LeaguePointFilterSection()
        
        sectionByGW.name = "by_gameweek".localiz().uppercased()
        for item in gameweeks {
            let data = LeaguePointFilterData()
            data.name = "From \(String(item.title ?? ""))"
            data.key = String(item.round ?? 0)
            dataByGW.append(data)
        }
        sectionByGW.data = dataByGW
        
        filtersSection.append(sectionByGW)
    }
    
    private func setupByMonths() {
        self.setListByMonth()
        
        guard !startMonths.isEmpty else { return }
        
        // By month section
        var dataByMonth = [LeaguePointFilterData]()
        let sectionByMonth = LeaguePointFilterSection()
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.kyyyyMM
        
        sectionByMonth.name = "by_month".localiz().uppercased()
        for month in startMonths {
            let data = LeaguePointFilterData()
            let startDate = month.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss) ?? Date()
            let stringDate = dateFormatter.string(from: startDate)
            data.name = getMonthName(month)
            data.key = stringDate
            dataByMonth.append(data)
        }
        sectionByMonth.data = dataByMonth.removingDuplicates(byKey: \.key)
        
        filtersSection.append(sectionByMonth)
    }
    
    private func getMonthName(_ dateString: String) -> String {
        guard !dateString.isEmpty else { return "" }
        let startDate = dateString.toDateComponents(DateFormat.kyyyyMMdd_hhmmss)
        let month = startDate.month ?? 0
        let monthNumber = month > 0 ? month - 1 : 0
        return Month(rawValue: monthNumber)?.description ?? ""
    }
    
    private func setListByMonth() {
        let formatter = DateFormat.kyyyyMMdd_hhmmss
        let startAtDate = league?.startAt?.toDate(fromFormat: formatter) ?? Date()
        let startAtString = startAtDate.toString(formatter: formatter, locale: Locale.current.identifier)
        let nowDateString = Date().toString(formatter: formatter, locale: Locale.current.identifier)
        self.startMonths = getMonthAndYearBetween(from: startAtString, to: nowDateString)
        if startMonths.isEmpty {
            self.startMonths.append(league?.startAt ?? "")
        }
    }
}

extension GlobalLeagueFilterPointPresenter {
    
    func getMonthAndYearBetween(from start: String, to end: String) -> [String] {
        let format = DateFormatter()
        format.dateFormat = DateFormat.kyyyyMMdd_hhmmss

        guard let startDate = format.date(from: start),
            let endDate = format.date(from: end) else {
                return []
        }

        let calendar = Calendar(identifier: .gregorian)
        let fromMonth = startDate.month
        var endMonth = endDate.month
        if endMonth < fromMonth {
            endMonth += 12
        }
//        let components = calendar.dateComponents(Set([.month]), from: startDate, to: endDate)

        var allDates: [String] = []
        let dateRangeFormatter = DateFormatter()
        dateRangeFormatter.dateFormat = DateFormat.kyyyyMMdd_hhmmss

//        guard let months = components.month else { return [] }
        
        for i in 0 ... (endMonth - fromMonth) {
            guard let date = calendar.date(byAdding: .month, value: i, to: startDate) else { continue }

            let formattedDate = dateRangeFormatter.string(from: date)
            allDates += [formattedDate]
        }
        return allDates
    }
}
