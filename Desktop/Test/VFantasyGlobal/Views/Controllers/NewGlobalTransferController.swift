//
//  NewGlobalTransferController.swift
//  PAN689
//
//  Created by Quang Tran on 8/12/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class NewGlobalTransferController: UIViewController {
    
    @IBOutlet weak var navigationBar: GlobaNavigationSearchBar!
    @IBOutlet weak var pageMenu: PageMenu!
    @IBOutlet weak var lblDeadlineTitle: UILabel!
    @IBOutlet weak var lblDeadlineValue: UILabel!
    @IBOutlet weak var lblTeamTitle: UILabel!
    @IBOutlet weak var lblTeamValue: UILabel!
    @IBOutlet weak var lblBankTitle: UILabel!
    @IBOutlet weak var lblBankValue: UILabel!
    
    private var canLoadPlayers: Bool = false
    var myTeam: MyTeamData?
    var presenter = NewGlobalTransferPresenter(service: PlayerListService())
    var types: [PlayerPositionType] = [.all, .goalkeeper, .defender, .midfielder, .attacker]
    
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
        
        initUI()
        initHeaderBar()
        initPageMenu()
        setupPresenter()
    }
    
    func initUI() {
        self.lblDeadlineTitle.textColor = .white
        self.lblDeadlineTitle.font = UIFont(name: FontName.regular, size: 14)
        self.lblDeadlineTitle.text = "Deadline".localiz()
        self.lblDeadlineValue.textColor = UIColor(hex: 0xF87221)
        self.lblDeadlineValue.font = UIFont(name: FontName.bold, size: 14)
        self.lblDeadlineValue.text = "-"
        
        self.lblTeamTitle.textColor = .white
        self.lblTeamTitle.font = UIFont(name: FontName.regular, size: 14)
        self.lblTeamTitle.text = "Transfers left".localiz()
        self.lblBankTitle.textColor = .white
        self.lblBankTitle.font = UIFont(name: FontName.regular, size: 14)
        self.lblBankTitle.text = "bank".localiz().upperFirstCharacter()
    }
    
    private func updateContent(in label: UILabel, _ value: String, _ suffix: String? = nil) {
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: FontName.bold, size: 18) as Any]
        let suffixAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: FontName.regular, size: 12) as Any]
        let attributedString = NSMutableAttributedString(string: "\(value)", attributes: attributes)
        if let suffix = suffix, !suffix.isEmpty {
            attributedString.append(NSAttributedString(string: " \(suffix)", attributes: suffixAttributes))
        }
        label.attributedText = attributedString
    }
    
    private func updateHeaderView() {
        let value = presenter.playerLineupInfo.budget
        self.updateContent(in: lblTeamValue, "\(self.presenter.transferLeft)")
        self.updateContent(in: lblBankValue, "€\(VFantasyCommon.budgetDisplay(value, suffixMillion: "", suffixThousands: ""))", (value ?? 0) >= 1000000 ? "m" : "k")
        if VFantasyManager.shared.isVietnamese() {
            self.updateContent(in: lblBankValue, "\(VFantasyCommon.budgetDisplay(value, suffixMillion: "", suffixThousands: ""))", (value ?? 0) >= 1000000 ? "m" : "k")
        }
        self.lblDeadlineValue.text = self.presenter.deadline_time
    }
    
    func initHeaderBar() {
        navigationBar.delegate = self
    }
    
    private func initPageMenu() {
        self.pageMenu.delegate = self
        self.pageMenu.dataSource = self
    }
    
    func startGetData() {
        presenter.getCurrentSeason { (status) in
            if !status {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.canLoadPlayers = true
                self.presenter.getPlayerList()
            }
        }
    }
    
    func reloadData() {
        self.presenter.getTransferPlayerList()
    }
    
    private func setupPresenter() {
        self.presenter.attackView(view: self)
        self.presenter.teamId = self.myTeam?.id ?? 0
        self.presenter.myTeam = self.myTeam
        self.presenter.getTransferPlayerList()
    }
    
    private func updatePage(_ page: UIView) {
        if !self.canLoadPlayers {
            return
        }
        guard let page = page as? GlobalPlayerListView else { return }
        self.presenter.position = page.type
        let players = self.presenter.playerFor(position: page.type)
        if players.isEmpty {
            self.presenter.getPlayerList()
        } else {
            page.updateData(players)
        }
        page.lblTotalPlayers.text = "\(self.presenter.getTotalPlayers()) \("players".localiz())"
    }
}

