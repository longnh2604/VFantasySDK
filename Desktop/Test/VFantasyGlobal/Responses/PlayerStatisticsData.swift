//
//  PlayerStatisticsData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

struct PlayerStatisticsResponse: Codable {
    let meta: Meta?
    let response: PlayerStatisticsData?
}

struct PlayerStatisticsData: Codable {
    let id: Int?
    let name, photo: String?
    let mainPosition, minorPosition: Int?
    let isInjured: Bool?
    let transferValue, totalPoint, totalRound: Int?
    let metas: [PlayerStatisticsMeta]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, photo
        case mainPosition = "main_position"
        case minorPosition = "minor_position"
        case isInjured = "is_injured"
        case transferValue = "transfer_value"
        case totalPoint = "total_point"
        case totalRound = "total_round"
        case metas
    }
}

struct PlayerStatisticsMeta: Codable {
    let id, round, point, change: Int?
}

struct PlayerStatisticsObjectResponse: Codable {
    let meta: Meta?
    let response: PlayerStatisticsObjectData?
}

struct PlayerStatisticsObjectData: Codable {
    let id: Int?
    let name, photo: String?
    let mainPosition, minorPosition: Int?
    let isInjured: Bool?
    let transferValue, totalPoint, totalRound: Int?
    let meta: PlayerStatisticsObjectMeta?
    
    enum CodingKeys: String, CodingKey {
        case id, name, photo
        case mainPosition = "main_position"
        case minorPosition = "minor_position"
        case isInjured = "is_injured"
        case transferValue = "transfer_value"
        case totalPoint = "total_point"
        case totalRound = "total_round"
        case meta
    }
}

struct PlayerStatisticsObjectMeta: Codable {
    let goals: Double?
    let assists, cleanSheet, duelsTheyWin, passes: Double?
    let shots, saves, yellowCards, dribbles: Double?
    let turnovers, ballsRecovered, foulsCommitted: Double?
    
    enum CodingKeys: String, CodingKey {
        case goals, assists
        case cleanSheet = "clean_sheet"
        case duelsTheyWin = "duels_they_win"
        case passes, shots, saves
        case yellowCards = "yellow_cards"
        case dribbles, turnovers
        case ballsRecovered = "balls_recovered"
        case foulsCommitted = "fouls_committed"
    }
}
