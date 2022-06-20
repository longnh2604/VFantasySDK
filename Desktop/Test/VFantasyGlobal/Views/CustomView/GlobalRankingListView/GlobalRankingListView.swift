//
//  GlobalRankingListView.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class GlobalRankingListView: UIView {

    @IBOutlet weak var tbvList: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblMineNumber: UILabel!
    @IBOutlet weak var ivMineLogo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var collectionViewHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var collectionViewToTopLayout: NSLayoutConstraint!

    var rootView: UIViewController!
    var leagueId = 0
    var myTeam: MyTeamData?
    var type: GlobalRankingType = .global {
        didSet {
            presenter.attachView(view: self)
            presenter.rankingType = type
            presenter.leagueId = self.leagueId
            presenter.myTeam = self.myTeam
        }
    }
    var gameweeks: [GameWeek] = [] {
        didSet {
            self.collectionViewHeightLayout.constant = gameweeks.isEmpty ? 0.0 : 30.0
            self.collectionViewToTopLayout.constant = gameweeks.isEmpty ? 0.0 : 16.0
            self.collectionView.reloadData()
            self.setNeedsLayout()
        }
    }
    var currentGW: Int = 0 {
        didSet {
            guard let index = self.gameweeks.firstIndex(where: { return $0.id == self.currentGW }) else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
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
        self.tbvList.contentInset = UIEdgeInsets(top: 0.0, left: 0, bottom: 40, right: 0)
        self.tbvList.register(UINib(nibName: NewGlobalRankingCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: NewGlobalRankingCell.identifierCell)
        self.collectionView.register(UINib(nibName: "GlobalPlayerListPositionCell", bundle: Bundle.sdkBundler()), forCellWithReuseIdentifier: "GlobalPlayerListPositionCell")
    }

    func initData() {
        self.presenter.filterByGW(self.currentGW)
        if self.presenter.users.isEmpty {
            self.presenter.getLeagueRanking()
        }
    }
    
    func updateData() {
        ivMineLogo.setPlayerAvatarRefreshCache(with: presenter.teamData?.logo)
        lblMineNumber.text = String(presenter.teamData?.rank ?? 0)
        lblName.text = presenter.teamData?.name
        lblRank.text = VFantasyCommon.formatPoint(presenter.teamData?.totalPoint)
    }
}

extension GlobalRankingListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewGlobalRankingCell.identifierCell) as? NewGlobalRankingCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.contentToBottomLayout.constant = indexPath.row == 9 - 1 ? 0.0 : 1.0
        if indexPath.row == 0 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.topLeft, .topRight], 16.0)
        } else if indexPath.row == self.presenter.users.count - 1 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.bottomLeft, .bottomRight], 16.0)
        } else {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, .allCorners, 0.0)
        }
        cell.updateData(data: presenter.users[indexPath.row])
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
}

extension GlobalRankingListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewGlobalRankingCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = presenter.users[indexPath.row]
        let myTeam = MyTeamData(id: user.id, createdAt: nil, updatedAt: nil, currentBudget: nil, description: nil, formation: nil, league: nil, isCompleted: nil, isOwner: user.isOwner, logo: nil, name: user.name, pickOrder: nil, rank: user.rank, totalPlayers: user.totalPlayers, user: user.user, totalPoint: user.totalPoint, globalRanking: nil, currentGW: presenter.myTeam?.currentGW)
        VFantasyCommon.gotoPointTeam(myTeam, from: self.rootView)
    }
}

extension GlobalRankingListView: RankingGlobalView {
    
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

extension GlobalRankingListView: UIScrollViewDelegate {
    @objc func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if yVelocity < 0 {
            // UP
            if (offset - maxOffset) >= 10.0 {
                self.presenter.loadMoreFriends()
            }
        }else if yVelocity > 0 {
            // DOWN
        }else{
            // UN Define
        }
    }
}

extension GlobalRankingListView : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GlobalPlayerListPositionCell", for: indexPath) as! GlobalPlayerListPositionCell
        if indexPath.row == 0 {
            cell.lblPosition.text = "all".localiz()
            cell.isActive = currentGW == 0
        } else {
            let gw = self.gameweeks[indexPath.row-1]
            cell.lblPosition.text = "GW\(gw.round ?? 0)"
            cell.isActive = currentGW == gw.id
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gameweeks.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var isReload = false
        if indexPath.row == 0 {
            if self.currentGW != 0 {
                self.currentGW = 0
                isReload = true
            }
        } else {
            let round = self.gameweeks[indexPath.row - 1].id ?? 0
            if round != currentGW {
                currentGW = round
                isReload = true
            }
        }
        if isReload {
            collectionView.reloadData()
            self.presenter.filterByGW(currentGW)
            self.presenter.resetPage()
            self.presenter.getLeagueRanking()
        }
    }
}

extension GlobalRankingListView : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var title = "all".localiz()
        if indexPath.row != 0 {
            title = "GW\(self.gameweeks[indexPath.row - 1].round ?? 0)"
        }
        let font = UIFont(name: FontName.bold, size: 14)!
        let width = title.width(withConstrainedHeight: 30.0, font: font)
        return CGSize(width: width + 24.0, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
