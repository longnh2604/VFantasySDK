//
//  TeamHistoryData.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation

struct PickHistoryData: Codable {
    let meta: Meta?
    let response: PickHistoryResponse?
}

struct PickHistoryResponse: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let data: [PickHistory]?
    
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

struct PickHistory: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let teamID: Int?
    let team: Team?
    let playerID: Int?
    let player: Player?
    let round: Int?
    let pickAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case teamID = "team_id"
        case team
        case playerID = "player_id"
        case player, round
        case pickAt = "pick_at"
    }
}

struct EndCountDownData: Codable {
    let meta: Meta?
    let response: EndCountDownResponse?
}

struct EndCountDownResponse: Codable {
    let id, numberOfUser, currentNumberOfUser, draftTotalJoined: Int?
    let currentTime: String?
    var draftTimeLeft: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case numberOfUser = "number_of_user"
        case currentNumberOfUser = "current_number_of_user"
        case draftTotalJoined = "draft_total_joined"
        case currentTime = "current_time"
        case draftTimeLeft = "draft_time_left"
    }
}

struct EndTurnData: Codable {
    let meta: Meta?
    let response: EndTurnResponse?
}

struct EndTurnResponse: Codable {
    let team: Team?
    
    enum CodingKeys: String, CodingKey {
        case team
    }
}
