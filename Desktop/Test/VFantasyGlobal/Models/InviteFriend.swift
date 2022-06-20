//
//  InviteFriend.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation

struct InviteFriendModel {
    var leagueID = 0
    var userID = ""
    var friendID = 0
}

struct InviteFriendData: Codable {
    let meta: Meta?
    let response: InviteFriendResponse?
}

struct InviteFriendResponse: Codable {
    let leagueID, senderID, receiverID: Int?
    let updatedAt, createdAt: String?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case leagueID = "league_id"
        case senderID = "sender_id"
        case receiverID = "receiver_id"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case id
    }
}
