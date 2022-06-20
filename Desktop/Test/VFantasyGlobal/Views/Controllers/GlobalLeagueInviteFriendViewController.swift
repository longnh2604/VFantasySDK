//
//  GlobalLeagueInviteFriendViewController.swift
//  PAN689
//
//  Created by Quang Tran on 1/5/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import Foundation
import UIKit

class GlobalLeagueInviteFriendViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    private var presenter = GlobalInviteFriendPresenter(service: GlobalInviteFriendService())
    
    var successInviteFriendClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(view: self)
        presenter.reloadFriends()
    }
        
    func setLeagueId(_ id: Int) {
        presenter.leagueId = id
    }
}

// MARK: - UITableViewDataSource

extension GlobalLeagueInviteFriendViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == PlayListSection.search.rawValue {
            return 1
        }

        return presenter.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == PlayListSection.search.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFriendCell", for: indexPath) as! SearchFriendCell
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.selectionStyle = .none
        cell.updateUI(presenter.friends[safe: indexPath.row])
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension GlobalLeagueInviteFriendViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == PlayListSection.search.rawValue {
            return 100
        }
        return 60
    }
}

// MARK: - TransferGlobalView

extension GlobalLeagueInviteFriendViewController: LeagueGlobalDetailView {
    
    func reloadView() {
        tableView.reloadData()
    }
    
    // MARK: Process loading
    
    func startLoading() {
        self.startAnimation()
    }
    
    func finishLoading() {
        self.stopAnimation()
    }
    
    func alertMessage(_ message: String) {
        self.stopAnimation()
        self.showAlert(message: message)
    }
    
    func successInviteFriend() {
        successInviteFriendClosure?()
    }
}

// MARK: - UISearchBarDelegate

extension GlobalLeagueInviteFriendViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            presenter.searchText = searchText
            presenter.reloadFriends()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        presenter.searchText = text
        presenter.reloadFriends()
        
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let emptyText = ""
        searchBar.text = emptyText
        presenter.searchText = emptyText
        presenter.reloadFriends()
        
        if let controller = UIApplication.getTopController() {
            controller.view.endEditing(true)
        }
    }
}

// MARK: - UserCellDelegate

extension GlobalLeagueInviteFriendViewController: UserCellDelegate {
    
    func onInviteFriend(_ index: Int) {
        if let friendId = presenter.friends[safe: index]?.id {
            presenter.inviteFriend(friendId)
        }
    }
}

extension GlobalLeagueInviteFriendViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
