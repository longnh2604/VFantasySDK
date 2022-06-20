//
//  PlayerDetailPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit
import MZFormSheetPresentationController

struct StatisticWithTeamData {
    let name: String
    let key: String
    let value: Double
    
    // show value int or percent
    // 0 -> show int
    // 1 -> show percent (%)
    let type: Int
}

class PlayerDataModel: NSObject {
    var playerId: Int?
    var teamId: Int?
    var filter: String?
    var keyFilter: String = PlayerFilterKey.total
    var valueFilter: String = "all"
    
    override init() {
        super.init()
        
        let filters = [LineupOrderRequestModel(property: PlayerFilterKey.total, rela: "", orderOperator: "eq", value: "all")]
        let order = VFantasyCommon.validSortType(filters)
        
        self.filter = order
    }
}

struct PlayerStatisticsFilterRequest: Codable {
    let property, playerStatisticsOperator, value: String?
    
    enum CodingKeys: String, CodingKey {
        case property
        case playerStatisticsOperator = "operator"
        case value
    }
}

class PlayerDetailModelView {
    var name: String?
    var photo: String?
    var main_position: Int?
    var minor_position: Int?
    var transfer_value: Int?
    var total_point: Int?
    var nameFilter: String?
    var isInjured: Bool?
    var realClub: RealClub?
}

protocol PlayerDetailView: BaseViewProtocol {
    func reloadView()
    func onPick()
    func showHelper()
    func reloadWeekView(_ data: [CheckBoxData])
}

class PlayerDetailPresenter: NSObject {
    weak var playerDetailView: PlayerDetailView?
    var service: PlayerDetailService?
    
    var playerType: PlayerDetailType = .statistic
    
    var playerDetail = PlayerDetailModelView()
    
    var playerModel = PlayerDataModel()
    
    var statistics = [PlayerStatisticsMeta]()
    var statisticsTeam = [StatisticWithTeamData]()
    
    var totalPoints: Int {
        var totals: Int = 0
        for model in statisticsTeam {
            let types: [PlayerStatsType] = [.yellow_cards, .turnovers, .fouls_committed]
            if !types.filter({ return $0.rawValue == model.key.lowercased() }).isEmpty {
              totals -= model.value.roundToInt()
            } else {
              totals += model.value.roundToInt()
            }
        }
        return totals
    }
    
    var checkboxes = [CheckBoxData]()
    var canPick = false
    var selectingIndex = 0
    var pickingPlayer: Player?
    var isTransferGlobal: Bool = false
    var isPlayerStatsGlobal: Bool = false
    var isFilterGW: Bool {
        let data = selectedData != nil ? selectedData : firstData
        if let data = data {
            if data.key == "all" || data.key == "points_per_round" {
                return false
            }
            return true
        }
        return false
    }
    
    var gameplay = GamePlay.Transfer
    var playerListType = PlayerListType.playerList
    
    var myTeam: MyTeamData?
    var selectedData: CheckBoxData?
    var firstData: CheckBoxData?
    
    // MARK: - setup view
    init(service: PlayerDetailService) {
        super.init()
        self.service = service
    }
    
    func attackView(view: PlayerDetailView) {
        self.playerDetailView = view
        checkboxes = generateDropdownData()
    }
    
    func detachView () {
        self.playerDetailView = nil
    }
    
    func initData() {
        self.setupData()
        self.initStatistic()
        self.getPlayerDetail()

        self.getListGameweek()
    }
    
    private func setupData() {
        guard playerListType == .playerPool else { return }
        if isTransferGlobal || isPlayerStatsGlobal {
            var item: CheckBoxData = generateDropdownData().last!
            if isPlayerStatsGlobal {
                item = generateDropdownData().first!
            }
            let filters = [LineupOrderRequestModel(property: getKeyRequest(item.name ?? ""), rela: "", orderOperator: "eq", value: item.value)]
            let order = VFantasyCommon.validSortType(filters)
            self.selectedData = item
            self.playerModel.valueFilter = item.value ?? "all"
            self.playerModel.keyFilter = item.key ?? "total"
            self.playerModel.filter = order
        } else {
            let filters = [LineupOrderRequestModel(property: "gameweek", rela: "", orderOperator: "eq", value: "\(myTeam?.currentGW?.round ?? 0)")]
            let order = VFantasyCommon.validSortType(filters)
            self.playerModel.filter = order
        }
    }
    
    func initStatistic() {
        statistics.removeAll()
        statisticsTeam.removeAll()
        
        if playerType == .statisticWithTeam {
            self.getStatisticWithTeam()
        } else {
            self.getStatisticWithOutTeam()
        }
    }

    // MARK: - Statistic with team (Player detail)
    func getStatisticWithTeam() {
        self.playerDetailView?.startLoading()
        
        self.service?.getPlayerStatisticWithTeam(playerModel, callBack: { (response, status) in
            self.playerDetailView?.finishLoading()
            if status == false {
                CommonResponse.handleResponseFail(response, self.playerDetailView)
                return
            }
            
            self.updateDropdownData()
            
            if self.playerModel.keyFilter == PlayerFilterKey.points_per_round {
                // return array meta
                self.handleResponseStatisticSuccessfully(response)
            } else {
                // return object meta
                self.handleResponseStatisticObjectSuccessfully(response)
            }
        })
    }
    
