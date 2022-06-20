//
//  League.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct League: Codable {
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
    let tradeReview, tradeReviewDisplay, draftTime: String?
    let timeToPick: Int?
    let status: Int?
    let statusDisplay: String?
    let draftRunning: Int?
    let draftRunningDisplay: String?
    
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
        case tradeReview = "trade_review"
        case tradeReviewDisplay = "trade_review_display"
        case draftTime = "draft_time"
        case timeToPick = "time_to_pick"
        case status
        case statusDisplay = "status_display"
        case draftRunning = "draft_running"
        case draftRunningDisplay = "draft_running_display"
    }
}
