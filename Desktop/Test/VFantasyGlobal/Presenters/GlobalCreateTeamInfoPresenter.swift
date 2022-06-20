//
//  GlobalCreateTeamInfoPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import UIKit

protocol GlobalCreateTeamInfoView : BaseViewProtocol {
    func didSelectPageControl(_ pos: Int)
    func reloadView(_ index: Int)
    func onChangedSort()
    func updateBudget()
    func updatePlayerInfo()
    func completeLineup()
    func reloadLineup()
    func updateGameWeek(gameWeek: GameWeekInfo)
}

class GlobalCreateTeamInfoPresenter: NSObject {
    weak private var view: GlobalCreateTeamInfoView?
    private var teamInfoType: CreateTeamInfoType = .lineup
    
    var leagueID = 0
    var teamID = 0
    var round = 0
    var currentPage = 0
    
    var model = PlayerRequestModel()
    private var playerService = CreateTeamInfoService()
    private let teamService = CreateTeamInfoService()
    private let randomIndex = -1
    
    var playerListInfo = TeamPlayerInfo()
    var playerLineupInfo = TeamPlayerInfo()
    var nextGameWeek = GameWeekInfo()
    var leagueTeamInfo = LeagueTeamInfo()
    var searchText = ""
    var currentSortType = SortType.desc
    var canPickLineup = false
    var completedLineup = false
    var showingHUD = false
    var sumValueOfPlayer: Int = 0
    private var triggerSort = false
    private var canLoadMorePlayers = true
    
    var attackers = [Player?]()
    var midfielders = [Player?]()
    var defenders = [Player?]()
    var goalkeepers = [Player?]()
    func attachView(view: GlobalCreateTeamInfoView) {
        self.view = view
        initPlayersForPosition()
    }
    
    func detachView() {
        self.view = nil
    }
    
    deinit {
        print("Deinit CreateTeamInfoPresenter")
    }
    
    // MARK: - Player list
    func refreshPlayerList(_ toggleSort: Bool = false) {
        playerListInfo.isRefreshing = true
        playerListInfo.removeAllPlayers()
        playerService.page = 1
        canLoadMorePlayers = true
        
        if toggleSort {
            let sort = VFantasyCommon.changeSorting(currentSortType)
            currentSortType = sort
            triggerSort = true
        }
        
        let transferRequestModel = TransferRequestModel(property: "value", direction: currentSortType.rawValue)
        model.order = VFantasyCommon.validSortType([transferRequestModel])
        
        if showingHUD {
            view?.startLoading()
        }
        getPlayerList()
    }
    
    func morePlayers() {
        getPlayerList()
    }
    
    func noPlayers() -> Bool {
        return playerListInfo.players.count == 0
    }
    
    func isAllowPickClup(realClupID: Int) -> Bool {
        let total = self.playerLineupInfo.players.filter { $0.realClubID == realClupID }.count
        return total < 3
    }
    
    func isAllowPickPlayer(player: Player) -> Bool {
        return (playerLineupInfo.budget ?? 0.0) >= Double(player.transferValue ?? 0)
    }
        
    func getPlayerList() {
        if model.requesting { return }
        model.requesting = true
        
        model.leagueID = String(leagueID)
        model.keyword = searchText
        model.season_id = String(playerLineupInfo.seasonId ?? 0)
        
        if canLoadMorePlayers {
            playerService.getPlayerList(model) { (response, success) in
                self.view?.finishLoading()
                if success {
                    self.handlePlayerListResponseSuccess(response)
                } else {
                    CommonResponse.handleResponseFail(response, self.view)
                }
                self.model.requesting = false
            }
        } else {
            view?.finishLoading()
        }
        self.model.requesting = false
    }
    
