//
//  GlobalLeagueModelView.swift
//  VFantasyGlobal
//
//  Created by User on 26/05/2022.
//

import UIKit

struct GlobalLeagueModelView {

    var id = 0
    var name = ""
    var avatar = ""
    var desc = ""
    var startGameWeek: GameWeek?
    var gameweekId = 0
    var gameweekTitle = ""
    var code = ""
    var ownerUserId = 0
    var currentNumberOfUser = 0
    
    var isOwner: Bool {
        let loggedInUserId = VFantasyManager.shared.getUserId()
        return loggedInUserId == ownerUserId
    }
    
    init() {
        
    }
    
    init(name: String, avatar: String, desc: String, gameweekId: Int) {
        self.name = name
        self.avatar = avatar
        self.desc = desc
        self.gameweekId = gameweekId
    }
    
    init(id: Int, name: String, avatar: String, desc: String, gameweekId: Int, gameweekTitle: String) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.desc = desc
        self.gameweekId = gameweekId
        self.gameweekTitle = gameweekTitle
    }
    
    init(league: LeagueDatum) {
        self.id = league.id ?? 0
        self.name = league.name ?? ""
        self.avatar = league.logo ?? ""
        self.desc = league.description ?? ""
        self.gameweekId = league.startGameweekId ?? 0
        self.gameweekTitle = ""
        self.code = league.code ?? ""
        self.ownerUserId = league.userID ?? 0
        self.currentNumberOfUser = league.currentNumberOfUser ?? 0
        self.startGameWeek = league.startGameweek
    }
    
    init(league: GlobalLeagueData?) {
        self.id = league?.id ?? 0
        self.name = league?.name ?? ""
        self.avatar = league?.logo ?? ""
        self.desc = league?.description ?? ""
        self.gameweekId = league?.startGameweekId ?? 0
        self.gameweekTitle = ""
        self.code = league?.code ?? ""
    }
}
