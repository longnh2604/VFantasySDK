//
//  GlobalMatchesData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct MatchResultsResponse: Codable {
    let meta: Meta?
    let response: MatchResults?
}

struct MatchResults: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let round: Int?
    let data: [MatchResultsData]?
    let totalRound: Int?
    
    enum CodingKeys: String, CodingKey {
        case total
        case perPage = "per_page"
        case currentPage = "current_page"
        case lastPage = "last_page"
        case nextPageURL = "next_page_url"
        case prevPageURL = "prev_page_url"
        case from, to, data
        case round
        case totalRound = "total_round"
    }
}

struct MatchResultsData: Codable {
    let id, round: Int?
    let startAt, endAt: String?
    let league: League?
    let team, withTeam: Team?
    var showingInfo = false
    
    enum CodingKeys: String, CodingKey {
        case id, round
        case startAt = "start_at"
        case endAt = "end_at"
        case league, team
        case withTeam = "with_team"
    }
}

struct LatestRoundData: Codable {
    let meta: Meta?
    let response: LatestRound?
}

struct LatestRound: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let seasonID: Int?
    let season: Season?
    let round: Int?
    let startAt, endAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case seasonID = "season_id"
        case season
        case round
        case startAt = "start_at"
        case endAt = "end_at"
    }
}