    private func handlePlayerListResponseSuccess(_ response: AnyObject) {
        if let result = response as? PlayerListData {
            guard let meta = result.meta else {
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    return
                }
                view?.alertMessage(message.localiz())
                return
            }
            
            if let res = result.response {
                if res.nextPageURL == nil {
                    canLoadMorePlayers = false
                }
                if let newData = res.data {
                    playerListInfo.players += newData
                    playerService.page += 1
                }
                playerListInfo.statistic = res.statistic
                view?.reloadView(0)
            }
            
            playerListInfo.isRefreshing = false
            if triggerSort {
                view?.onChangedSort()
                triggerSort = false
            } else {
                view?.reloadView(1)
            }
        }
    }
    
    func sortPosition(_ pos: Int) {
        model.position = "\(pos)"
    }
    
    func availablePositionIndexForPlayer(_ player: Player) -> Int? {
        var returnValue: Int? = nil
        let message = "no_vacancy_for_this_position".localiz()
        if let mainPos = player.mainPosition {
            switch mainPos {
            case PlayerPositionType.goalkeeper.rawValue:
                if let availablePos = VFantasyCommon.availablePositionIndex(goalkeepers) {
                    returnValue = availablePos
                } else {
                    view?.alertMessage(message)
                }
            case PlayerPositionType.defender.rawValue:
                if let availablePos = VFantasyCommon.availablePositionIndex(defenders) {
                    returnValue = availablePos
                } else {
                    view?.alertMessage(message)
                }
            case PlayerPositionType.midfielder.rawValue:
                if let availablePos = VFantasyCommon.availablePositionIndex(midfielders) {
                    returnValue = availablePos
                } else {
                    view?.alertMessage(message)
                }
            default:
                if let availablePos = VFantasyCommon.availablePositionIndex(attackers) {
                    returnValue = availablePos
                } else {
                    view?.alertMessage(message)
                }
            }
        }
        
        return returnValue
    }
    
    private func fillPlayerIntoAvailablePositions(_ player: Player) {
        if let newPos = VFantasyCommon.availablePositionIndex(attackers) {
            attackers[newPos] = player
        } else if let newPos = VFantasyCommon.availablePositionIndex(midfielders) {
            midfielders[newPos] = player
        } else if let newPos = VFantasyCommon.availablePositionIndex(defenders) {
            defenders[newPos] = player
        } else if let newPos = VFantasyCommon.availablePositionIndex(goalkeepers) {
            goalkeepers[newPos] = player
        }
    }
    
    // MARK: - Lineup
    func getLineup() {
        view?.startLoading()
        
        CreateTeamInfoService().getLineup(teamID) { (response, success) in
            if success {
                self.handleLineupResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
    
     func handleLineupResponseSuccess(_ response: AnyObject) {
        if let result = response as? LineupData {
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
                print("Mess:", message.localiz())
                return
            }
            
            if let res = result.response {
                handleLineupResponse(res)
                view?.finishLoading()
            }
            
            view?.finishLoading()
        }
    }
    func calValuePlayers(players: [Player]) {
        let listValueOfPlayer = players.map {$0.transferValue}
        var sum = 0
        for value in listValueOfPlayer {
            guard let value = value else {return}
            sum = sum + value
        }
        sumValueOfPlayer = sum
        print("Summmmm:", sum)
    }
    func handleLineupResponse(_ res: LineupResponse) {
        if let newData = res.players {
            playerLineupInfo.players = newData
            calValuePlayers(players: playerLineupInfo.players)
        }
        playerLineupInfo.statistic = res.statistic
        playerLineupInfo.budget = res.team?.currentBudget
        playerLineupInfo.seasonId = res.league?.seasonID
        if let totalPlayer = res.team?.totalPlayers {
            playerLineupInfo.totalPlayers = totalPlayer
        }
        if let gameWeek = res.nextGameWeek {
            nextGameWeek.id = gameWeek.id
            nextGameWeek.round = gameWeek.round
            nextGameWeek.startAt = gameWeek.startAt
            nextGameWeek.endAt = gameWeek.endAt
            nextGameWeek.title = gameWeek.title
            NotificationCenter.default.post(name: NotificationName.updateGameWeek, object: nil, userInfo: [NotificationKey.updateGameWeek : nextGameWeek])
        }
        if let gameplayValue = res.league?.gameplayOption {
            let gameplay = GamePlay.fromHashValue(hashValue: gameplayValue)
            playerLineupInfo.gameplay = gameplay
            
            if gameplay == .Transfer {
                handleLineupTransfer(res)
            } else {
                handleLineupDraft(res)
            }
        }
        
        if let completed = res.team?.isCompleted {
            if playerLineupInfo.fullLineup() {
                completedLineup = completed
            } else {
                completedLineup = false
            }
        }
        
        //get number of teams for tab 3
        leagueTeamInfo.currentTeams = res.league?.currentNumberOfUser ?? 0
        leagueTeamInfo.maxTeams = res.league?.numberOfUser ?? 0
        
        reloadPlayersForPosition()
        NotificationCenter.default.post(name: NotificationName.updateField, object: nil, userInfo: [NotificationKey.showValue : true])
        view?.reloadView(0)
        //reload tab 3 also
        view?.reloadView(2)
    }
    
    private func handleLineupTransfer(_ res: LineupResponse) {
        //if current time surpass setup date, change label title and use start time instead of setup time
        if let setupTime = res.league?.teamSetup, let startTime = res.league?.startAt {
            if let setupDate = setupTime.toDate {
                if setupDate.surpass(Date()) {
                    playerLineupInfo.time = setupTime.validDisplayTime()
                } else {
                    playerLineupInfo.time = startTime.validDisplayTime()
                }
            }
        }
    }
    
    private func handleLineupDraft(_ res: LineupResponse) {
        if let draftTime = res.league?.draftTime?.toDate,
            let status = res.league?.status,
            let timePerPick = res.league?.timeToPick,
            let startTime = res.league?.startAt {
            let leagueStatus = LeagueStatus.fromHashValue(hashValue: status)
            if leagueStatus == .waitingForStart {
                playerLineupInfo.seconds = draftTime.seconds(from: Date())
            } else {
                playerLineupInfo.seconds = nil
            }
            playerLineupInfo.secondsToStartTime = startTime.toDate?.seconds(from: Date())
            playerLineupInfo.timePerPick = timePerPick
        }
        
        if let draftStatus = res.league?.draftRunning {
            print("Draft status: \(draftStatus)")
            if draftStatus == 1 {
                playerLineupInfo.draftStatus = .started
            } else if draftStatus == 2 {
                playerLineupInfo.draftStatus = .finished
            } else {
                playerLineupInfo.draftStatus = .waitingForStart
            }
        }
    }
    
    func getLastTurn() -> LastPickTurn? {
        return playerLineupInfo.players.last?.lastPickTurn
    }
    
    func reloadPlayersForPosition() {
        initPlayersForPosition()
        
        let players = playerLineupInfo.players
        let count = players.count
        if count > 0 {
            for i in 0...count - 1 {
                let player = players[i]
                if let mainPos = player.mainPosition, let order = player.order {
                    //Check each Position,
                    //If order of player is random (picked from Android player list) -> order = -1 -> find available position for that player -> add to list
                    //Else if order != -1 (picked from iOS player list) -> add player to list
                    switch mainPos {
                    case PlayerPositionType.goalkeeper.rawValue:
                        if order == randomIndex {
                            if let newPos = VFantasyCommon.availablePositionIndex(goalkeepers) {
                                goalkeepers[newPos] = player
                            }
                        } else {
                            if order > 0 && order <= goalkeepers.count {
                                goalkeepers[order - 1] = player
                            }
                        }
                    case PlayerPositionType.defender.rawValue:
                        if order == randomIndex {
                            if let newPos = VFantasyCommon.availablePositionIndex(defenders) {
                                defenders[newPos] = player
                            }
                        } else {
                            if order > 0 && order <= defenders.count {
                                defenders[order - 1] = player
                            }
                        }
                    case PlayerPositionType.midfielder.rawValue:
                        if order == randomIndex {
                            if let newPos = VFantasyCommon.availablePositionIndex(midfielders) {
                                midfielders[newPos] = player
                            }
                        } else {
                            if order > 0 && order <= midfielders.count {
                                midfielders[order - 1] = player
                            }
                        }
                    default:
                        if order == randomIndex {
                            if let newPos = VFantasyCommon.availablePositionIndex(attackers) {
                                attackers[newPos] = player
                            }
                        } else {
                            if order > 0 && order <= attackers.count {
                                attackers[order - 1] = player
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func initPlayersForPosition() {
        attackers = [nil, nil, nil, nil]
        midfielders = [nil, nil, nil, nil, nil, nil]
        defenders = [nil, nil, nil, nil, nil, nil]
        goalkeepers = [nil, nil]
    }
    
    // MARK: - Add Player
    func addPlayer(_ player: Player, response: TurnReceiveData? = nil) {
        view?.startLoading()
        if let id = player.id, let order = player.order {
            CreateTeamInfoService().addPlayer(id, teamID, order, currentResponse: response) { response, success in
                if success {
                    self.handleAddPlayerResponseSuccess(response, player)
                } else {
                    CommonResponse.handleResponseFail(response, self.view)
                }
            }
        }
    }
    
    private func updateLineup(_ player: Player) {
        //update Field
        if player.order == nil {
            fillPlayerIntoAvailablePositions(player)
        } else {
            reloadPlayersForPosition()
        }
        NotificationCenter.default.post(name: NotificationName.updateField, object: nil, userInfo: [NotificationKey.showValue : true])
        
        //update Statistic
        if let updatedStatistic = VFantasyCommon.upgradeStatistic(playerLineupInfo.statistic, player: player) {
            //save for reuse
            playerLineupInfo.statistic = updatedStatistic
            //Notify to PositionContainerCell to update data
            NotificationCenter.default.post(name: NotificationName.updateStatistic, object: nil, userInfo: [NotificationKey.statistic : updatedStatistic])
        }
        
        //update player status
        view?.updatePlayerInfo()
    }
    
    func handleAddPlayerResponseSuccess(_ response: AnyObject, _ player: Player) {
        if let result = response as? AddPlayerData {
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
            
            if playerLineupInfo.gameplay == .Transfer {
                if let res = result.response {
                    let team = res.team
                    let budget = team?.currentBudget ?? 0
                    
                    playerLineupInfo.players.append(player)
                    view?.updatePlayerInfo()
                    calValuePlayers(players: playerLineupInfo.players)
                    playerLineupInfo.budget = budget
                }
                updateLineup(player)
                // update
                //update budget info
                view?.updateBudget()
            }
            //finish
            view?.finishLoading()
        }
    }
    
    // MARK: - Remove player
    func removePlayer(_ player: Player, response: TurnReceiveData? = nil) {
        view?.startLoading()
        
        if let id = player.id {
            CreateTeamInfoService().removePlayer(id, teamID, currentResponse: response) { response, success in
                if success {
                    self.handleRemovePlayerResponseSuccess(response, player)
                } else {
                    CommonResponse.handleResponseFail(response, self.view)
                }
            }
        }
    }
    
    func handleRemovePlayerResponseSuccess(_ response: AnyObject, _ player: Player) {
        view?.finishLoading()
         if let result = response as? AddPlayerData {
            guard let meta = result.meta else { return }
            if meta.success == false {
                guard let message = meta.message else { return }
                view?.alertMessage(message.localiz())
                return
            }
            if let res = result.response {
                let team = res.team
                let budget = team?.currentBudget ?? 0
                let players = playerLineupInfo.players
                playerLineupInfo.players = players.filter { $0 != player }
                playerLineupInfo.budget = budget
                calValuePlayers(players: playerLineupInfo.players)
            }
            
            //update Field
            //updateLineup(player)
            reloadPlayersForPosition()
            NotificationCenter.default.post(name: NotificationName.updateField, object: nil)
            
            //update Statistic
            if let updatedStatistic = VFantasyCommon.downgradeStatistic(playerLineupInfo.statistic, player: player) {
                //save for reuse
                playerLineupInfo.statistic = updatedStatistic
                //Notify to PositionContainerCell to update data
                NotificationCenter.default.post(name: NotificationName.updateStatistic, object: nil, userInfo: [NotificationKey.statistic : updatedStatistic])
            }
            
            completedLineup = false
            //update player status
            refreshPlayerList()
            //update Budget
            view?.updateBudget()
        }
    }
    
    // MARK: - Team List
    func refreshTeamList() {
        leagueTeamInfo.removeAllTeams()
        teamService.page = 1
        
        getTeamList()
    }
    
    func getTeamList() {
        view?.startLoading()
        
        teamService.getLeagueTeams(leagueID) { (response, success) in
            if success {
                self.handleTeamListResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
    
    func handleTeamListResponseSuccess(_ response: AnyObject) {
        if let result = response as? LeagueTeamsData {
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
                if let newData = res.data {
                    leagueTeamInfo.teams += newData
                }
            }
            
            view?.finishLoading()
            view?.reloadView(2)
        }
    }
    
    // MARK: - Complete Lineup
    func completeLineup() {
        view?.startLoading()
        CreateTeamInfoService().completeLineup(teamID) { (response, success) in
            self.view?.finishLoading()
            if success {
                self.handleCompleteLineupResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
    
    func handleCompleteLineupResponseSuccess(_ response: AnyObject) {
        if let result = response as? LeagueTeamsData {
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
            
            completedLineup = true
            currentPage = 2
            view?.finishLoading()
            NotificationCenter.default.post(name: NotificationName.completeSetupTeam, object: nil, userInfo: [NotificationKey.completeSetupTeam : true])
        }
    }
    
    // MARK: - Audo pick players
    func autoPickPlayers() {
        if playerLineupInfo.players.count == 18 {
            view?.alertMessage("Your team is full")
            return
        }
        view?.startLoading()
        teamService.autoPickPlayers(self.teamID) { (response, success) in
            if success {
                self.handleAutoPickPlayersResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
    
    func removeAutoPickPlayers() {
        view?.startLoading()
        teamService.removeAutoPickPlayers(self.teamID) { (response, success) in
            if success {
                self.handleAutoPickPlayersResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.view)
            }
        }
    }
    
    func handleAutoPickPlayersResponseSuccess(_ response: AnyObject) {
        view?.finishLoading()
        if let result = response as? AddPlayerData {
            guard let meta = result.meta else { return }
            if meta.success == false {
                guard let message = meta.message else { return }
                view?.alertMessage(message.localiz())
                return
            }
            self.getLineup()
        }
    }
}

extension GlobalCreateTeamInfoPresenter : CustomPageControlDelegate {
    func currentIndex(indexPath: IndexPath) {
        if indexPath.row == currentPage { return }
        
        switch indexPath.row {
        case 0:
            teamInfoType = .lineup
        case 1:
            teamInfoType = .playerList
        case 2:
            teamInfoType = .teamList
        default:
            teamInfoType = .lineup
        }
        
        currentPage = indexPath.row
        view?.didSelectPageControl(indexPath.row)
    }
}

