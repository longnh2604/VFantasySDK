//
//  Gameweek.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct GameWeek: Codable {
    let id, round, team1Result, team2Result: Int?
    let team1, team2: String?
    let startAt, endAt, delayStartAt, delayEndAt: String?
    let title: String?
    let point, avgPoint, maxPoint: Int?
    let h2hName, h2hShortName: String?
    let maxTeamId: Int?
    let transfer_deadline: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case round = "round"
        case team1Result = "team_1_result"
        case team2Result = "team_2_result"
        case team1 = "team_1"
        case team2 = "team_2"
        case startAt = "start_at"
        case endAt = "end_at"
        case delayStartAt = "delay_start_at"
        case delayEndAt = "delay_end_at"
        case title
        case point
        case avgPoint = "avg_point"
        case maxPoint = "max_point"
        case h2hName = "h2h_name"
        case h2hShortName = "h2h_short_name"
        case maxTeamId = "max_team_id"
        case transfer_deadline
    }
}

class GameWeekInfo {
    var id: Int!
    var round: Int!
    var startAt: String!
    var endAt: String!
    var title: String!
}
