//
//  SquadData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct SquadData: Codable {
    let meta: Meta?
    let response: SquadResponse?
}

struct SquadResponse: Codable {
    let id: Int?
    let name: String?
    let totalPoint, currentBudget: Int?
    let league: League?
    let team: Team?
    let myTeam: Team?
    let players: [Player]?
    let selectedRound: Int?
    let totalRounds: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case totalPoint = "total_point"
        case currentBudget = "current_budget"
        case league, players
        case team
        case myTeam = "my_team"
        case selectedRound = "selected_round"
        case totalRounds = "total_rounds"
    }
}
