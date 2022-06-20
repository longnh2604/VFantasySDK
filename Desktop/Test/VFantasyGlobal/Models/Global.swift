//
//  Global.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

struct PlayerRequestModel {
    var leagueID = ""
    var position = ""
    var keyword = ""
    var order = ""
    var clubID = ""
    var season_id = ""
    var current_season_id = 0
    var teamId = 0
    var from_player_id: Int?
    var gameplayOption = GamePlay.Transfer
    var canPickDueToSelectedCorrectSeason = true
    var requesting = false
    var action = ""
    
    mutating func reset() {
        leagueID = ""
        position = ""
        keyword = ""
        order = ""
        clubID = ""
    }
}

class CreateTeamModel: NSObject {
    var name: String?
    var desc: String?
    var logo: UIImage?
    var teamId: Int?
    var avatar: String?
    
    func updates(_ name: String?, _ description: String?, _ teamId: Int?, _ avatar: String?) {
        self.name = name
        self.desc = description
        self.teamId = teamId
        self.avatar = avatar
    }
}

let MAX_PLAYERS = 18

struct TeamPlayerInfo {
    var statistic: Statistic?
    var totalPlayers = 0
    var players = [Player]()
    var budget: Double?
    var time: String?
    var seconds: Int?
    var secondsToStartTime: Int?
    var gameplay: GamePlay?
    var draftStatus: DraftStatus = .waitingForStart
    var seasonId: Int?
    var timePerPick: Int?
    var isRefreshing = false
    
    mutating func removeAllPlayers() {
        players.removeAll()
    }
    
    func fullLineup() -> Bool {
        return players.count >= MAX_PLAYERS
    }
}

struct LeagueTeamInfo {
    var currentTeams = 0
    var maxTeams = 0
    var teams = [Team]()
    
    mutating func removeAllTeams() {
        teams.removeAll()
    }
}

struct TransferRequestModel: Codable {
    let property, direction: String?
}

struct GlobalRankingRequestModel {
    var leagueId = 0
    var byMonth = ""
    var byGameweek = 0
}

struct TransferPlayerRequestModel {
    var teamId = 0
    var leagueId = 0
    var fromPlayerId = 0
    var toPlayerId = 0
    var withTeamId = 0
    var gameplayOption = GamePlay.Transfer
    var fromListPlayerId = ""
    var toListPlayerId = ""
}

struct GlobalPointsRequestModel {
    var realRoundId: Int?
    var formation: String = "4-4-2"
    var formationTeam: FormationTeam {
        return FormationTeam(rawValue: formation) ?? .team_442
    }
    
    mutating func reset() {
        realRoundId = nil
        formation = "4-4-2"
    }
}

class MatchResultsModel: NSObject {
    var leagueId = 0
    var canLoadMoreMyResults = true
    var canLoadMoreRealResults = true
    var round = ""
}

struct TransferPlayerListRequestModel: Codable {
    let property, direction: String?
    
    enum CodingKeys: String, CodingKey {
        case property
        case direction
    }
}

class TransferGlobalModel: NSObject {
    var timeDeadline = ""
    var maxTransferPlayer = 0
    var currentTransferPlayer = 0
}

class CheckBoxData: NSObject {
    var key: String?
    var value: String?
    var name: String?
    
    var selected: Bool = false
    
    init(_ key: String,_ value: String,_ name: String,_ selected: Bool = false) {
        self.key = key
        self.value = value
        self.selected = selected
        self.name = name
    }
    
    override init() {
    }
}

struct LineupOrderRequestModel: Codable {
    let property, rela, orderOperator, value: String?
    
    enum CodingKeys: String, CodingKey {
        case property, rela
        case orderOperator = "operator"
        case value
    }
}

struct LeaveGlobalLeagueModel: Codable {
    let meta: Meta?
    let response: LeaveGlobalLeagueResponse?
}

struct LeaveGlobalLeagueResponse: Codable {
    let id: Int?
}

class LeaguePointFilterData: NSObject {
    var name = ""
    var key = ""
    var isSelected = false
}