    func handleResponseStatisticObjectSuccessfully(_ response: AnyObject) {
        if let data = response as? PlayerStatisticsObjectResponse {
            if let meta = data.meta {
                if meta.success == false {
                    self.playerDetailView?.alertMessage((meta.message ?? "").localiz())
                    return
                }
            }
            
            // set informantion player detail
            if let dataPlayer = data.response {
                self.playerDetail.total_point = dataPlayer.totalPoint
                self.playerDetail.nameFilter = FilterValue.total
            }
            
            if let statistic = data.response?.meta {
                // goals
                let modelGoals = StatisticWithTeamData(name: "goals".localiz().uppercased(), key: PlayerStatsType.goals.rawValue, value: statistic.goals ?? 0, type: 0)
                let modelAssists = StatisticWithTeamData(name: "assists".localiz().uppercased(), key: PlayerStatsType.assists.rawValue, value: statistic.assists ?? 0, type: 0)
                let modelCleanSheet = StatisticWithTeamData(name: "clean_sheet".localiz().uppercased(), key: PlayerStatsType.clean_sheet.rawValue, value: statistic.cleanSheet ?? 0, type: 0)
                let modelDuelsTheyWin = StatisticWithTeamData(name: "duels_they_win".localiz().uppercased(), key: PlayerStatsType.duels_they_win.rawValue, value: statistic.duelsTheyWin ?? 0, type: 0)
                let modelPasses = StatisticWithTeamData(name: "passes".localiz().uppercased(), key: PlayerStatsType.passes.rawValue, value: statistic.passes ?? 0, type: 0)
                let modelShots = StatisticWithTeamData(name: "shots".localiz().uppercased(), key: PlayerStatsType.shots.rawValue, value: statistic.shots ?? 0, type: 0)
                let modelSave = StatisticWithTeamData(name: "saves".localiz().uppercased(), key: PlayerStatsType.saves.rawValue, value: statistic.saves ?? 0, type: 0)
                let modelYellowCards = StatisticWithTeamData(name: "yellow_cards".localiz().uppercased(), key: PlayerStatsType.yellow_cards.rawValue, value: statistic.yellowCards ?? 0, type: 0)
                let modelDribbles = StatisticWithTeamData(name: "dribbles".localiz().uppercased(), key: PlayerStatsType.dribbles.rawValue, value: statistic.dribbles ?? 0, type: 0)
                let modelTurnOvers = StatisticWithTeamData(name: "red cards".localiz().uppercased(), key: PlayerStatsType.turnovers.rawValue, value: statistic.turnovers ?? 0, type: 0)
                let modelballRecovered = StatisticWithTeamData(name: "ball_recovered".localiz().uppercased(), key: PlayerStatsType.balls_recovered.rawValue, value: statistic.ballsRecovered ?? 0, type: 0)
                let modelFoulsCommitted = StatisticWithTeamData(name: "fouls_committed".localiz().uppercased(), key: PlayerStatsType.fouls_committed.rawValue, value: statistic.foulsCommitted ?? 0, type: 0)
                
                self.statisticsTeam = [modelGoals, modelAssists, modelCleanSheet, modelDuelsTheyWin, modelPasses, modelShots, modelSave, modelYellowCards, modelDribbles, modelTurnOvers, modelballRecovered, modelFoulsCommitted]
            }
            self.playerDetailView?.reloadView()
        }
    }
    
    func updateChekboxData(_ gameweeks: [CheckBoxData]) {
        self.checkboxes.removeAll()
        self.checkboxes.append(contentsOf: generateDropdownData())
        self.checkboxes.append(contentsOf: gameweeks)
    }
  
    func generateDropdownData() -> [CheckBoxData] {
        let checkList = [CheckBoxData("all", "all", FilterValue.total),
//                         CheckBoxData("1", "1", FilterValue.avg1),
//                         CheckBoxData("avgAll", "all", FilterValue.avgAll),
//                         CheckBoxData("avg5", "5", FilterValue.avg5),
//                         CheckBoxData("avg3", "3", FilterValue.avg3),
                         CheckBoxData("points_per_round", "all", FilterValue.points_per_round)]
        
        return checkList
    }
    
    func updateDropdownData() {
        checkboxes.forEach { checkData in
            if checkData.key == self.playerModel.keyFilter {
                checkData.selected = true
            } else {
                checkData.selected = false
            }
        }
    }
    
    // MARK: - Statistic (Lineup Player details)
    func getStatisticWithOutTeam() {
        self.playerDetailView?.startLoading()
        
        self.service?.getPlayerStatistic(playerModel, callBack: { (response, status) in
            self.playerDetailView?.finishLoading()
            if status == false {
                CommonResponse.handleResponseFail(response, self.playerDetailView)
                return
            }
            
            if self.playerModel.keyFilter == PlayerFilterKey.points_per_round {
                // return array meta
                self.handleResponseStatisticSuccessfully(response)
            } else {
                // return object meta
                self.handleResponseStatisticObjectSuccessfully(response)
            }
        })
    }
    
