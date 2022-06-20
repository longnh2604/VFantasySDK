//
//  VFantasyStructs.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

struct DateFormat {
    static let kyyyyMMdd_hhmm = "dd/MM/yyyy HH:mm"
    static let kyyyyMMdd_1 = "dd/MM/yyyy"
    static let kyyyyMMdd_hhmmss = "yyyy-MM-dd HH:mm:ss"
    static let kyyyyMMdd_hhmmss_1 = "dd/MM/yyyy HH:mm:ss"
    static let kyyyyMMdd = "yyyy-MM-dd"
    static let EEEEMMddYYYY = "EEEE,MMMM-dd-yyyy"
    static let kyyyyMM = "yyyy-MM"
    static let khhmm = "HH:mm"
}

struct FormatDate {
    //Sep 17, 2:22 AM
    static let format_1 = "MMM d, h:mm a"
    
    //Mon, 17 Sep 2018 02:22:12 +0000
    static let format_2 = "E, d MMM yyyy HH:mm:ss Z"
    
    //September 2018
    static let format_3 = "MMMM yyyy"
    
    //Monday, Sep 17, 2018
    static let format_4 = "EEEE, MMM d, yyyy"
    
    //Fri 7/20 10:00 AM
    static let format_5 = "E, MM/dd h:mm a"
    
    //"2018/09/10 00:00:00"
    static let format_6 = "yyyy/MM/dd HH:mm:ss"
    
    //"2018/09/20
    static let format_7 = "yyyy/MM/dd"
    
    //"2018/09/10 00:00:00"
    static let format_8 = "yyyy/MM/dd hh:mm:ss"
    
    //Monday, 20 June 2021
    static let format_9 = "EEEE, dd MMMM yyyy"

}

struct FontName {
    static let blackItalic = "SFProDisplay-BlackItalic"
    static let black = "SFProDisplay-Black"
    static let regular = "SFProDisplay-Regular"
    static let bold = "SFProDisplay-Bold"
}

struct FontSize {
    static let large: CGFloat = 20
    static let big: CGFloat = 18
    static let normal: CGFloat = 14
    static let small: CGFloat = 13
}

struct StorageKey {
    static let league = "leagues/images"
    static let team = "leagues/images"
    static let user = "users/images"
}

struct NotificationName {
    //notify when done receive device token from System
    static let didGetDeviceToken = Notification.Name("notificationDidGetDeviceToken")
    //update Leagues when created league
    static let reloadMyLeaguesHomeScreen = Notification.Name("notificationReloadMyLeaguesHomeScreen")
    //update iCarousel when Home screen done requesting my leagues
    static let homeDidLoadLeagues = Notification.Name("notificationHomeDidLoadLeagues")
    //request API when load more items of my leagues in Home screen
    static let homeRequestLeagues = Notification.Name("notificationHomeRequestLeagues")
    //request API when load more items of my teams in League screen
    static let leagueRequestTeams = Notification.Name("notificationLeagueRequestTeams")
    //update League Detail UI when created league
    static let editedLeague = Notification.Name("notificationEditedLeague")
    //update League Detail list team UI when update team
    static let updatedTeam = Notification.Name("notificationUpdatedTeam")
    //change to tab League when click JOIN button in Home screen
    static let refreshHomeLeagues = Notification.Name("notificationRefreshHomeLeagues")
    //reload choose my league in league viewcontroller
    static let reloadMyLeague = Notification.Name("notificationReloadMyLeague")
    //pick player
    static let pickPlayer = Notification.Name("notificationPickPlayer")
    //show player detail
    static let showPlayerDetail = Notification.Name("notificationShowPlayerDetail")
    //add player
    static let addPlayer = Notification.Name("notificationAddPlayer")
    //remove player
    static let removePlayer = Notification.Name("notificationRemovePlayer")
    //update field
    static let updateField = Notification.Name("notificationUpdateField")
    //update gameweek
    static let updateGameWeek = Notification.Name("notificationUpdateGameWeek")
    // complete setup team.
    static let completeSetupTeam = Notification.Name("notificationCompleteSetup")
    //change views on setup team.
    static let changeView = Notification.Name("notificationChangeView")
    //update statistic
    static let updateStatistic = Notification.Name("notificationUpdateStatistic")
    //hide leagues keyboard
    static let hideKeyboard = Notification.Name("notificationHideKeyboard")
    //Transferred player -> update Transfer Viewcontroller
    static let transferredPlayer = Notification.Name("notificationHideKeyboard")
    //Edit profile -> update view profile
    static let editProfile = Notification.Name("notificationEditProfile")
    //Reload when selected Home Tab
    static let selectedHomeTab = Notification.Name("notificationSelectedHomeTab")
    //Reload when selected Notification Tab
    static let selectedNotificationTab = Notification.Name("notificationSelectedNotificationTab")
    //Clear register data when logout
    static let clearRegisterData = Notification.Name("notificationClearRegisterData")
    //Update budget when finish transfer
    static let updateTransferBudget = Notification.Name("notificationUpdateTransferBudget")
    //Update time countdown for transferring
    static let updateTimeStatus = Notification.Name("NotificationUpdateTimeStatus")
    //Change Main Screen tab on Push
    static let changeMainScreenTabOnPush = Notification.Name("notificationChangeMainScreenTabOnPush")
    //Open PitchView
    static let openPitchView = Notification.Name("notificationOpenPitchView")
    //update current turn countdown time
    static let updateCurrentTurnCountdownTime = Notification.Name("notificationUpdateCurrentTurnCountdownTime")
    //update notifications count
    static let updateNotificationsCount = Notification.Name("notificationUpdateNotificationsCount")
    //update localize
    static let updateLocalize = Notification.Name("notificationUpdateLocalize")
}

struct NotificationKey {
    static let myLeagues = "myLeagues"
    static let position = "position"
    static let index = "index"
    static let player = "player"
    static let players = "players"
    static let statistic = "statistic"
    static let showValue = "showValue"
    static let changeView = "changeView"
    static let updateGameWeek = "updaateGameWeek"
    static let completeSetupTeam = "completeSetupTeam"
}

struct DataFormationChange {
    var player: Player!
    var position: PositionPlayer!
}

struct PlayerFilterKey {
    static let total = "total"
    static let avg = "avg"
    static let points_per_round = "points_per_round"
}

struct FilterValue {
    static let total = "total_stats".localiz()
    static let avgAll = "avg_season".localiz()
    static let avg5 = "avg_5".localiz()
    static let avg3 = "avg_3".localiz()
    static let avg1 = "last_round".localiz()
    static let points_per_round = "point_per_round".localiz()
}

struct StatsViewData {
    static let matches = "matches".localiz().uppercased()
    static let win = "win".localiz().uppercased()
    static let draw = "draw".localiz().uppercased()
    static let loss = "loss".localiz().uppercased()
    static let points = "pts".localiz().uppercased()
}

struct DisplayKey {
    static let value = "value"
    static let point = "point"
    static let goals = "goals"
    static let assists = "assists"
    static let clean_sheet = "clean_sheet"
    static let duels_they_win = "duels_they_win"
    static let passes = "passes"
    static let shots = "shots"
    static let saves = "saves"
    static let yellow_cards = "yellow_cards"
    static let dribbles = "dribbles"
    static let turnovers = "turnovers"
    static let balls_recovered = "balls_recovered"
    static let fouls_committed = "fouls_committed"
    static let name = "name"
    static let total_point = "total_point"
    static let main_position = "main_position"
    static let desc = "desc"
    static let asc = "asc"
}
