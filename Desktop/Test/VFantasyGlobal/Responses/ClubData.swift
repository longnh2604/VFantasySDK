//
//  ClubData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct ClubObjectResponse: Codable {
    let meta: Meta?
    let response: ClubResponse?
}

struct ClubResponse: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let data: [ClubModelData]?
    
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

struct ClubModelData: Codable {
    let id: Int?
    let createdAt, updatedAt, name, shortName: String?
    let logo: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name
        case shortName = "short_name"
        case logo
    }
}
