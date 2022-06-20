//
//  GlobalMyTeam.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct GlobalMyTeam: Codable {
    let meta: Meta?
    let response: MyTeamData?
}

struct MyTeamData: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let currentBudget: Int?
    let description: String?
    let formation: String?
    var league: League?

    let isCompleted: Bool?
    let isOwner: Bool?
    let logo: String?
    let name: String?
    let pickOrder: Int?
    let rank: Int?
    let totalPlayers: Int?
    var user: User?
    var point: Int?
    let totalPoint: Int?
    var globalRanking: GlobalRanking?
    var currentGW: GameWeek?
    var super7_value: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case currentBudget = "current_budget"
        case description
        case formation
        case point
        case league = "league"
        case isCompleted = "is_completed"
        case isOwner = "is_owner"
        case logo, name
        case pickOrder = "pick_order"
        case rank
        case totalPlayers = "total_players"
        case totalPoint = "total_point"
        case user
        case globalRanking = "global_ranking"
        case currentGW = "gameweek"
        case super7_value
    }
    
    static func convertTeamToMyTeam(data: Team) -> MyTeamData {
        return MyTeamData(id: data.id, createdAt: data.createdAt, updatedAt: data.updatedAt, currentBudget: nil, description: nil, formation: nil, league: nil, isCompleted: nil, isOwner: nil, logo: data.logo, name: data.name, pickOrder: nil, rank: nil, totalPlayers: nil, user: nil, totalPoint: nil, globalRanking: nil, currentGW: nil)
    }
    
    static func createMyTeam(with id: Int) -> MyTeamData {
        return MyTeamData(id: id, createdAt: nil, updatedAt: nil, currentBudget: nil, description: nil, formation: nil, league: nil, isCompleted: nil, isOwner: nil, logo: nil, name: nil, pickOrder: nil, rank: nil, totalPlayers: nil, user: nil, totalPoint: nil, globalRanking: nil, currentGW: nil)
    }
}

struct GlobalMyTeams: Codable {
    let meta: Meta?
    let response: MyTeamsResult?
}

struct MyTeamsResult: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let data: [MyTeamData]?
    
    enum CodingKeys: String, CodingKey {
        case total
        case perPage = "per_page"
        case currentPage = "current_page"
        case lastPage = "last_page"
        case nextPageURL = "next_page_url"
        case prevPageURL = "prev_page_url"
        case from, to, data
    }
}

struct GlobalTeamModel: Codable {
    let meta: Meta?
    let response: TeamCreated?
}

struct TeamCreated: Codable {
    let id: Int!
    let createAt: String?
}

struct GlobalTeamOTWeek: Codable {
    let meta: Meta?
    let response: TeamOTWeekData?
}

struct TeamOTWeekData: Codable {
    let gameweek: GameWeek?
    let players: [Player]?

    enum CodingKeys: String, CodingKey {
        case gameweek
        case players
    }
}
