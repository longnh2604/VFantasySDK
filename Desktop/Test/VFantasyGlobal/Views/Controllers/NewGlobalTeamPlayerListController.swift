//
//  NewGlobalTeamPlayerListController.swift
//  PAN689
//
//  Created by Quang Tran on 8/12/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class NewGlobalTeamPlayerListController: UIViewController {

    @IBOutlet weak var navigationBar: GlobaNavigationSearchBar!
    @IBOutlet weak var pageMenu: PageMenu!

    var sortType: SortType = .desc
    var clubID: String = ""
    var keyword: String = ""
    var initPageData: Bool = false
    var myTeam: MyTeamData?
    var fixedPosition = PlayerPositionType.all
    var pickingIndex = 0
    var seasonId: Int = 0
    var leagueId: Int = 0
    var currentCheckClub:[FilterData]?
    var playerLineupInfo = TeamPlayerInfo()
    var types: [PlayerPositionType] = [.all, .goalkeeper, .defender, .midfielder, .attacker]
    
    weak var delegate: GlobalTeamPlayerListViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initPageData {
            initPageData = true
            initPageMenu()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: 0x10003F)
        initHeaderBar()
    }
    
    func initHeaderBar() {
        navigationBar.delegate = self
        navigationBar.searchBar.layer.cornerRadius = 16.0
        navigationBar.searchBar.layer.masksToBounds = true
        navigationBar.searchBar.tfSearch.placeholder(text: "Search name to pick".localiz(), color: .white)

    }
    
    private func initPageMenu() {
        self.pageMenu.delegate = self
        self.pageMenu.dataSource = self
        self.pageMenu.reloadPageMenu(types.firstIndex(where: { return $0 == self.fixedPosition }) ?? 0)
    }
    
    private func updatePage(_ page: UIView) {
        guard let page = page as? GlobalPlayerListView, page.presenter != nil else { return }
        if  page.presenter!.playerListInfo.players.isEmpty ||
            page.presenter!.searchText != keyword ||
            page.presenter!.model.clubID != clubID ||
            page.presenter!.currentSortType != sortType {
            page.presenter!.currentSortType = sortType
            page.presenter!.model.clubID = clubID
            page.presenter!.searchText = keyword
            page.presenter!.refreshPlayerList()
        }
        page.updateBankView(self.playerLineupInfo.budget, self.sortType)

    }
}

extension NewGlobalTeamPlayerListController: GlobaNavigationSearchBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationSearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onRightOnClick(_ sender: GlobaNavigationSearchBar) {
        if let controller = UIApplication.getTopController() {
            if let filterVC = instantiateViewController(storyboardName: .player, withIdentifier: "FilterClubViewController") as? FilterClubViewController {
                filterVC.delegate = self
                filterVC.setCurrentCheck(position: nil, club: self.currentCheckClub)
                filterVC.showPosition = false
                filterVC.initBackView(title: "player_list".localiz())
                controller.navigationController?.pushViewController(filterVC, animated: true)
            }
        }
    }
    
    func onSearch(_ sender: GlobaNavigationSearchBar, _ key: String) {
        self.keyword = key
        if let page = self.pageMenu.currentPage {
            self.updatePage(page)
        }
    }
}

extension NewGlobalTeamPlayerListController : FilterClubViewControllerDelegate {
    func didClickBack(position: [FilterData], club: [FilterData]) {
        self.currentCheckClub = club
        
        var clubIds = [String]()
        club.forEach { (filterData) in
            clubIds.append(filterData.key)
        }
        
        self.clubID = clubIds.joined(separator: ",")
        if let page = self.pageMenu.currentPage {
            self.updatePage(page)
        }
    }
}

extension NewGlobalTeamPlayerListController: PlayerDetailViewControllerDelegate {
    func onPick(_ player: Player) {
        self.onAdded(player)
    }
    
    func onPick(_ id: Int) {
        
    }
}

