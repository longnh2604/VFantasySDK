//
//  Team.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

struct Team: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let userID: Int?
    let user: User?
    let name, description, logo: String?
    let rank, totalPoint: Int?
    let currentBudget: Double?
    let currentValue: Double?
    let formation: String?
    let pickOrder, round: Int?
    let isCompleted: Bool?
    let isOwner: Bool?
    let point, teamRoundID, totalPlayers: Int?
    let statistic: PlayerStatisticsObjectMeta?
    let currentRound: CurrentRound?
    let lastRound: CurrentRound?
    let transferRound: CurrentRound?
    let current, next: Bool?
    var dueNextTime: Int?
    let dueNextTimeMax: Int?
    let playerLeft: Int?
    let isBot: Bool?
    let totalValue: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case user, name, description, logo
        case currentBudget = "current_budget"
        case currentValue = "current_value"
        case rank
        case totalPoint = "total_point"
        case formation, round
        case pickOrder = "pick_order"
        case isCompleted = "is_completed"
        case point
        case teamRoundID = "team_round_id"
        case statistic
        case totalPlayers = "total_transfer_round_players"
        case isOwner = "is_owner"
        case currentRound = "current_round"
        case lastRound = "last_round"
        case transferRound = "transfer_round"
        case current, next
        case dueNextTime = "due_next_time"
        case dueNextTimeMax = "due_next_time_max"
        case playerLeft = "player"
        case isBot = "is_bot"
        case totalValue = "total_value"
    }
    
    mutating func reCalculateDueNextTime(with input: Int) {
        if dueNextTime == nil { return }
        if dueNextTime! > input {
            dueNextTime! -= input
        } else {
            dueNextTime = 0
        }
    }
}

struct GlobalRanking: Codable {
    let city, club, country, global: ItemRanking?
    enum CodingKeys: String, CodingKey {
        case city, club, country, global
    }
}

struct ItemRanking: Codable {
    let id: Int?
    let name: String?
    let rank: Int?
    let rankStatus: Int?
    let shortName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, rank
        case shortName = "short_name"
        case rankStatus = "rank_status"
    }
}
