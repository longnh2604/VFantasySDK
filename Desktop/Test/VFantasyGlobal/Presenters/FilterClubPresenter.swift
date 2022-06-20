//
//  FilterClubPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

class FilterData: NSObject {
    var name = ""
    var key = ""
    var direction = SortType.none
    var isSelected = false
}

class FilterSection: NSObject {
    var name = ""
    var data = [FilterData]()
}

protocol FilterClubView: BaseViewProtocol {
    func reloadView()
}

class FilterClubPresenter: NSObject {
    private var service: FilterClubService?
    weak private var filterClubView: FilterClubView?
    
    var filtersSection = [FilterSection]()
    var currentCheckPosition = [FilterData]()
    var currentCheckClub = [FilterData]()
    
    //MARK:- setup view
    init(service:FilterClubService) {
        super.init()
        self.service = service
    }
    
    func attackView(view:FilterClubView) {
        self.filterClubView = view
    }
    
    func detachView () {
        self.filterClubView = nil
    }
    
    func initData(showPosition: Bool) {
        if showPosition {
            let sectionPosition = FilterSection()
            sectionPosition.name = "FILTERED BY POSITION".localiz()
            
            let attacker = FilterData()
            attacker.name = "Attacker".localiz()
            attacker.key = "\(PlayerPositionType.attacker.rawValue)"
            if checkCurrentPositionCheck(key: attacker.key) {
                attacker.isSelected = true
            }
            
            let Midfielder  = FilterData()
            Midfielder.name = "Midfielder".localiz()
            Midfielder.key = "\(PlayerPositionType.midfielder.rawValue)"
            if checkCurrentPositionCheck(key: Midfielder.key) {
                Midfielder.isSelected = true
            }
            
            let Defender = FilterData()
            Defender.name = "Defender".localiz()
            Defender.key = "\(PlayerPositionType.defender.rawValue)"
            if checkCurrentPositionCheck(key: Defender.key) {
                Defender.isSelected = true
            }
            
            let Goalkeeper  = FilterData()
            Goalkeeper.name = "Goalkeeper".localiz()
            Goalkeeper.key = "\(PlayerPositionType.goalkeeper.rawValue)"
            if checkCurrentPositionCheck(key: Goalkeeper.key) {
                Goalkeeper.isSelected = true
            }
            
            sectionPosition.data = [attacker, Midfielder, Defender, Goalkeeper]
            filtersSection.append(sectionPosition)
        }
        
        // section club
        let data = [FilterData]()
        let sectionClub = FilterSection()
        sectionClub.name = "FILTERED BY CLUB".localiz()
        sectionClub.data = data
        
        filtersSection.append(sectionClub)
        
        self.listClubs()
    }
    
    func checkCurrentPositionCheck(key:String) -> Bool {
        var isCheck = false
        for index in 0 ..< currentCheckPosition.count {
            let object = currentCheckPosition[index]
            if object.key == key  {
                isCheck = true
                break
            }
        }
        return isCheck
    }
    
    func checkCurrentClubCheck(key:String) -> Bool {
        var isCheck = false
        for index in 0 ..< currentCheckClub.count {
            let object = currentCheckClub[index]
            if object.key == key  {
                isCheck = true
                break
            }
        }
        return isCheck
    }
    
    func checkDataPositionCheckMark(isShowPosition: Bool = true) -> [FilterData] {
        guard isShowPosition else { return [] }
        var position = [FilterData]()
        filtersSection[0].data.forEach { (filterData) in
            if filterData.isSelected {
                position.append(filterData)
            }
        }
        return position
    }
    
    func checkDataClubCheckMark() -> [FilterData] {
        var club = [FilterData]()
        if let filterSection = filtersSection.last {
            filterSection.data.forEach { (filterData) in
                if filterData.isSelected {
                    club.append(filterData)
                }
            }
        }
        return club
    }
    
    //MARK:- call api get list club
    func listClubs() {
        guard let filterClubView = self.filterClubView else {
            return
        }
        filterClubView.startLoading()
        self.service?.getListClub(callBack: { (response, status) in
            filterClubView.finishLoading()
            
            if status == false {
                return
            }
            
            if let data = response as? ClubObjectResponse {
                if data.meta?.success == false {
                    return
                }
                guard let responseData = data.response else {return}
                
                self.handleClubSuccessfully(response: responseData)
            }
        })
    }
    
    func handleClubSuccessfully(response:ClubResponse) {
        guard let clubDatas = response.data else {return}
        
        if let filterSection = filtersSection.last {
            clubDatas.forEach({ (clubData) in
                
                let filterData = FilterData()
                filterData.name = clubData.name ?? ""
                filterData.key = "\(clubData.id ?? -1)"
                filterData.isSelected = self.checkCurrentClubCheck(key: filterData.key)
                filterSection.data.append(filterData)
                
                self.service?.page += 1
                self.filterClubView?.reloadView()
            })
        }
    }
}

