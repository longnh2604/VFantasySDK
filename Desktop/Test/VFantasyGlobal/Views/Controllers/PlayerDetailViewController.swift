//
//  PlayerDetailViewController.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

class PlayerDetailViewController: UIViewController {
    
    @IBOutlet weak var tbView: UITableView!
    
    fileprivate var presenter = PlayerDetailPresenter(service: PlayerDetailService())
    var fromView: FromViewController = .PlayerList
    
    weak var delegate: PlayerDetailViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter.playerListType == .playerPool {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        
        // Do any additional setup after loading the view.
        configureTableView()
        initPresenter()
        initData()
    }
    
    func configureTableView() {
        tbView.estimatedRowHeight = 100
        tbView.rowHeight = UITableView.automaticDimension
    }
    
    func initPresenter() {
        presenter.attackView(view: self)
    }
    
    func initData() {
        presenter.initData()
    }
    
    func setupMyTeam(_ myTeam: MyTeamData?) {
        presenter.myTeam = myTeam
    }
    
    func setupIsTransferGlobal(_ isTransfer: Bool) {
        presenter.isTransferGlobal = isTransfer
    }
    
    func setupIsPlayerStatsGlobal(_ isStatsGlobal: Bool) {
        presenter.isPlayerStatsGlobal = isStatsGlobal
    }
    
    func setFromView(_ fromView: FromViewController) {
        self.fromView = fromView
    }
    
    func setupPlayer(_ playerId: Int?, _ canPick: Bool = false) {
        presenter.playerModel.playerId = playerId
        presenter.canPick = canPick
    }
    
    func setPickingPlayer(_ player: Player) {
        presenter.pickingPlayer = player
    }
    
    func setupTeamId(_ teamId: Int?) {
        presenter.playerModel.teamId = teamId
    }
    
    func setupTypePlayerStatistic(_ type: PlayerDetailType) {
        presenter.playerType = type
    }
    
    func setGameplay(_ gameplay: GamePlay) {
        presenter.gameplay = gameplay
    }
    
    func setPlayerListType(_ value: PlayerListType) {
        presenter.playerListType = value
    }
}

extension PlayerDetailViewController: PlayerDetailView {
    func showHelper() {
        alertWithOk("player_detail_helper".localiz())
    }
    
    func onPick() {
        if let player = presenter.pickingPlayer {
            delegate?.onPick(player)
            navigationController?.popViewController(animated: true)
        } else {
            if let id = presenter.playerModel.playerId {
                delegate?.onPick(id)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func reloadView() {
        self.tbView.reloadData()
    }
    
    func startLoading() {
        self.startAnimation()
    }
    
    func finishLoading() {
        self.stopAnimation()
    }
    
    func alertMessage(_ message: String) {
        self.showAlert(message: message)
    }
    
    func reloadWeekView(_ data: [CheckBoxData]) {
        //        presenter.checkboxes = data
        presenter.updateChekboxData(data)
        
        self.tbView.reloadData()
    }
}

extension PlayerDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == PlayerDetailSection.Transfer.rawValue {
            return 0
        }
        if self.presenter.playerModel.keyFilter == PlayerFilterKey.points_per_round {
            return 44
        } else {
            return 0
        }
    }
}

extension PlayerDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == PlayerDetailSection.Transfer.rawValue {
            return 1
        }
        
        if self.presenter.playerModel.keyFilter == PlayerFilterKey.points_per_round {
            return self.presenter.statistics.count
        }else{
            return self.presenter.statisticsTeam.count + (presenter.isFilterGW ? 1 : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == PlayerDetailSection.Transfer.rawValue {
            return nil
        }
        
        let header = CustomHeaderPlayerDetail.instanceFromNib() as! CustomHeaderPlayerDetail
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == PlayerDetailSection.Transfer.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellPlayerDetailInfo", for: indexPath) as! CustomCellPlayerDetailInfo
            cell.playerListType = presenter.playerListType
            cell.reloadView(presenter.playerDetail)
            cell.myTeam = presenter.myTeam
            cell.dropdownData(presenter.checkboxes)
            if presenter.playerListType == .playerPool {
                if let selected = presenter.selectedData {
                    cell.dropdownView.updateSelection(selected.key ?? "")
                } else if let myTeam = presenter.myTeam {
                    let selectedFirst = CheckBoxData(String(myTeam.currentGW?.id ?? 0),
                                                     String(myTeam.currentGW?.round ?? 0),
                                                     myTeam.currentGW?.title ?? "")
                    cell.dropdownView.updateSelection(selectedFirst.key ?? "")
                    presenter.firstData = selectedFirst
                }
            }
            
            if presenter.gameplay == .Draft {
                cell.hidePlayerValue()
            }
            cell.delegate = self.presenter
            
            if fromView == .TeamPlayerList {
                if presenter.canPick {
                    cell.updateMenuButton(presenter.pickingPlayer?.isSelected)
                } else {
                    cell.menuButton.isHidden = true
                }
            } else {
                cell.menuButton.isHidden = true
            }
            
            if presenter.playerType == .statistic {
                cell.infoButton.isHidden = true
            }
            
            return cell
        } else {
            if self.presenter.playerModel.keyFilter == PlayerFilterKey.points_per_round {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellPlayDetailRound", for: indexPath) as! CustomCellPlayDetailRound
                let model = presenter.statistics[indexPath.row]
                cell.reloadView(model, indexPath)
                return cell
            } else {
                if indexPath.row == 0 && presenter.isFilterGW {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellTotalPointsGW", for: indexPath) as! CustomCellTotalPointsGW
                    cell.update(presenter.totalPoints)
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellPlayerDetailValue", for: indexPath) as! CustomCellPlayerDetailValue
                let model = presenter.statisticsTeam[presenter.isFilterGW ? indexPath.row - 1 : indexPath.row]
                cell.reloadView(model)
                return cell
            }
        }
    }
}
