//
//  GlobalRankingListView.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol GlobalPlayerListViewDelegate {
    func onLoadMore(_ sender: GlobalPlayerListView)
    func onAdded(_ player: Player)
    func onDetail(_ player: Player)
    func toggleSort()
    func changedSort(_ sender: GlobalPlayerListView, _ order: OrderProperty, _ sort: SortType)
}

class GlobalPlayerListView: UIView {
    
    @IBOutlet weak var tbvList: UITableView!
    @IBOutlet weak var lblTotalPlayers: UILabel!
    @IBOutlet weak var transferLeftView: UIView!
    @IBOutlet weak var lblSortByPoint: UILabel!
    @IBOutlet weak var lblSortByPrice: UILabel!
    @IBOutlet weak var ivSortByPoint: UIImageView!
    @IBOutlet weak var ivSortByPrice: UIImageView!
    
    @IBOutlet weak var bankView: UIView!
    @IBOutlet weak var lblBank: UILabel!
    @IBOutlet weak var ivSort: UIImageView!
    
    var delegate: GlobalPlayerListViewDelegate?
    var rootView: UIViewController!
    var type: PlayerPositionType = .all
    var players: [Player] = []
    var sortType: SortType = .desc {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.ivSort.transform = self.sortType == .desc ? .identity : CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                self.ivSortByPoint.transform = self.sortType == .desc ? .identity : CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                self.ivSortByPrice.transform = self.sortType == .desc ? .identity : CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }
        }
    }
    var orderBy: OrderProperty = .value {
        didSet {
            self.ivSortByPrice.isHidden = orderBy != .value
            self.ivSortByPoint.isHidden = orderBy != .point
            let color = UIColor(hex: 0xF87221)
            self.lblSortByPoint.textColor = orderBy == .point ? color : .white
            self.lblSortByPrice.textColor = orderBy == .value ? color : .white
        }
    }
    
    var myTeam: MyTeamData?
    var presenter: GlobalCreateTeamInfoPresenter?
    var fixedPosition = PlayerPositionType.all
    var pickingIndex = 0
    var seasonId: Int = 0
    var currentCheckClub:[FilterData]?
    
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
        self.orderBy = .value
        self.tbvList.register(UINib(nibName: GlobalPlayerNewCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: GlobalPlayerNewCell.identifierCell)
    }
    
    func updateData(_ players: [Player]) {
        self.transferLeftView.isHidden = false
        self.players = players
        self.tbvList.reloadData()
    }
    
    func updateBankView(_ value: Double?, _ type: SortType) {
        self.sortType = type
        self.bankView.isHidden = false
        self.updateContent(in: self.lblBank, "bank".localiz().upperFirstCharacter(), "€\(VFantasyCommon.budgetDisplay(value))")
        if VFantasyManager.shared.isVietnamese() {
            self.updateContent(in: self.lblBank, "bank".localiz().upperFirstCharacter(), "\(VFantasyCommon.budgetDisplay(value))")
        }
    }
    
    private func updateContent(in label: UILabel, _ title: String, _ value: String) {
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xD2D3D7), NSAttributedString.Key.font: UIFont(name: FontName.regular, size: 14) as Any]
        let suffixAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: FontName.bold, size: 16) as Any]
        let attributedString = NSMutableAttributedString(string: "\(title)", attributes: attributes)
        attributedString.append(NSAttributedString(string: " \(value)", attributes: suffixAttributes))
        label.attributedText = attributedString
    }
    
    @IBAction func onSort(_ sender: Any) {
        let type = VFantasyCommon.changeSorting(self.sortType)
        self.sortType = type
        self.delegate?.toggleSort()
    }
    
    @IBAction func onSortByPrice(_ sender: Any) {
        if self.orderBy == .value {
            //Change desc
            let type = VFantasyCommon.changeSorting(self.sortType)
            self.sortType = type
        } else {
            self.orderBy = .value
        }
        self.delegate?.changedSort(self, self.orderBy, self.sortType)
    }
    
    @IBAction func onSortByPoint(_ sender: Any) {
        if self.orderBy == .point {
            //Change desc
            let type = VFantasyCommon.changeSorting(self.sortType)
            self.sortType = type
        } else {
            self.orderBy = .point
        }
        self.delegate?.changedSort(self, self.orderBy, self.sortType)
    }
}

