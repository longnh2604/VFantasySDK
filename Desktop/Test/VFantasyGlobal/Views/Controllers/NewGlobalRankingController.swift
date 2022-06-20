//
//  NewGlobalRankingController.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class NewGlobalRankingController: UIViewController {

    @IBOutlet weak var navigationBar: GlobaNavigationBar!
    @IBOutlet weak var pageMenu: PageMenu!

    var leagueId = 0
    var currentGW = 0
    var myTeam: MyTeamData?
    var allGameweek: [GameWeek] = []
    
    private var types: [GlobalRankingType] = [.global, .country, .city, .club]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initHeaderBar()
        self.getListGameweekForTeamID()
    }
    
    func initHeaderBar() {
        navigationBar.headerTitle = "Ranking".localiz().uppercased()
        navigationBar.delegate = self
    }
    
    private func getListGameweekForTeamID() {
        self.startAnimation()
        GlobalPointsService().getGameweekList(self.myTeam?.id ?? 0, callback: { [weak self] (result, status) in
            guard let strongSelf = self else { return }
            strongSelf.stopAnimation()
            if let result = result as? GameWeekModel {
                strongSelf.allGameweek = result.response ?? []
            } else {
                strongSelf.allGameweek = []
            }
            strongSelf.initPageMenu()
        })
    }
    
    private func initPageMenu() {
        self.pageMenu.delegate = self
        self.pageMenu.dataSource = self
        self.pageMenu.reloadPageMenu(0)
    }
}

extension NewGlobalRankingController: GlobaNavigationBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationBar) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - PageMenuDelegate, PageMenuDatasource
extension NewGlobalRankingController: PageMenuDelegate, PageMenuDatasource {
    func numbersPage(in pageMenu: PageMenu) -> Int {
        return types.count
    }
    
    func pageMenu(_ pageMenu: PageMenu, viewForPageAt index: Int) -> UIView {
        let page = GlobalRankingListView()
        page.rootView = self
        page.leagueId = self.myTeam?.league?.id ?? 0
        page.myTeam = self.myTeam
        page.type = types[index]
        page.gameweeks = self.allGameweek
        return page
    }
    
    func heightForSegmentMenu(_ pageMenu: PageMenu) -> CGFloat {
        return 46
    }
    
    func pageMenu(_ pageMenu: PageMenu, viewForSegmentAt index: Int) -> UIView {
        let widthItem = (UIScreen.SCREEN_WIDTH - 32)/4.0
        let segmentItem = SegmentItemView(frame: CGRect(x: 0, y: 0, width: widthItem, height: 23))
        segmentItem.updateItem(types[index].title)
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
        guard let page = viewItem as? GlobalRankingListView else { return }
        page.initData()
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

extension NewGlobalRankingController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