    func handleResponseStatisticSuccessfully(_ response: AnyObject) {
        if let data = response as? PlayerStatisticsResponse {
            if let meta = data.meta {
                if meta.success == false {
                    self.playerDetailView?.alertMessage((meta.message ?? "").localiz())
                    return
                }
            }
            
            if let dataPlayer = data.response {
                self.playerDetail.total_point = dataPlayer.totalPoint
                self.playerDetail.nameFilter = FilterValue.total
            }
            
            if let statistics = data.response?.metas {
                statistics.forEach { (meta) in
                    self.statistics.append(meta)
                }
            }
            self.playerDetailView?.reloadView()
        }
    }
    
    // MARK: - Handle get player detail
    
    func getPlayerDetail() {
        service?.getPlayerDetail(playerModel) { response, status in
            if status {
                self.handleGetPlayerDetailInResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.playerDetailView)
            }
        }
    }
    
    private func handleGetPlayerDetailInResponseSuccess(_ response: AnyObject) {
        if let result = response as? PlayerDetailResponse {
            guard let meta = result.meta else {
                playerDetailView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    playerDetailView?.finishLoading()
                    return
                }
                playerDetailView?.alertMessage(message.localiz())
                return
            }
            
            if let dataPlayer = result.response {
                self.playerDetail.name = dataPlayer.getNameDisplay() ?? ""
                self.playerDetail.photo = dataPlayer.photo ?? ""
                self.playerDetail.main_position = dataPlayer.mainPosition
                self.playerDetail.minor_position = dataPlayer.minorPosition
                self.playerDetail.transfer_value = dataPlayer.transferValue
                self.playerDetail.isInjured = dataPlayer.isInjured
                self.playerDetail.realClub = dataPlayer.realClub
            }
            
            playerDetailView?.finishLoading()
            playerDetailView?.reloadView()
        }
    }
  
  private func getKeyRequest(_ value: String) -> String {
    switch value {
    case FilterValue.total:
      return PlayerFilterKey.total
    case FilterValue.points_per_round:
      return PlayerFilterKey.points_per_round
    default:
      return PlayerFilterKey.avg
    }
  }
    
}

// MARK: - CustomCellPlayerDetailInfoDelegate
extension PlayerDetailPresenter: CustomCellPlayerDetailInfoDelegate {
    func showInfo() {
        playerDetailView?.showHelper()
    }
    
    func didPickPlayer() {
        self.playerDetailView?.onPick()
    }
    
    func didClickSeason(_ item: CheckBoxData) {
        selectedData = item
        if item.key == "all" || item.key == "points_per_round" {
            let filters = [LineupOrderRequestModel(property: getKeyRequest(item.name ?? ""), rela: "", orderOperator: "eq", value: item.value)]
            let order = VFantasyCommon.validSortType(filters)
            
            self.playerModel.valueFilter = item.value ?? "all"
            self.playerModel.keyFilter = item.key ?? "total"
            self.playerModel.filter = order
            self.initStatistic()
        } else {
            didPickGameweek(item)
        }
    }
    
    func didPickGameweek(_ item: CheckBoxData) {
        let filters = [LineupOrderRequestModel(property: "gameweek", rela: "", orderOperator: "eq", value: item.value)]
        let order = VFantasyCommon.validSortType(filters)
        
        self.playerModel.valueFilter = item.value ?? ""
        self.playerModel.keyFilter = item.key ?? ""
        self.playerModel.filter = order
        self.initStatistic()
    }
}

extension PlayerDetailPresenter {
    
    //MARK: Gameweek List
    
    func getListGameweek() {
        playerDetailView?.startLoading()
        service?.getGameweekList(callback: { (result, status) in
            self.handleGameweekListCallback(result, status)
        })
    }
    
    private func handleGameweekListCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, playerDetailView)
        } else {
            self.handleGameweekResponseSuccess(result)
        }
    }
    
    private func handleGameweekResponseSuccess(_ response: AnyObject) {
        if let result = response as? GlobalGameWeekModel {
            guard let meta = result.meta else {
                playerDetailView?.finishLoading()
                playerDetailView?.reloadWeekView([])
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    playerDetailView?.finishLoading()
                    playerDetailView?.reloadWeekView([])
                    return
                }
                playerDetailView?.alertMessage(message.localiz())
                return
            }
            if let data = result.response {
                let dataGW = data.data ?? [GameWeek]()
                playerDetailView?.reloadWeekView(convertData(from: dataGW))
            } else {
                playerDetailView?.reloadWeekView([])
            }
        } else {
            playerDetailView?.reloadWeekView([])
        }
        playerDetailView?.finishLoading()
        
    }
    
    private func convertData(from weeks: [GameWeek]) -> [CheckBoxData] {
        return weeks.map { (week) -> CheckBoxData in
            return CheckBoxData("\(week.id ?? 0)", "\(week.round ?? 0)", week.title ?? "")
        }
    }
}

