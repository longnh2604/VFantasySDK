//
//  GlobalWeekScoreListView.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class GlobalWeekScoreListView: UIView {

    @IBOutlet weak var tbvList: UITableView!
    
    @IBOutlet weak var lblMineNumber: UILabel!
    @IBOutlet weak var ivMineLogo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    
    var rootView: UIViewController!
    var teamId: Int = 0
    var leagueId: Int = 0
    var gameweek: GameWeek!
    
    private var presenter = GlobalRankingPresenter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = self.createFromNib()
        let contentView = views?.first as? UIView
        contentView?.backgroundColor = .clear
        contentView?.frame = self.bounds
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        setup()
    }
    
    func setup() {
        ivMineLogo.roundCorners(.allCorners, 8.0)
        presenter.attachView(view: self)
        self.tbvList.contentInset = UIEdgeInsets(top: 24.0, left: 0, bottom: 40, right: 0)
        self.tbvList.register(UINib(nibName: NewGlobalRankingCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: NewGlobalRankingCell.identifierCell)
    }

    func initData() {
        if self.presenter.users.isEmpty {
            self.presenter.getLeagueRankingByRound(self.gameweek.id ?? 0, self.leagueId, self.teamId)
        }
    }
    
    func updateData() {
        ivMineLogo.setPlayerAvatarRefreshCache(with: presenter.teamData?.logo)
        lblMineNumber.text = String(presenter.teamData?.rank ?? 0)
        lblName.text = presenter.teamData?.name
        lblRank.text = String(presenter.teamData?.point ?? 0)
    }
}

extension GlobalWeekScoreListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewGlobalRankingCell.identifierCell) as? NewGlobalRankingCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.contentToBottomLayout.constant = indexPath.row == self.presenter.users.count - 1 ? 0.0 : 1.0
        if indexPath.row == 0 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.topLeft, .topRight], 16.0)
        } else if indexPath.row == self.presenter.users.count - 1 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.bottomLeft, .bottomRight], 16.0)
        } else {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, .allCorners, 0.0)
        }
        cell.updateData(data: presenter.users[indexPath.row], isWeekScore: true)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
}

extension GlobalWeekScoreListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewGlobalRankingCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = presenter.users[indexPath.row]
        let myTeam = MyTeamData(id: user.id, createdAt: nil, updatedAt: nil, currentBudget: nil, description: nil, formation: nil, league: nil, isCompleted: nil, isOwner: user.isOwner, logo: nil, name: user.name, pickOrder: nil, rank: user.rank, totalPlayers: user.totalPlayers, user: user.user, totalPoint: user.totalPoint, globalRanking: nil, currentGW: presenter.myTeam?.currentGW)
        VFantasyCommon.gotoPointTeam(myTeam, from: self.rootView)
    }
}

extension GlobalWeekScoreListView: RankingGlobalView {
    
    func reloadView() {
        self.updateData()
        self.tbvList.reloadData()
    }
    
    func startLoading() {
        self.rootView.startAnimation()
    }
    
    func finishLoading() {
        self.rootView.stopAnimation()
    }
    
    func alertMessage(_ message: String) {
        self.rootView.showAlert(message: message)
    }
}

extension GlobalWeekScoreListView: UIScrollViewDelegate {
    @objc func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if yVelocity < 0 {
            // UP
            if (offset - maxOffset) >= 10.0 {
                self.presenter.loadMoreRankingByRound(self.gameweek.id ?? 0, self.leagueId, self.teamId)
            }
        }else if yVelocity > 0 {
            // DOWN
        }else{
            // UN Define
        }
    }
}
