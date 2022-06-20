//
//  DisplayPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation
import UIKit
protocol DisplayView: BaseViewProtocol {
    func reloadView()
}

class DisplayPresenter: NSObject {
    weak private var displayView:DisplayView?
    
    var displaySection = [FilterSection]()
    var currentCheck = [FilterData]()
    var hideValueFilter = false
    
    func attackView(view:DisplayView) {
        self.displayView = view
    }
    
    func detachView () {
        self.displayView = nil
    }
    
    func initData() {
        let sectionDisplay = FilterSection()
        sectionDisplay.name = "".localiz()
        
        if !hideValueFilter {
            let value = FilterData()
            value.name = "value".localiz().upperFirstCharacter()
            value.key = "\(DisplayKey.value)"
            if checkCurrentDisplayCheck(key: value.key) {
                value.isSelected = true
            }
            sectionDisplay.data.append(value)
        }
        
        let point  = FilterData()
        point.name = "point".localiz()
        point.key = DisplayKey.point
        if checkCurrentDisplayCheck(key: point.key) {
            point.isSelected = true
        }
        sectionDisplay.data.append(point)
        
        let stat1 = FilterData()
        stat1.name = "goals".localiz()
        stat1.key = DisplayKey.goals
        if checkCurrentDisplayCheck(key: stat1.key) {
            stat1.isSelected = true
        }
        sectionDisplay.data.append(stat1)
        
        let stat2 = FilterData()
        stat2.name = "assists".localiz()
        stat2.key = DisplayKey.assists
        if checkCurrentDisplayCheck(key: stat2.key) {
            stat2.isSelected = true
        }
        sectionDisplay.data.append(stat2)
        
        let stat3 = FilterData()
        stat3.name = "clean_sheet".localiz()
        stat3.key = DisplayKey.clean_sheet
        if checkCurrentDisplayCheck(key: stat3.key) {
            stat3.isSelected = true
        }
        sectionDisplay.data.append(stat3)
        
        let stat4 = FilterData()
        stat4.name = "duels_they_win".localiz()
        stat4.key = DisplayKey.duels_they_win
        if checkCurrentDisplayCheck(key: stat4.key) {
            stat4.isSelected = true
        }
        sectionDisplay.data.append(stat4)
        
        let stat5 = FilterData()
        stat5.name = "passes".localiz()
        stat5.key = DisplayKey.passes
        if checkCurrentDisplayCheck(key: stat5.key) {
            stat5.isSelected = true
        }
        sectionDisplay.data.append(stat5)
        
        let stat6 = FilterData()
        stat6.name = "shots".localiz()
        stat6.key = DisplayKey.shots
        if checkCurrentDisplayCheck(key: stat6.key) {
            stat6.isSelected = true
        }
        sectionDisplay.data.append(stat6)
        
        let stat7 = FilterData()
        stat7.name = "saves".localiz()
        stat7.key = DisplayKey.saves
        if checkCurrentDisplayCheck(key: stat7.key) {
            stat7.isSelected = true
        }
        sectionDisplay.data.append(stat7)
        
        let stat8 = FilterData()
        stat8.name = "yellow_cards".localiz()
        stat8.key = DisplayKey.yellow_cards
        if checkCurrentDisplayCheck(key: stat8.key) {
            stat8.isSelected = true
        }
        sectionDisplay.data.append(stat8)
        
        let stat9 = FilterData()
        stat9.name = "dribbles".localiz()
        stat9.key = DisplayKey.dribbles
        if checkCurrentDisplayCheck(key: stat9.key) {
            stat9.isSelected = true
        }
        sectionDisplay.data.append(stat9)
        
        let stat10 = FilterData()
        stat10.name = "red cards".localiz()
        stat10.key = DisplayKey.turnovers
        if checkCurrentDisplayCheck(key: stat10.key) {
            stat10.isSelected = true
        }
        sectionDisplay.data.append(stat10)
        
        let stat11 = FilterData()
        stat11.name = "ball_recovered".localiz()
        stat11.key = DisplayKey.balls_recovered
        if checkCurrentDisplayCheck(key: stat11.key) {
            stat11.isSelected = true
        }
        sectionDisplay.data.append(stat11)
        
        let stat12 = FilterData()
        stat12.name = "fouls_committed".localiz()
        stat12.key = DisplayKey.fouls_committed
        if checkCurrentDisplayCheck(key: stat12.key) {
            stat12.isSelected = true
        }
        
        sectionDisplay.data.append(stat12)
        displaySection.append(sectionDisplay)
        
        replaceDisplay()
    }
    
    func checkCurrentDisplayCheck(key:String) -> Bool {
        var isCheck = false
        for index in 0 ..< currentCheck.count {
            let object = currentCheck[index]
            if object.key == key  {
                isCheck = true
                break
            }
        }
        return isCheck
    }
    
    func replaceDisplay() {
        let data = displaySection[0].data
        let count = data.count
        for index in 0...count - 1 {
            let display = data[index]
            if let duplicate = currentCheck.first(where: { $0.key == display.key }) {
                displaySection[0].data[index] = duplicate
                displaySection[0].data[index].isSelected = true
            }
        }
    }
    
    func checkDataDisplayCheckMark() -> [FilterData] {
        var display = [FilterData]()
        displaySection[0].data.forEach { (filterData) in
            if filterData.isSelected {
                display.append(filterData)
            }
        }
        return display
    }
}
