//
//  TurnReceiveData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

struct TurnReceiveData: Codable {
    let event: String?
    let rootNumber, number: Int?
    let room: String?
    let totalPlayer, totalRound, pickRound, leagueID: Int?
    let showPickRound: Int?
    var teams: [Team]?
    var endTurn: Bool?
    var playerData: SocketPlayerData?
    
    enum CodingKeys: String, CodingKey {
        case event
        case rootNumber = "root_number"
        case number, room
        case totalPlayer = "total_player"
        case totalRound = "total_round"
        case pickRound = "pick_round"
        case showPickRound = "show_pick_round"
        case leagueID = "league_id"
        case teams = "league"
        case endTurn = "end_turn"
        case playerData = "playerData"
    }
    
    func getCurrentTeam() -> TeamTurnData? {
        if let current = teams?.first(where: { $0.current == true }) {
            return teamTurnMapping(current)
        }
        return nil
    }
    
    func getNextTeam() -> TeamTurnData? {
        if let next = teams?.first(where: { $0.next == true }) {
            return teamTurnMapping(next)
        }
        return nil
    }
    
    func getTeamMatch(teamId: Int) -> TeamTurnData? {
        if let match = teams?.first(where: { $0.id == teamId }) {
            return teamTurnMapping(match)
        }
        return nil
    }
    
    func handleAtLastMoment(_ completion: @escaping () -> ()) {
        if let currentTeam = getCurrentTeam() {
            if currentTeam.time == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion()
                }
            }
        }
    }
    
    private func teamTurnMapping(_ team: Team) -> TeamTurnData? {
        if let time = number, let pickRound = showPickRound, let id = team.id, let name = team.name, let order = team.pickOrder, let dueTime = team.dueNextTime, let dueMax = team.dueNextTimeMax {
            return TeamTurnData(time: time, id: id, name: name, pickTurn: pickRound, pickOrder: order, dueNextTime: dueTime, dueNextTimeMax: dueMax)
        }
        return nil
    }
    
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}

struct SocketPlayerData: Codable {
    let token, action: String?
    let teamId, playerId, pickOrder, pickRound: Int?
    let order: Int?
    
    enum CodingKeys: String, CodingKey {
        case token
        case action
        case teamId = "team_id"
        case playerId = "player_id"
        case pickOrder = "pick_order"
        case pickRound = "pick_round"
        case order
    }
}

struct TeamTurnData {
    var time = 0
    var id = 0
    var name = ""
    var pickTurn = 0
    var pickOrder = 0
    var dueNextTime = 0
    var dueNextTimeMax = 0
}
