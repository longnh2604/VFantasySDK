//
//  GlobalLeaguePresenter.swift
//  VFantasyGlobal
//
//  Created by User on 26/05/2022.
//

import Foundation

protocol GlobalLeagueView: BaseViewProtocol {
    func reloadData()
    func gotoCreateTeam()
    func gotoPickPlayers()
    func gotoTransferPlayer(_ deletedPlayer: [Player])
    func goBackGlobal(_ teamId: Int)
    func reloadGlobalTeam(_ isSwitchTeam: Bool)
    func reloadMyTeams()
    func reloadMyLeagues()
    func redeemLeague(_ data: LeagueDatum?)
}

class GlobalLeaguePresenter: NSObject {
    private var service: GlobalServices? = nil
    weak private var supperView: GlobalLeagueView?
    
    var teamId: Int = 0
    var globalLeague: CreateTeamModel = CreateTeamModel()
    var myTeam: MyTeamData?
    var allTeams: [MyTeamData] = []
    var leagues = [LeagueDatum]()
    var isCompletedTeam: Bool = false
    var isSwitchedTeam: Bool = false
    
    init(service: GlobalServices) {
        super.init()
        self.leagues = []
        self.service = service
    }
    func attachView(view: GlobalLeagueView) {
        self.supperView = view
    }
    //MARK: Fake my leagues
    func requestMyLeagueList() {
        service?.myLeagues(callBack: { result, status in
            self.handleLeaguesCallback(result, status)
        })
    }
    private func handleLeaguesCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, supperView)
        } else {
            self.handleLeaguesResponseSuccess(result)
        }
    }
    private func handleLeaguesResponseSuccess(_ response: AnyObject) {
        if let result = response as? LeagueData {
            guard let meta = result.meta else {
                supperView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    supperView?.finishLoading()
                    return
                }
                supperView?.alertMessage(message.localiz())
                return
            }
            
            if let res = result.response {
                if let newData = res.data {
                    leagues = newData
                    supperView?.reloadMyLeagues()
                }
            }
            
            supperView?.finishLoading()
        }
    }
    //MARK: Info My Team
    func getInfoMyTeam(_ isSwitchTeam: Bool = false) {
        self.isSwitchedTeam = isSwitchTeam
        if self.teamId == 0 {
            self.supperView?.gotoCreateTeam()
            self.supperView?.reloadGlobalTeam(false)
            return
        }
        supperView?.startLoading()
        service?.getDetailTeam(self.teamId, callBack: { (result, status) in
            self.handleMyTeamCallback(isSwitchTeam, result, status)
        })
    }
    
    private func handleMyTeamCallback(_ isSwitchTeam: Bool, _ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, supperView)
        } else {
            self.handleMyTeamResponseSuccess(isSwitchTeam, result)
        }
    }
    
    private func handleMyTeamResponseSuccess(_ isSwitchTeam: Bool, _ response: AnyObject) {
        self.isCompletedTeam = false
        if let result = response as? GlobalMyTeam {
            guard let meta = result.meta else {
                supperView?.finishLoading()
                self.supperView?.reloadGlobalTeam(false)
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    supperView?.finishLoading()
                    self.supperView?.reloadGlobalTeam(false)
                    return
                }
                supperView?.alertMessage(message.localiz())
                return
            }
            
            self.myTeam = result.response
            if let res = result.response {
                self.globalLeague.updates(res.name, res.description, res.id, res.logo)
                //isCompleted false || totalPlayer < 18
                if let isCompleted = res.isCompleted, isCompleted == true {
                    if let totalPlayers = res.totalPlayers, totalPlayers == 18 {
                        self.supperView?.reloadData()
                        self.isCompletedTeam = true
                        self.supperView?.reloadGlobalTeam(isSwitchTeam)
                    } else {
                        self.getLeagueDetail(self.myTeam?.league?.id ?? 0)
                    }
                } else {
                    self.supperView?.gotoPickPlayers()
                    self.supperView?.reloadGlobalTeam(false)
                }
            } else {
                self.supperView?.gotoCreateTeam()
                self.supperView?.reloadGlobalTeam(false)
            }
            supperView?.finishLoading()
        } else {
            supperView?.reloadGlobalTeam(false)
        }
        
    }
    
    // MARK: Check transfer
    func validateTransfer(_ complete: @escaping (Bool, String) -> Void) {
        supperView?.startLoading()
        service?.getValidateTransfer(teamID: self.myTeam?.id ?? 0, { (response, status) in
            self.supperView?.finishLoading()
            if !status {
                if let message = response as? String {
                    complete(false, message)
                } else if let error = response as? NSError, error.domain == NSURLErrorDomain {
                    complete(false, "no_internet".localiz())
                }
            } else {
                if let result = response as? GlobalTransferDeadline {
                    if let meta = result.meta {
                        if meta.success == true {
                            complete(true, meta.message?.localiz() ?? "")
                        } else {
                            complete(false, meta.message?.localiz() ?? "")
                        }
                    }
                } else {
                    complete(false, "")
                }
            }
        })
    }

    
    //MARK: Get league detail
    func getLeagueDetail(_ leagueId: Int) {
        supperView?.startLoading()
        service?.getDetailLeague(leagueId, { (result, status) in
            self.handleLeagueDetailCallback(result, status)
        })
        
    }
    
    private func handleLeagueDetailCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, supperView)
        } else {
            self.handleLeagueDetailResponseSuccess(result)
        }
    }
    
    private func handleLeagueDetailResponseSuccess(_ response: AnyObject) {
        if let result = response as? GlobalLeagueModel {
            guard let meta = result.meta else {
                supperView?.finishLoading()
                self.supperView?.reloadGlobalTeam(false)
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    supperView?.finishLoading()
                    self.supperView?.reloadGlobalTeam(false)
                    return
                }
                supperView?.alertMessage(message.localiz())
                return
            }
            
            let totalTransferRoundPlayers = result.response?.team?.totalPlayers ?? 18
            if totalTransferRoundPlayers < 18 {
                supperView?.gotoTransferPlayer(result.response?.deletedPlayers ?? [])
            } else {
                self.isCompletedTeam = true
                supperView?.reloadData()
            }
            
            supperView?.finishLoading()
        }
        supperView?.reloadGlobalTeam(self.isSwitchedTeam)
    }
        
    //MARK: Global league
    func createGlobalLeague() {
        supperView?.startLoading()
        service?.createGlobalTeam(globalLeague, callBack: { (result, status) in
            self.handleGlobalLeagueCallback(result, status)
        })
    }
    
    func editGlobalLeague() {
        supperView?.startLoading()
        service?.editGlobalTeam(globalLeague, callBack: { (result, status) in
            self.handleGlobalLeagueCallback(result, status)
        })
    }
    
    private func handleGlobalLeagueCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, supperView)
        } else {
            self.handleGlobalLeagueResponse(result)
        }
    }
    
    func handleGlobalLeagueResponse(_ response: AnyObject) {
        if let result = response as? GlobalTeamModel {
            guard let meta = result.meta else {
                supperView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    supperView?.finishLoading()
                    return
                }
                supperView?.alertMessage(message.localiz())
                return
            }
            
            if let data = result.response {
                supperView?.goBackGlobal(data.id)
            }
            supperView?.finishLoading()
        }
    }
    
    //MARK: Redeem code
    func redeemCodeToJoinLeague(_ code: String) {
        supperView?.startLoading()
        service?.redeemToJoin(code, { (result, status) in
            self.handleRedeemCodeCallback(result, status)
        })
    }
    
    private func handleRedeemCodeCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, supperView)
        } else {
            self.handleRedeemCodeResponseSuccess(result)
        }
    }
    
    private func handleRedeemCodeResponseSuccess(_ response: AnyObject) {
        if let result = response as? RedeemData {
            guard let meta = result.meta else {
                supperView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    supperView?.finishLoading()
                    return
                }
                supperView?.alertMessage(message.localiz())
                return
            }
            supperView?.redeemLeague(result.response)
            supperView?.finishLoading()
        }
    }
}

//MARK: - All my teams
extension GlobalLeaguePresenter {
    func getAllMyTeams() {
        service?.getMyTeams({ (result, status) in
            self.handleMyTeamsCallback(result, status)
        })
    }
    
    private func handleMyTeamsCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, supperView)
        } else {
            self.handleMyTeamsResponseSuccess(result)
        }
    }
    
    private func handleMyTeamsResponseSuccess(_ response: AnyObject) {
        self.allTeams.removeAll()
        if let result = response as? GlobalMyTeams {
            guard let meta = result.meta else {
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    return
                }
                supperView?.alertMessage(message.localiz())
                return
            }
            
            self.allTeams = result.response?.data ?? []
        }
        self.supperView?.reloadMyTeams()
    }
}
