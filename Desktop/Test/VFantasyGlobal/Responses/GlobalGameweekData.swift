//
//  GlobalGameweekData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct GameWeekModel: Codable {
    let meta: Meta?
    let response: [GameWeek]?
}

struct GlobalGameWeekModel: Codable {
    let meta: Meta?
    let response: GlobalGameWeekData?
}

struct GlobalGameWeekData: Codable {
    let data: [GameWeek]?
    let from, lastPage, perPage, to, total, currentPage: Int?
    enum CodingKeys: String, CodingKey {
        case data
        case currentPage = "current_page"
        case from, to, total
        case lastPage = "last_page"
        case perPage = "per_page"
    }
}
