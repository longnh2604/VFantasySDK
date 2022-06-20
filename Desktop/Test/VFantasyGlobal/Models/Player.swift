//
//  Player.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import SwiftDate

struct PlayerDetailResponse: Codable {
    let meta: Meta?
    let response: Player?
}

struct Player: Codable, Equatable {
    let id: Int?
    let createdAt, updatedAt: String?
    let startAt: String?
    let realClubID: Int?
    let realClub: RealClub?
    let name, nickname, photo: String?
    let isInjured, isGoalkeeper, isDefender, isMidfielder: Bool?
    let isAttacker: Bool?
    let mainPosition, minorPosition, transferValue, pointLastRound: Int?
    var isSelected: Bool?
    let goals, assists, cleanSheet, duelsTheyWin: Int?
    let passes, shots, saves, yellowCards: Int?
    let dribbles, turnovers, ballsRecovered, foulsCommitted: Int?
    let totalPoint: Int?
    let point: Int?
    let position: Int?
    var order: Int?
    let transferDeadline: String?
    let rankStatus: Int?
    let lastPickTurn: LastPickTurn?
    var isTrading: Bool?
    var gameweeks: [GameWeek]?
    var isAddNew: Bool = false
    var isEnoughMoneyForTransfer: Bool = false
    let gameweek_point: Int?
    let season_point: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case startAt = "start_at"
        case realClubID = "real_club_id"
        case realClub = "real_club"
        case name, nickname, photo
        case isInjured = "is_injured"
        case isGoalkeeper = "is_goalkeeper"
        case isDefender = "is_defender"
        case isMidfielder = "is_midfielder"
        case isAttacker = "is_attacker"
        case mainPosition = "main_position"
        case minorPosition = "minor_position"
        case transferValue = "transfer_value"
        case pointLastRound = "point_last_round"
        case isSelected = "is_selected"
        case goals, assists
        case cleanSheet = "clean_sheet"
        case duelsTheyWin = "duels_they_win"
        case passes, shots, saves
        case yellowCards = "yellow_cards"
        case dribbles, turnovers
        case ballsRecovered = "balls_recovered"
        case foulsCommitted = "fouls_committed"
        case point
        case order, position
        case totalPoint = "total_point"
        case transferDeadline = "transfer_deadline"
        case rankStatus = "rank_status"
        case isTrading = "is_trading"
        case lastPickTurn = "last_pick_turn"
        case gameweeks = "gameweek"
        case gameweek_point, season_point
    }
    
    //Match both minor position and main position
    func isMatch(_ type: PlayerPositionType) -> Bool {
        if let mainPos = self.mainPosition {
            if mainPos == type.rawValue {
                return true
            } else {
                if let minorPos = self.minorPosition {
                    if minorPos == type.rawValue {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func isPosition(_ type: PlayerPositionType) -> Bool {
        if let position = position {
            return position == type.rawValue
        }
        return false
    }
    
    static func ==(lhs: Player, rhs: Player) -> Bool { // Implement Equatable
        return lhs.id == rhs.id
    }
    
    func validTransferDeadline() -> Bool {
        if let deadline = transferDeadline?.toDate {
            return Date().lessThan(deadline)
        }
        return true
    }
    
    //0: goalkeeper; 1: defender; 2: midfielder; 3: attacker;
    func positionName() -> String {
        switch mainPosition {
            case 0: return "Goalkeeper"
            case 1: return "Defender"
            case 2: return "Midfielder"
            case 3: return "Attacker"
            default: return ""
        }
    }
    
    func positionShortName() -> String {
        switch mainPosition {
            case 0: return "G"
            case 1: return "D"
            case 2: return "M"
            case 3: return "A"
            default: return ""
        }
    }
    
    func getNameDisplay(_ type: PlayerDisplayName = .fullName) -> String? {
        if let nickName = self.nickname, !nickName.isEmpty {
            return nickName
        }
        if type == .shortName {
            return self.name?.getSumaryName()
        }
        if type == .fullName {
            return self.name
        }
        return self.getNameDisplay(.fullName)
    }
        
    func positionColor(position: Int? = nil) -> UIColor? {
        let switchPosition = position == nil ? mainPosition : position
        switch switchPosition {
            case 0: return UIColor(red: 73.0/255.0, green: 157.0/255.0, blue: 228.0/255.0, alpha: 1.0)
            case 1: return UIColor(red: 90.0/255.0, green: 165.0/255.0, blue: 28.0/255.0, alpha: 1.0)
            case 2: return UIColor(red: 253.0/255.0, green: 187.0/255.0, blue: 88.0/255.0, alpha: 1.0)
            case 3: return UIColor(red: 252.0/255.0, green: 28.0/255.0, blue: 37.0/255.0, alpha: 1.0)
            default: return UIColor(red: 252.0/255.0, green: 28.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        }
    }
    
    func realClubName() -> String {
        if let shortName = realClub?.shortName, !shortName.isEmpty {
            return shortName
        }
        return realClub?.name ?? ""
    }
  
    func realClubNext() -> String {
      if let short = realClub?.h2hShortName, !short.isEmpty {
          return short
      }
        return realClub?.h2hName ?? ""
    }
    
    mutating func setIsEnoughMoney(_ isEnough: Bool) {
        self.isEnoughMoneyForTransfer = isEnough
    }
}

struct LastPickTurn: Codable, Equatable  {
    let id, playerId, teamId, round: Int?
    let pickAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case playerId = "player_id"
        case teamId = "team_id"
        case round = "round"
        case pickAt = "pick_at"
    }
}

struct BudgetOption: Codable {
    let id: Int?
    let name: String?
    let value: Int?
}
