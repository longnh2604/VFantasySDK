//
//  RealMatch.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import SwiftDate

struct RealMatchData: Codable {
    let meta: Meta?
    let response: RealMatchResponse?
}

struct RealMatchResponse: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let round: Int?
    let maxRound: Int?
    let data: [RealMatch]?
    
    enum CodingKeys: String, CodingKey {
        case total
        case perPage = "per_page"
        case currentPage = "current_page"
        case lastPage = "last_page"
        case nextPageURL = "next_page_url"
        case prevPageURL = "prev_page_url"
        case from, to, data
        case round = "round"
        case maxRound = "max_round"
    }
}

struct RealMatch: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let seasonID: Int?
    let season: Season?
    let team1, team2: String?
    let team1_Result, team2_Result, round: Int?
    let startAt, endAt: String?
    let delayStartAt, delayEndAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case seasonID = "season_id"
        case season
        case team1 = "team_1"
        case team2 = "team_2"
        case team1_Result = "team_1_result"
        case team2_Result = "team_2_result"
        case round
        case startAt = "start_at"
        case endAt = "end_at"
        case delayStartAt = "delay_start_at"
        case delayEndAt = "delay_end_at"
    }
    
    func getStartTime() -> String {
        if let delay = delayStartAt {
            return delay.validDisplayDate()
        }
        return startAt!.validDisplayDate()
    }
}

struct Season: Codable {
    let id: Int?
    let name: String?
    let end_at: String?
}