extension NewGlobalTeamPlayerListController: GlobalPlayerListViewDelegate {
    func changedSort(_ sender: GlobalPlayerListView, _ order: OrderProperty, _ sort: SortType) {
        
    }
    
    func toggleSort() {
        let sort = VFantasyCommon.changeSorting(self.sortType)
        self.sortType = sort
        if let page = self.pageMenu.currentPage {
            self.updatePage(page)
        }
    }
    
    func onLoadMore(_ sender: GlobalPlayerListView) {
    }
    
    func onDetail(_ player: Player) {
        if let playerId = player.id {
            if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController, let gameplay = self.playerLineupInfo.gameplay {
                controller.setupPlayer(playerId, true)
                controller.setPickingPlayer(player)
                controller.delegate = self
                controller.setupTypePlayerStatistic(.statistic)
                controller.setFromView(.TeamPlayerList)
                controller.initBackView(title: "player_list".localiz())
                controller.setGameplay(gameplay)
              
                controller.setPlayerListType(.playerPool)
                controller.setupTeamId(myTeam?.id)
                controller.setupMyTeam(myTeam)
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func onAdded(_ player: Player) {
        var newPlayer = player
        newPlayer.order = pickingIndex + 1
        delegate?.onAddPlayer(newPlayer)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - PageMenuDelegate, PageMenuDatasource
extension NewGlobalTeamPlayerListController: PageMenuDelegate, PageMenuDatasource {
    func numbersPage(in pageMenu: PageMenu) -> Int {
        return types.count
    }

    func pageMenu(_ pageMenu: PageMenu, viewForPageAt index: Int) -> UIView {
        let page = GlobalPlayerListView()
        let popupPresenter = GlobalCreateTeamInfoPresenter()
        popupPresenter.playerLineupInfo = self.playerLineupInfo
        popupPresenter.showingHUD = true
        popupPresenter.sortPosition(index - 1)
        page.presenter = popupPresenter
        page.presenter!.attachView(view: page)
        page.presenter!.leagueID = self.leagueId
        page.presenter!.teamID = self.myTeam?.id ?? 0
        page.seasonId = self.seasonId
        page.rootView = self
        page.type = types[index]
        page.delegate = self
        return page
    }

    func heightForSegmentMenu(_ pageMenu: PageMenu) -> CGFloat {
        return 46
    }

    func pageMenu(_ pageMenu: PageMenu, viewForSegmentAt index: Int) -> UIView {
        let title = types[index].title
        let segmentItem = SegmentItemView(frame: CGRect(x: 0, y: 0, width: 300, height: 24))
        segmentItem.updateItem(title)
        let width = segmentItem.getWidthItem()
        var frame = segmentItem.frame
        frame.size.width = width + 32.0
        segmentItem.frame = frame
        return segmentItem
    }

    func tagsLabelForUpdateSegment(_ pageMenu: PageMenu) -> [Int] {
        return [100]
    }

    func titleNormalColors(_ pageMenu: PageMenu) -> [UIColor] {
        return [.white]
    }

    func titleSelectedColors(_ pageMenu: PageMenu) -> [UIColor] {
        return [UIColor(hex: 0xF87221)]
    }

    func pageViewDidEndScroll(_ pageMenu: PageMenu, _ previousIndex: Int, _ pageIndex: Int, _ viewItem: UIView) {
        self.updatePage(viewItem)
    }

    func pageReloadData(_ pageMenu: PageMenu, _ pageIndex: Int, _ pages: [UIView]) {

    }

    /* Menu Width Segment Type */
    func menuHeaderWidthType(_ pageMenu: PageMenu) -> Int {
        return MenuHeaderWidthType.automatic.rawValue
    }

    /* Menu Indicator Segment Type */
    func indicatorSegmentType(_ pageMenu: PageMenu) -> Int {
        return MenuHeaderIndicatorType.bounds.rawValue
    }
}

extension NewGlobalTeamPlayerListController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
