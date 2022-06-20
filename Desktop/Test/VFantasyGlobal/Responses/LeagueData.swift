//
//  LeagueData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct LeagueData: Codable {
    let meta: Meta?
    let response: LeagueResponse?
}

struct RedeemData: Codable {
    let meta: Meta?
    let response: LeagueDatum?
}

struct LeagueGlobalDetailModel: Codable {
    let meta: Meta?
    let response: LeagueDatum?
}

struct LeagueResponse: Codable {
    let total, perPage, currentPage, lastPage: Int?
    let nextPageURL, prevPageURL: String?
    let from, to: Int?
    let data: [LeagueDatum]?
    
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

struct LeagueDatum: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let userID: Int?
    let user: User?
    let gameplayOption, gameplayOptionDisplay: String?
    let seasonID: Int?
    let name, description, logo, leagueType: String?
    let leagueTypeDisplay: String?
    let numberOfUser, currentNumberOfUser: Int?
    let scoringSystem, scoringSystemDisplay, startAt: String?
    let realRoundStart, realRoundEnd, budgetID, budgetValue: Int?
    let budgetOption: BudgetOption?
    let teamSetup: String?
    let team: Team?
    let tradeReview, tradeReviewDisplay, draftTime: String?
    let timeToPick: Int?
    let status: Int?
    let statusDisplay: String?
    let invitation: Invitation?
    let rank, rankStatus: Int?
    let rankDisplay: String?
    let h2h: H2H?
    let startGameweek: GameWeek?
    let startGameweekId: Int?
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case user
        case gameplayOption = "gameplay_option"
        case gameplayOptionDisplay = "gameplay_option_display"
        case seasonID = "season_id"
        case name, description, logo
        case leagueType = "league_type"
        case leagueTypeDisplay = "league_type_display"
        case numberOfUser = "number_of_user"
        case currentNumberOfUser = "current_number_of_user"
        case scoringSystem = "scoring_system"
        case scoringSystemDisplay = "scoring_system_display"
        case startAt = "start_at"
        case realRoundStart = "real_round_start"
        case realRoundEnd = "real_round_end"
        case budgetID = "budget_id"
        case budgetValue = "budget_value"
        case budgetOption = "budget_option"
        case teamSetup = "team_setup"
        case team
        case tradeReview = "trade_review"
        case tradeReviewDisplay = "trade_review_display"
        case draftTime = "draft_time"
        case timeToPick = "time_to_pick"
        case status
        case statusDisplay = "status_display"
        case invitation, rank
        case rankStatus = "rank_status"
        case h2h
        case startGameweekId = "start_gameweek_id"
        case code = "code"
        case rankDisplay = "rank_display"
        case startGameweek = "start_gameweek"
    }
}

struct Invitation: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let senderID: Int?
    let sender: User?
    let receiverID: Int?
    let receiver: User?
    let leagueID: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case senderID = "sender_id"
        case sender
        case receiverID = "receiver_id"
        case receiver
        case leagueID = "league_id"
    }
}

struct H2H: Codable {
    let team: Team?
    let withTeam: Team?
    enum CodingKeys: String, CodingKey {
        case team = "team"
        case withTeam = "with_team"
    }
}
