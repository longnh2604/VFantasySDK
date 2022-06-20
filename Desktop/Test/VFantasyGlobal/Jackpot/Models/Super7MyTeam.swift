//
//  Super7MyTeam.swift
//  PAN689
//
//  Created by Quang Tran on 12/27/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

struct Super7ClaimModel {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phone: String = ""
}

class CreateSuper7Model: NSObject {
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

struct Super7TeamModel: Codable {
    let meta: Meta?
    let response: MyTeamData?
}

struct Super7LeagueModel: Codable {
    let meta: Meta?
    let response: League?
}

struct Super7PitchTeamModel: Codable {
    let meta: Meta?
    let response: Super7PitchTeamData?
}

struct Super7PitchTeamData: Codable {
    let id: Int?
    let currentGW: GameWeek?
    let currentRound: CurrentRound?
    let currentTransferPlayer: Int?
    let defaultRound: Int?
    let isLockFormation: Bool?
    let isLockRound: Bool?
    let lastRound: CurrentRound?
    let nextRound: CurrentRound?
    let maxTransferPlayer: Int?
    let selectedRound: Int?
    let team: Team?
    let totalRounds: Int?
    let transferDeadline: String?
    let transferPlayerLeft: Int?
    let transferPlayerLeftDisplay: String?
    let transferRound: CurrentRound?
    let transferTimeLeft: Double?
    var players: [Player] = []
    var morePlayers: [Player] = []
    var matches: [Super7Match] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case currentGW = "gameweek"
        case currentRound = "current_round"
        case currentTransferPlayer = "current_transfer_player"
        case defaultRound = "default_round"
        case isLockFormation = "is_lock_formation"
        case isLockRound = "is_lock_round"
        case lastRound = "last_round"
        case nextRound = "next_round"
        case maxTransferPlayer = "max_transfer_player"
        case selectedRound = "selected_round"
        case team
        case totalRounds = "total_rounds"
        case transferDeadline = "transfer_deadline"
        case transferPlayerLeft = "transfer_player_left"
        case transferPlayerLeftDisplay = "transfer_player_left_display"
        case transferRound = "transfer_round"
        case transferTimeLeft = "transfer_time_left"
        case players
        case morePlayers = "more_players"
        case matches
    }
    
    var deadline: Date {
        guard let date = self.currentGW?.transfer_deadline?.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss) else { return Date() }
        return date
    }
    
    var isEndDeadline: Bool {
        guard let date = self.currentGW?.transfer_deadline?.toDate(fromFormat: DateFormat.kyyyyMMdd_hhmmss) else { return true }
        return Date() > date 
    }
    
    var canClaimThePrize: Bool {
        return matches.count == self.matches.filter({ return $0.isStar }).count
    }
}

struct Super7Match: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let real_round: CurrentRound?
    let seasonID: Int?
    let season: Season?
    let team1, team2: String?
    let team1_Result, team2_Result, round: Int?
    let team_1_id, team_2_id: Int?
    let startAt, endAt: String?
    let delayStartAt, delayEndAt: String?
    let selected_player: Player?
    let star_of_match: Player?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case real_round
        case seasonID = "season_id"
        case season
        case team1 = "team_1"
        case team2 = "team_2"
        case team1_Result = "team_1_result"
        case team2_Result = "team_2_result"
        case round
        case startAt = "start_at"
        case endAt = "end_at"
        case delayStartAt = "delay_start_at"
        case delayEndAt = "delay_end_at"
        case team_1_id, team_2_id
        case selected_player
        case star_of_match
    }
    
    var isEnded: Bool {
        var date: Date?
        if let delay = self.delayStartAt {
            date = delay.toDate
        } else {
            date = startAt?.toDate
        }
        guard let date = date else { return true }
        return Date() > date
    }
    
    var isStar: Bool {
        guard let selected_id = selected_player?.id, selected_id > 0 else { return false }
        guard let star_id = star_of_match?.id, star_id > 0 else { return false }
        return selected_id == star_id
    }
}

struct AutoPickPlayersData: Codable {
    let meta: Meta?
    let response: AutoPickPlayersResponse?
}

struct AutoPickPlayersResponse: Codable {
    let team: Team?
    
    enum CodingKeys: String, CodingKey {
        case team
    }
}

struct Super7DreamTeamsModel: Codable {
    let meta: Meta?
    let response: Super7DreamTeam?
}

struct Super7DreamTeam: Codable {
    var matches: [Super7Match] = []
    var winners: [MyTeamData] = []
    var gameweek: GameWeek?
    
    enum CodingKeys: String, CodingKey {
        case matches = "matches"
        case gameweek = "gameweek"
        case winners = "winners"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.matches = try container.decode([Super7Match].self, forKey: .matches)
        self.winners = try container.decode([MyTeamData].self, forKey: .winners)
        self.gameweek = try container.decode(GameWeek.self, forKey: .gameweek)
    }
    
    var players: [Player] {
        var result: [Player] = []
        for match in matches {
            guard let player = match.selected_player else { continue }
            result.append(player)
        }
        return result
    }
}

struct Super7ClaimPrizeData: Codable {
    let meta: Meta?
    let response: Team?
}
