//
//  Super7SelectPlayerController.swift
//  PAN689
//
//  Created by Quang Tran on 12/14/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class Super7SelectPlayerController: UIViewController {

    @IBOutlet weak var navigationBar: GlobaNavigationSearchBar!
    @IBOutlet weak var pageMenu: PageMenu!

    var teams: [String] = []
    var match: Super7Match!
    var super7Team: MyTeamData!
    var keySearch: String = ""
    var delegate: Super7PlayerListViewDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        initPageMenu()
    }
    
    func initUI() {
        self.navigationBar.searchBar.tfSearch.placeholder(text: "Search name".localiz(), color: .white)
        self.navigationBar.hasRightItem = false
        self.navigationBar.delegate = self
    }
    
    private func initPageMenu() {
        self.teams.append(contentsOf: [self.match.team1 ?? "", self.match.team2 ?? ""])
        self.pageMenu.delegate = self
        self.pageMenu.dataSource = self
    }
}

// MARK: - GlobaNavigationSearchBarDelegate
extension Super7SelectPlayerController: GlobaNavigationSearchBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationSearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onRightOnClick(_ sender: GlobaNavigationSearchBar) {
        
    }
    
    func onSearch(_ sender: GlobaNavigationSearchBar, _ key: String) {
        self.keySearch = key
        guard let page = self.pageMenu.currentPage as? Super7PlayerListView else { return }
        page.initData(self.keySearch)
    }
}

extension Super7SelectPlayerController: Super7PlayerListViewDelegate {
    func onSelectedPlayer(_ player: Player, _ clubId: Int, _ matchId: Int) {
        self.delegate?.onSelectedPlayer(player, clubId, self.match.id ?? 0)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - PageMenuDelegate, PageMenuDatasource
extension Super7SelectPlayerController: PageMenuDelegate, PageMenuDatasource {
    func numbersPage(in pageMenu: PageMenu) -> Int {
        return teams.count
    }
    
    func pageMenu(_ pageMenu: PageMenu, viewForPageAt index: Int) -> UIView {
        let page = Super7PlayerListView()
        page.rootView = self
        page.clubID = index == 0 ? self.match.team_1_id ?? 0 : self.match.team_2_id ?? 0
        page.leagueID = self.super7Team.league?.id ?? 0
        page.seasonID = self.super7Team.league?.seasonID ?? 0
        page.selected_player = self.match.selected_player
        page.delegate = self
        return page
    }
    
    func heightForSegmentMenu(_ pageMenu: PageMenu) -> CGFloat {
        return 46
    }
    
    func pageMenu(_ pageMenu: PageMenu, viewForSegmentAt index: Int) -> UIView {
        let widthItem = (UIScreen.SCREEN_WIDTH - 32)/2.0
        let segmentItem = SegmentItemView(frame: CGRect(x: 0, y: 0, width: widthItem, height: 23))
        segmentItem.updateItem(teams[index])
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
        guard let page = viewItem as? Super7PlayerListView else { return }
        page.initData(self.keySearch)
    }
    
    func pageReloadData(_ pageMenu: PageMenu, _ pageIndex: Int, _ pages: [UIView]) {
        
    }
    
    /* Menu Width Segment Type */
    func menuHeaderWidthType(_ pageMenu: PageMenu) -> Int {
        return MenuHeaderWidthType.equal.rawValue
    }
    
    /* Menu Indicator Segment Type */
    func indicatorSegmentType(_ pageMenu: PageMenu) -> Int {
        return MenuHeaderIndicatorType.average.rawValue
    }
}
