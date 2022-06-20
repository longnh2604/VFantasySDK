//
//  TransferPlayerListData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct TransferPlayerListData: Codable {
    let meta: Meta?
    let response: TransferPlayerListResponse?
}

struct TransferPlayerListResponse: Codable {
    let totalPlayers: Int?
    let players: [Player]?
    let totalInjuredPlayers: Int?
    let injuredPlayers: [Player]?
    let team: Team?
    let currentTransferPlayer, maxTransferPlayer: Int?
    let transferPlayerLeftDisplay, transferDeadline: String?
    let transferTimeLeft: Int?
    let nextGameWeek: GameWeek?
    
    enum CodingKeys: String, CodingKey {
        case totalPlayers = "total_players"
        case players
        case totalInjuredPlayers = "total_injured_players"
        case injuredPlayers = "injured_players"
        case team
        case currentTransferPlayer = "current_transfer_player"
        case maxTransferPlayer = "max_transfer_player"
        case transferPlayerLeftDisplay = "transfer_player_left_display"
        case transferDeadline = "transfer_deadline"
        case transferTimeLeft = "transfer_time_left"
        case nextGameWeek = "next_gameweek"
    }
}

struct TransferResponse: Codable {
    let meta: Meta?
    let response: TransferData?
}

struct TransferData: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let active: Int?
    let name, nickname, photo: String?
    let isInjured, isGoalkeeper, isDefender, isMidfielder: Bool?
    let isAttacker: Bool?
    let mainPosition, minorPosition, transferValue: Int?
    let deletedAt: Int?
    let realClubId: Int?
    let referenceId: String?
    let isBot: Bool?
    let totalTransfers: Int?
    let realClub: RealClub?
    let point: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case active = "active"
        case name, nickname, photo
        case isInjured = "is_injured"
        case isGoalkeeper = "is_goalkeeper"
        case isDefender = "is_defender"
        case isMidfielder = "is_midfielder"
        case isAttacker = "is_attacker"
        case mainPosition = "main_position"
        case minorPosition = "minor_position"
        case transferValue = "transfer_value"
        case deletedAt = "deleted_at"
        case realClubId = "real_club_id"
        case referenceId = "reference_id"
        case isBot = "is_bot"
        case totalTransfers = "total_transfers"
        case realClub = "real_club"
        case point = "point"
    }
}