extension NewGlobalTransferController: GlobaNavigationSearchBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationSearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onRightOnClick(_ sender: GlobaNavigationSearchBar) {
        self.presenter.didClickFilter()
    }
    
    func onSearch(_ sender: GlobaNavigationSearchBar, _ key: String) {
        self.presenter.searchPlayers(key)
    }
}

extension NewGlobalTransferController: GlobalPlayerListViewDelegate {
    func changedSort(_ sender: GlobalPlayerListView, _ order: OrderProperty, _ sort: SortType) {
        self.presenter.didClickSort(order, sort)
    }
    
    func toggleSort() {
        
    }
    
    func onLoadMore(_ sender: GlobalPlayerListView) {
        self.presenter.loadMorePlayerList()
    }
    
    func onDetail(_ player: Player) {
        if let id = player.id {
            if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                controller.setupPlayer(id)
                controller.initBackView(title: "transfering_player".localiz())
                controller.setPlayerListType(.playerPool)
                controller.setupTeamId(presenter.teamId)
                controller.setupTypePlayerStatistic(.statistic)
                controller.setupMyTeam(presenter.myTeam)
                controller.setupIsTransferGlobal(true)
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func onAdded(_ player: Player) {
        if self.presenter.transferLeft <= 0 {
            showAlert(message: "alert_zero_transfer".localiz())
            return
        }
        let popup = GlobalTransferSwapView(frame: self.view.bounds)
        popup.currentBudget = VFantasyCommon.budgetDisplay(self.presenter.playerLineupInfo.budget)
        popup.players = self.presenter.playerLineupInfo.players.filter({ return $0.mainPosition == player.mainPosition && ((Double($0.transferValue ?? 0) + (self.presenter.playerLineupInfo.budget ?? 0)) >= Double(player.transferValue ?? 0)) })
        popup.show(root: self.view)
        
        popup.onDetail = { player in
            self.onDetail(player)
        }
        popup.onSwap = { swapPlayer in
            let players: [Player] = self.presenter.playerLineupInfo.players.filter({ return $0.realClubID == player.realClubID })
            if players.count >= 3 && swapPlayer.realClubID != player.realClubID {
                self.showAlert(message: "You cannot pick more than 3 players from the same club.".localiz())
            } else {
                self.alertWithTwoOptions("Are you sure you want to make this transfer?".localiz(), "", okAction: "Confirm".localiz(), cancelAction: "Cancel".localiz()) {
                    popup.hide()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.presenter.transferPlayers(from: [swapPlayer], to: [player])
                    }
                } handleCancelAction: {
                    
                }
            }
        }
    }
}

// MARK: - PageMenuDelegate, PageMenuDatasource
extension NewGlobalTransferController: PageMenuDelegate, PageMenuDatasource {
    func numbersPage(in pageMenu: PageMenu) -> Int {
        return types.count
    }
    
    func pageMenu(_ pageMenu: PageMenu, viewForPageAt index: Int) -> UIView {
        let page = GlobalPlayerListView()
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

extension NewGlobalTransferController: NewGlobalTransferView {
    func completedTransfer(_ status: Bool, _ message: String) {
        alertWithOkHavingTitle("transfer", message.localiz()) {}
        if status {
            self.presenter.completedTransfer()
        }
    }
    
    func finishGetTransferData() {
        self.startGetData()
    }
    
    func updateData() {
        self.updateHeaderView()
        guard let currentPage = self.pageMenu.currentPage else { return }
        self.updatePage(currentPage)
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

extension NewGlobalTransferController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