class LeaguePointModelView: NSObject {
    
    var id: Int? = nil
    var rank: Int? = nil
    var gameweek: GameWeek?
    @objc var totalPoint: String? = nil
    @objc var point: String? = nil
    @objc var name: String? = nil
}

struct PositionCountModel {
    var pos = PlayerPositionType.goalkeeper
    var count = 0
    
    mutating func updateCount(_ count: Int) {
        self.count = count
    }
}

class TeamLineupDraftModel: NSObject {
    var page = 0
    var teamId = 0
    var round = 0
    var leagueId = 0
    var canLoadMorePickHistory = true
    var socketTurnReceiveData: TurnReceiveData?
    var timeLeft = 0
}

class GlobalLeaguePointMappingData: NSObject {
    
    static func mappingLeaguePointDataToModelView(_ user: RankingData) -> LeaguePointModelView {
        let modelView = LeaguePointModelView()
        modelView.id = user.id
        modelView.name = user.name
        modelView.gameweek = user.gameweek
        modelView.rank = user.rank
        modelView.totalPoint = String(user.totalPoint ?? 0)
        modelView.point = String(user.gameweek?.point ?? 0)
        return modelView
    }
}

struct TransferViewModel {
    var players = [PlayerModelView]() //display data
    var rawPlayers = [Player]() //raw data
    var injuredPlayers = [Player]()
    var budget = ""
    var timeLeftDisplay = ""
    var timeLeft = 0
    var playerLeft = ""
    var gameplayOption = GamePlay.Transfer
    var redundantPlayers = 0
}

class PlayerModelView: NSObject {
    var id:Int? = nil
    @objc var name: String? = nil
    @objc var club: String? = nil
    var position: Int? = nil
    var minorPosition: Int? = nil
    @objc var value: String? = nil
    @objc var point: String? = nil
    @objc var goals: String? = nil
    @objc var assists: String? = nil
    @objc var clean_sheet: String? = nil
    @objc var duels_they_win: String? = nil
    @objc var passes: String? = nil
    @objc var shots: String? = nil
    @objc var saves: String? = nil
    @objc var yellow_cards: String? = nil
    @objc var dribbles: String? = nil
    @objc var turnovers: String? = nil
    @objc var balls_recovered: String? = nil
    @objc var fouls_committed: String? = nil
    var rank_status: Int?
    var selected: Bool?
}

class PlayerListMappingData: NSObject {
    static func mappingPlayerToPlayerModelView(_ player: Player) -> PlayerModelView {
        let modelView = PlayerModelView()
        modelView.id = player.id
        modelView.name = player.getNameDisplay()
        modelView.club = player.realClub?.name
        modelView.position = player.mainPosition
        modelView.minorPosition = player.minorPosition
        modelView.value = "\(player.transferValue ?? 0)"
        modelView.point = "\(player.point ?? 0)"
        modelView.goals = "\(player.goals ?? 0)"
        modelView.assists = "\(player.assists ?? 0)"
        modelView.clean_sheet = "\(player.cleanSheet ?? 0)"
        modelView.duels_they_win = "\(player.duelsTheyWin ?? 0)"
        modelView.passes = "\(player.passes ?? 0)"
        modelView.shots = "\(player.shots ?? 0)"
        modelView.saves = "\(player.saves ?? 0)"
        modelView.yellow_cards = "\(player.yellowCards ?? 0)"
        modelView.dribbles = "\(player.dribbles ?? 0)"
        modelView.turnovers = "\(player.turnovers ?? 0)"
        modelView.balls_recovered = "\(player.ballsRecovered ?? 0)"
        modelView.fouls_committed = "\(player.foulsCommitted ?? 0)"
        modelView.rank_status = player.rankStatus
        modelView.selected = player.isSelected
        return modelView
    }
}

class MessageValid: NSObject {
    var email: String?
    var password: String?
    var phone: String?
    var code: String?
    
    var firstName: String?
    var lastName: String?
    var rePassword: String?
    var verificationCode: String?
}
