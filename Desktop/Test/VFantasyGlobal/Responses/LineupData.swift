//
//  LineupData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct LineupData: Codable {
    let meta: Meta?
    let response: LineupResponse?
}

struct LineupResponse: Codable {
    let team: Team?
    let league: League?
    let players: [Player]?
    let statistic: Statistic?
    let pickTurn: SocketChangeTurnData?
    let nextGameWeek: GameWeek?
    enum CodingKeys: String, CodingKey {
        case team, league, players, statistic
        case pickTurn = "your_turn"
        case nextGameWeek = "next_gameweek"
    }
}

struct Statistic: Codable {
    let goalkeeper, defender, midfielder, attacker: Int?
}

struct SocketChangeTurnResponse: Codable {
    let previous, current, next: SocketChangeTurnData?
}

struct SocketChangeTurnData: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let leagueID, teamID: Int?
    let team: Team?
    let round, order: Int?
    let startAt, endAt, pickAt: String?
    let isAuto: Bool?
    let draftTimeLeft: Int?
    let yourTurnIn: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case leagueID = "league_id"
        case teamID = "team_id"
        case team, round, order
        case startAt = "start_at"
        case endAt = "end_at"
        case pickAt = "pick_at"
        case isAuto = "is_auto"
        case draftTimeLeft = "draft_time_left"
        case yourTurnIn = "your_turn_in"
    }
    
    func sameId(with id: Int) -> Bool {
        if let teamId = team?.id {
            return teamId == id
        }
        return false
    }
}
