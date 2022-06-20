//
//  SessionData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct SeasonResponse: Codable {
    let meta: Meta?
    let response: SeasonResult?
}

struct SeasonResult: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let data: [SeasonData]?
    let currentSeason: SeasonData?
    
    enum CodingKeys: String, CodingKey {
        case total
        case perPage = "per_page"
        case currentPage = "current_page"
        case lastPage = "last_page"
        case nextPageURL = "next_page_url"
        case prevPageURL = "prev_page_url"
        case from, to, data
        case currentSeason = "current_season"
    }
}

struct SeasonData: Codable {
    let id: Int?
    let createdAt, updatedAt, name, startAt: String?
    let endAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name
        case startAt = "start_at"
        case endAt = "end_at"
    }
    
    func getIdValue() -> String {
        if let id = id {
            return String(id)
        }
        return ""
    }
}
