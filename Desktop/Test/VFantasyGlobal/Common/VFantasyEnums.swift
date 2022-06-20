//
//  VFantasyEnums.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

enum PlayerPositionType: Int {
    //No postion will be nil or -1
    case all = -1
    case goalkeeper = 0, defender, midfielder, attacker
    
    static func fromHashValue(hashValue: Int) -> PlayerPositionType {
        switch hashValue {
        case PlayerPositionType.goalkeeper.rawValue:
            return .goalkeeper
        case PlayerPositionType.defender.rawValue:
            return .defender
        case PlayerPositionType.midfielder.rawValue:
            return .midfielder
        case PlayerPositionType.attacker.rawValue:
            return .attacker
        default:
            return .all
        }
    }
    
    var title: String {
        switch self {
        case .goalkeeper:
            return "Goalkeepers".localiz()
        case .defender:
            return "Defenders".localiz()
        case .midfielder:
            return "Midfielders".localiz()
        case .attacker:
            return "Attackers".localiz()
        default:
            return "all".localiz()
        }
    }
    
    var positionSearch: String {
        if self == .all {
            return ""
        }
        return "\(self.rawValue)"
    }
}

enum PlayerDisplayName {
    case fullName, shortName
}

enum SortType: String {
    case desc = "desc"
    case asc = "asc"
    case none = ""
    
    static func fromHashValue(hashValue: String) -> SortType {
        if hashValue == SortType.desc.rawValue {
            return .desc
        } else if hashValue == SortType.asc.rawValue {
            return .asc
        }
        return none
    }
}

enum CreateTeamInfoType {
    case lineup, playerList, teamList
}

enum GamePlay: String {
    case Transfer = "transfer"
    case Draft = "draft"
    
    static func fromHashValue(hashValue: String) -> GamePlay {
        if hashValue == GamePlay.Transfer.rawValue {
            return .Transfer
        }
        return .Draft
    }
}

enum LineupDraft: Int {
    case lineup
    case player_list
    case team_list
}

enum LeagueStatus: Int {
    case cancelled = 0
    case waitingForStart = 1, onGoing, finished
    
    static func fromHashValue(hashValue: Int) -> LeagueStatus {
        if hashValue == LeagueStatus.cancelled.rawValue {
            return .cancelled
        } else if hashValue == LeagueStatus.waitingForStart.rawValue {
            return .waitingForStart
        } else if hashValue == LeagueStatus.onGoing.rawValue {
            return .onGoing
        }
        return .finished
    }
}

enum GlobalRankingType: Int {
    case global = 0
    case city = 1
    case country = 2
    case club = 3
    case none = 4
    
    func getString() -> String {
        switch self {
        case .global:
            return "global"
        case .city:
            return "city"
        case .club:
            return "club"
        case .country:
            return "country"
        default:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case .global:
            return "Global".localiz()
        case .country:
            return "Country".localiz()
        case .city:
            return "Region".localiz()
        case .club:
            return "Fav Club".localiz()
        default:
            return ""
        }
    }
}

enum DragDirection {
  case none, left, right, vertical, horizontal, up, down
}

enum PlayerListType {
    case playerList, playerPool
}

enum PlayerDetailType {
    case statistic, statisticWithTeam
}

enum DropdownViewStyle {
    case white, blue
}

enum FromViewController {
    case PlayerList
    case TeamPlayerList
}

enum PlayerDetailSection: Int {
    case Transfer
    case Statistic
}

enum LineupRowType: Int {
    case lineup = 0, field, complete
}

enum PlayListSection: Int {
    case search
    case player
}

enum PickingPhotoAction {
    case cancel, photo, camera
}
