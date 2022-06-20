//
//  RealClub.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct RealClub: Codable {
    let id: Int?
    let name: String?
    let shortName: String?
    let h2hName: String?
    let h2hShortName: String?
    let jerseys: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case shortName = "short_name"
        case h2hName = "h2h_name"
        case h2hShortName = "h2h_short_name"
        case jerseys
    }
}
