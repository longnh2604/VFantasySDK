//
//  PitchTeamData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

struct PitchTeamModel: Codable {
    let meta: Meta?
    let response: PitchTeamData?
}

struct PitchTeamData: Codable {
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
    }
}

struct CurrentRound: Codable {
    let id, round: Int?
    let startAt, endAt: String?
    let point: Int?
    let formation, transferDeadline: String?
    
    enum CodingKeys: String, CodingKey {
        case id, round
        case startAt = "start_at"
        case endAt = "end_at"
        case point, formation
        case transferDeadline = "transfer_deadline"
    }
}
