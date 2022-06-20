//
//  GlobalRankingListView.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol Super7PlayerListViewDelegate {
    func onSelectedPlayer(_ player: Player, _ clubId: Int, _ matchId: Int)
}

class Super7PlayerListView: UIView {

    @IBOutlet weak var tbvList: UITableView!

    var delegate: Super7PlayerListViewDelegate?
    var rootView: UIViewController!
    var presenter = Super7Presenter(service: Super7Service())
    var clubID: Int = 0 {
        didSet {
            presenter.playerRequest.clubID = "\(clubID)"
        }
    }
    var leagueID: Int = 0 {
        didSet {
            presenter.playerRequest.leagueID = "\(leagueID)"
        }
    }
    var seasonID: Int = 0 {
        didSet {
            presenter.playerRequest.season_id = "\(seasonID)"
        }
    }
    var selected_player: Player?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = Bundle.sdkBundler()?.loadNibNamed("Super7PlayerListView", owner: self, options: nil)
        let contentView = views?.first as? UIView
        contentView?.backgroundColor = .clear
        contentView?.frame = self.bounds
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        setup()
    }
    
    func setup() {
        self.presenter.attachView(view: self)
        self.presenter.updatePerpageForPlayer()
        self.tbvList.register(UINib(nibName: Super7PlayerCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: Super7PlayerCell.identifierCell)
    }
    
    func initData(_ keySearch: String = "") {
        if self.presenter.players.isEmpty || self.presenter.playerRequest.keyword != keySearch {
            self.presenter.resetPlayerPage()
            self.presenter.playerRequest.keyword = keySearch
            self.presenter.getPlayerList()
        }
    }
    
}

extension Super7PlayerListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Super7PlayerCell.identifierCell) as? Super7PlayerCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        
        let player = self.presenter.players[indexPath.row]
        cell.updateData(player)
        cell.btnAdd.isHidden = player.id == selected_player?.id
        cell.delegate = self

        cell.contentToBottomLayout.constant = indexPath.row == self.presenter.players.count - 1 ? 0.0 : 1.0
        if indexPath.row == 0 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.topLeft, .topRight], 16.0)
        } else if indexPath.row == self.presenter.players.count - 1 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.bottomLeft, .bottomRight], 16.0)
        } else {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, .allCorners, 0.0)
        }
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
}

extension Super7PlayerListView: Super7PlayerCellDelegate {
    func onAction(sender: Super7PlayerCell, _ player: Player) {
        self.delegate?.onSelectedPlayer(player, self.clubID, 0)
    }
}

extension Super7PlayerListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GlobalPlayerNewCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = self.presenter.players[indexPath.row]
        if let id = player.id {
            if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                controller.hidesBottomBarWhenPushed = true
                controller.setupPlayer(id)
                controller.initBackView(title: "Super 9".localiz())
                controller.setPlayerListType(.playerPool)
//                controller.setupTeamId(presenter.teamId)
                controller.setupTypePlayerStatistic(.statistic)
//                controller.setupMyTeam(presenter.myTeam)
                controller.setupIsPlayerStatsGlobal(false)
                self.rootView.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension Super7PlayerListView: Super7GlobalView {
    func reloadPlayerList() {
        DispatchQueue.main.async {
            self.tbvList.reloadData()
        }
    }
    
    func reloadSuper7DreamTeams() { }
    
    func reloadSuper7PitchView() { }
    
    func updatedSuper7Team() { }
    
    func reloadSuper7Team() { }
    
    func reloadSuper7League() { }
    
    func startLoading() {
        self.rootView.startAnimation()
    }
    
    func finishLoading() {
        self.rootView.stopAnimation()
    }
    
    func alertMessage(_ message: String) {
        self.rootView.stopAnimation()
        self.rootView.showAlert(message: message)
    }
}

extension Super7PlayerListView: UIScrollViewDelegate {
    @objc func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height

        let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if yVelocity < 0 {
            // UP
            if (offset - maxOffset) >= 10.0 {
                self.presenter.loadMorePlayers()
            }
        }else if yVelocity > 0 {
            // DOWN
        }else{
            // UN Define
        }
    }
}
