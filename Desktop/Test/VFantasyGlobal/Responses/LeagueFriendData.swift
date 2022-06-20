//
//  LeagueFriendData.swift
//  VFantasyGlobal
//
//  Created by User on 26/05/2022.
//

import Foundation

struct LeagueFriendModel {
    var keyword = ""
    var leagueID = ""
}

struct LeagueFriendData: Codable {
    let meta: Meta?
    let response: LeagueFriendResponse?
}

struct LeagueFriendResponse: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL: String?
    let prevPageURL: String?
    let from, to: Int?
    let data: [LeagueFriendDatum]?
    
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

struct LeagueFriendDatum: Codable {
    let id: Int?
    let name, email, firstName, lastName: String?
    let photo: String?
    var isInvited: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email
        case firstName = "first_name"
        case lastName = "last_name"
        case photo
        case isInvited = "is_invited"
    }
}
