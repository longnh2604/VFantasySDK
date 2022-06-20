//
//  PlayersStatsData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct PlayersStatsData: Codable {
    let meta: Meta?
    let response: PlayersStatsResponse?
}

struct PlayersStatsResponse: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let data: [Player]?
    
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
