//
//  GlobalRankingData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct GlobalRankingModel: Codable {
    let meta: Meta?
    let response: GlobalRankingResponse?
}

struct GlobalRankingResponse: Codable {
    let total, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let data: [RankingData]?
    let team: MyTeamData?
    
    enum CodingKeys: String, CodingKey {
        case total
        case currentPage = "current_page"
        case lastPage = "last_page"
        case nextPageURL = "next_page_url"
        case prevPageURL = "prev_page_url"
        case from, to, data
        case team
    }
}

struct RankingData: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let userID: Int?
    let user: User?
    let name: String?
    let description: String?
    let logo: String?
    let currentBudget: Int?
    let rank: Int?
    var point: Int?
    let totalPoint: Int?
    let formation: String?
    let pickOrder: Int?
    let totalPlayers: Int?
    let isCompleted: Bool?
    let isOwner: Bool?
    let result: ResultRanking?
    let gameweek: GameWeek?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case user
        case name = "name"
        case description = "description"
        case logo = "logo"
        case currentBudget = "current_budget"
        case rank = "rank"
        case point
        case totalPoint = "total_point"
        case formation = "formation"
        case pickOrder = "pick_order"
        case totalPlayers = "total_players"
        case isCompleted = "is_completed"
        case isOwner = "is_owner"
        case result
        case gameweek
    }
}

struct ResultRanking: Codable {
    let ranking, played, win, draw, lose, points: Int?
    
    enum CodingKeys: String, CodingKey {
        case ranking = "ranking"
        case played = "played"
        case win = "win"
        case draw = "draw"
        case lose = "lose"
        case points = "points"
    }
}