extension GlobalPlayerListView: GlobalPlayerNewCellDelegate {
    func onAction(sender: GlobalPlayerNewCell, _ player: Player) {
        self.delegate?.onAdded(player)
    }
}

extension GlobalPlayerListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let presenter = self.presenter {
            return presenter.playerListInfo.players.count
        }
        return self.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GlobalPlayerNewCell.identifierCell) as? GlobalPlayerNewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        
        if let presenter = self.presenter {
            cell.delegate = self
            cell.contentToBottomLayout.constant = indexPath.row == 9 - 1 ? 0.0 : 1.0
            if indexPath.row == 0 {
                cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.topLeft, .topRight], 16.0)
            } else if indexPath.row == presenter.playerListInfo.players.count - 1 {
                cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.bottomLeft, .bottomRight], 16.0)
            } else {
                cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, .allCorners, 0.0)
            }
            let info = presenter.playerListInfo
            let player = info.players[indexPath.row]
            cell.updateData(player)
            cell.lblValue.text = "€\(VFantasyCommon.budgetDisplay(player.transferValue))"
            if VFantasyManager.shared.isVietnamese() {
                cell.lblValue.text = "\(VFantasyCommon.budgetDisplay(player.transferValue))"
            }
            
            cell.btnAdd.isHidden = false
            if player.isSelected != true {
                if (!presenter.isAllowPickPlayer(player: player) || !presenter.isAllowPickClup(realClupID: player.realClubID ?? -1)) {
                    cell.btnAdd.isHidden = true
                } else {
                    cell.btnAdd.setImage(VFantasyCommon.image(named: "global_ic_add_transfer"), for: .normal)
                    cell.btnAdd.isUserInteractionEnabled = true
                }
            } else {
                cell.btnAdd.isUserInteractionEnabled = true
                cell.btnAdd.setImage(VFantasyCommon.image(named: "ic_lineup_player_added"), for: .normal)
            }
            
            cell.delegate = self
            
            if indexPath.row == info.players.count - 1 {
                presenter.morePlayers()
            }
        } else {
            cell.delegate = self
            cell.contentToBottomLayout.constant = indexPath.row == 9 - 1 ? 0.0 : 1.0
            if indexPath.row == 0 {
                cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.topLeft, .topRight], 16.0)
            } else if indexPath.row == self.players.count - 1 {
                cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.bottomLeft, .bottomRight], 16.0)
            } else {
                cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, .allCorners, 0.0)
            }
            cell.updateData(players[indexPath.row])
        }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
}

extension GlobalPlayerListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GlobalPlayerNewCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let presenter = self.presenter {
            self.delegate?.onDetail(presenter.playerListInfo.players[indexPath.row])
            return
        }
        self.delegate?.onDetail(players[indexPath.row])
    }
}

extension GlobalPlayerListView: GlobalCreateTeamInfoView {
    func updateGameWeek(gameWeek: GameWeekInfo) {
    }
    
    func reloadLineup() {
    }
    
    func updateCompletedButton() {
    }
    
    func completeLineup() {
    }
    
    func updatePlayerInfo() {
    }
    
    func updateBudget() {
    }
    
    func onChangedSort() {
    }
    
    func reloadView(_ index: Int) {
        self.tbvList.reloadData()
    }
    
    func didSelectPageControl(_ pos: Int) {
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

extension GlobalPlayerListView: UIScrollViewDelegate {
    @objc func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if yVelocity < 0 {
            // UP
            if (offset - maxOffset) >= 10.0 {
                self.delegate?.onLoadMore(self)
            }
        }else if yVelocity > 0 {
            // DOWN
        }else{
            // UN Define
        }
    }
}
