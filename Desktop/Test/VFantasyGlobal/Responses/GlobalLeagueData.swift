//
//  GlobalLeagueData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct GlobalTransferDeadline: Codable {
    let meta: Meta?
}

struct GlobalLeagueModel: Codable {
    let meta: Meta?
    let response: GlobalLeagueData?
}

struct GlobalLeagueData: Codable {
    let id, startGameweekId: Int?
    let name, description, logo, code: String?
    let deletedPlayers: [Player]?
    let team: Team?

    enum CodingKeys: String, CodingKey {
        case id
        case name = "name"
        case description = "description"
        case logo = "logo"
        case code = "code"
        case startGameweekId = "start_gameweek_id"
        case deletedPlayers = "deleted_players"
        case team
    }
}
