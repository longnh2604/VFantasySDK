//
//  NewGlobalWeekScoreController.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class NewGlobalWeekScoreController: UIViewController {

    @IBOutlet weak var navigationBar: GlobaNavigationBar!
    @IBOutlet weak var pageMenu: PageMenu!

    var teamId: Int = 0
    var leagueId: Int = 0
    var currentGW: Int = 0
    
    private var gameweeks: [GameWeek] = []
    private var presenter = NewGlobalPresenter(service: GlobalServices())
    
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
        self.setupPresenter()
        self.getAllGameweek()
    }
    
    func initHeaderBar() {
        navigationBar.headerTitle = "Week Score".localiz().uppercased()
        navigationBar.delegate = self
    }
    
    private func initPageMenu() {
        self.pageMenu.delegate = self
        self.pageMenu.dataSource = self
        if let index = self.gameweeks.firstIndex(where: { return $0.id == self.currentGW }) {
            self.pageMenu.reloadPageMenu(index)
        } else {
            self.pageMenu.reloadPageMenu(0)
        }
    }
    
    private func setupPresenter() {
        presenter.attachView(view: self)
        presenter.teamId = teamId
    }
    
    private func getAllGameweek() {
        self.presenter.getListGameweekForTeamID { (data) in
            if !data.isEmpty {
                self.gameweeks.removeAll()
                self.gameweeks = data
                self.initPageMenu()
            }
        }
    }
}

extension NewGlobalWeekScoreController: GlobaNavigationBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationBar) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - PageMenuDelegate, PageMenuDatasource
extension NewGlobalWeekScoreController: PageMenuDelegate, PageMenuDatasource {
    func numbersPage(in pageMenu: PageMenu) -> Int {
        return gameweeks.count
    }
    
    func pageMenu(_ pageMenu: PageMenu, viewForPageAt index: Int) -> UIView {
        let page = GlobalWeekScoreListView()
        page.rootView = self
        page.gameweek = self.gameweeks[index]
        page.teamId = self.teamId
        page.leagueId = self.leagueId
        return page
    }
    
    func heightForSegmentMenu(_ pageMenu: PageMenu) -> CGFloat {
        return 46
    }
    
    func pageMenu(_ pageMenu: PageMenu, viewForSegmentAt index: Int) -> UIView {
        let segmentItem = SegmentItemView(frame: CGRect(x: 0, y: 0, width: 300, height: 23))
        segmentItem.updateItem("GW\(self.gameweeks[index].round ?? 0)")
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
        guard let page = viewItem as? GlobalWeekScoreListView else { return }
        page.initData()
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

//MARK: - Presenter
extension NewGlobalWeekScoreController: NewGlobalView {
    func reloadTeamOTWeek(_ players: [Player]) {
        
    }
    
    func reloadStatsPlayers(_ type: PlayerStatsType, _ data: [Player]) {
    }
    
    func reloadHeader(_ isCompleted: Bool) {
        
    }
    
    func reloadPitchTeam() {
        
    }
    
    func reloadBankPlayers() {
        
    }
    
    func gotoFollowPlayDay() {
        
    }
    
    func startLoading() {
        startAnimation()
    }
    
    func finishLoading() {
        stopAnimation()
        
    }
    
    func alertMessage(_ message: String) {
        stopAnimation()
        showAlert(message: message)
    }
}

extension NewGlobalWeekScoreController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
