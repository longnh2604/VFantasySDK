//
//  PlayerListData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct PlayerListData: Codable {
    let meta: Meta?
    let response: PlayerListResponse?
}

struct PlayerListResponse: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let data: [Player]?
    let statistic: Statistic?
    let team: Team?
    let league: League?
    
    enum CodingKeys: String, CodingKey {
        case total
        case perPage = "per_page"
        case currentPage = "current_page"
        case lastPage = "last_page"
        case nextPageURL = "next_page_url"
        case prevPageURL = "prev_page_url"
        case from, to, data, statistic, team, league
    }
}
