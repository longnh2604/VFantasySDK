//
//  GlobalInviteFriendPresenter.swift
//  VFantasyGlobal
//
//  Created by User on 27/05/2022.
//

import Foundation

protocol LeagueGlobalDetailView: BaseViewProtocol {
    func reloadView()
    func successInviteFriend()
}

class GlobalInviteFriendPresenter: NSObject {
    
    private var service: GlobalInviteFriendService? = nil
    weak private var viewLeagueDetail: LeagueGlobalDetailView?
    
    private var friendModel = LeagueFriendModel()
    var friends = [LeagueFriendDatum]()
    
    var searchText = ""
    var leagueId = 0
    
    init(service: GlobalInviteFriendService) {
        super.init()
        self.service = service
    }
    
    func attachView(view: LeagueGlobalDetailView) {
        self.viewLeagueDetail = view
    }
    
    // MARK: - Invite friend list
    
    func loadInviteFriends() {
        guard let viewLeagueDetail = self.viewLeagueDetail else { return }
        
        viewLeagueDetail.startLoading()
        
        friendModel.leagueID = String(leagueId)
        service?.leagueGlobalInviteFriends(friendModel) { response, status in
            if status {
                self.handleFriendsResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.viewLeagueDetail)
            }
        }
    }
    
    func handleFriendsResponseSuccess(_ response: AnyObject) {
        if let result = response as? LeagueFriendData {
            guard let meta = result.meta else {
                viewLeagueDetail?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    viewLeagueDetail?.finishLoading()
                    return
                }
                viewLeagueDetail?.alertMessage(message.localiz())
                return
            }
            
            if let res = result.response {
                let data = res.data ?? [LeagueFriendDatum]()
                friends += data
            }
            
            viewLeagueDetail?.finishLoading()
            viewLeagueDetail?.reloadView()
        }
    }
    
    func loadMoreFriends() {
        loadInviteFriends()
    }
    
    func reloadFriends() {
        friends.removeAll()
        guard searchText != "" else {
            viewLeagueDetail?.reloadView()
            return
        }
        friendModel.keyword = searchText
        loadInviteFriends()
    }
    
    // MARK: - Invite A Friend
    
    func inviteFriend(_ friendId: Int) {
        viewLeagueDetail?.startLoading()
        
        var model = InviteFriendModel()
        model.leagueID = leagueId
        model.userID = "\(VFantasyManager.shared.getUserId())"
        model.friendID = friendId
        
        service?.inviteFriend(model) { (response, status) in
            if status {
                self.handleInviteFriendResponseSuccess(response)
            } else {
                CommonResponse.handleResponseFail(response, self.viewLeagueDetail)
            }
        }
    }
    
    func handleInviteFriendResponseSuccess(_ response: AnyObject) {
        if let result = response as? InviteFriendData {
            guard let meta = result.meta else {
                viewLeagueDetail?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    viewLeagueDetail?.finishLoading()
                    return
                }
                viewLeagueDetail?.alertMessage(message.localiz())
                return
            }
            
            if let data = result.response {
                var friendList = [LeagueFriendDatum]()
                for item in friends {
                    if item.id == data.receiverID {
                        var friend = item
                        friend.isInvited = true
                        friendList.append(friend)
                    } else {
                        friendList.append(item)
                    }
                }
                friends = friendList
                viewLeagueDetail?.successInviteFriend()
            }
            
            viewLeagueDetail?.reloadView()
            viewLeagueDetail?.finishLoading()
        }
    }
}
