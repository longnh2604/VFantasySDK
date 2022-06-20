//
//  TransferPlayerListViewController.swift
//  PAN689
//
//  Created by Quang Tran on 12/28/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

protocol TransferPlayerListViewControllerDelegate: NSObjectProtocol {
    func showPlayerList(position: PlayerPositionType, index: Int)
    func completeTransfer()
    func resetTransfer()
}

class TransferPlayerListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var presenter: TransferGlobalPresenter!
    weak var delegate: TransferPlayerListViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.getTransferPlayerList()
        initTableView()
    }
    
    func addObservers() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(openPlayerList), name: NotificationName.pickPlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removePlayer), name: NotificationName.removePlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addPlayer), name: NotificationName.addPlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openPlayerDetail), name: NotificationName.showPlayerDetail, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        let nib = UINib(nibName: "CompleteCreateTeamCell", bundle: Bundle.sdkBundler())
        tableView.register(nib, forCellReuseIdentifier: "CompleteCreateTeamCell")
        tableView.reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    // MARK: - Notification
    
    @objc func openPlayerList(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let position = userInfo[NotificationKey.position] as? PlayerPositionType,
            let index = userInfo[NotificationKey.index] as? Int {
            
            //show player list in CreateTeamInfoViewController
            delegate?.showPlayerList(position: position, index: index)
        }
    }
    
    @objc func removePlayer(_ notification: Notification) {
//        guard presenter.transferLeft > 0 else {
//            alertWithOkHavingTitle("remove_player_title".localiz(), "having_no_transfer_left".localiz())
//            return
//        }
        
        guard let userInfo = notification.userInfo else { return }
        
        if let player = userInfo[NotificationKey.player] as? Player {
          
          self.presenter.removePlayer(player)
          self.tableView.reloadData()
        }
    }
    
    @objc func addPlayer(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if var player = userInfo[NotificationKey.player] as? Player,
            let index = userInfo[NotificationKey.index] as? Int {
            player.order = index
            player.isAddNew = true
            self.presenter.addPlayer(player)
            self.tableView.reloadData()
        }
    }
    
    @objc func openPlayerDetail(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let player = userInfo[NotificationKey.player] as? Player {
            if let id = player.id {
                if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                    controller.setupPlayer(id)
                    controller.initBackView(title: "transfering_player".localiz())
                    controller.setPlayerListType(.playerPool)
                    controller.setupTeamId(presenter.teamID)
//                    controller.setupMyTeam(presenter.myTeam)
                    controller.setupTypePlayerStatistic(.statistic)
                    controller.setupIsTransferGlobal(true)
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    func reloadBudget() {
        reloadTableView()
    }
    
    func reloadCompleteButton() {
        reloadTableView()
    }
    
    private func reloadTableView() {
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
}

extension TransferPlayerListViewController: PositionContainerCellDelegate {
  func onResetTransfer(_ sender: PositionContainerCell) {
    self.delegate?.resetTransfer()
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension TransferPlayerListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PositionContainerCell") as! PositionContainerCell
            if let statistic = presenter.playerLineupInfo.statistic {
                cell.reloadData(statistic)
            }
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransferPlayerCell") as! TransferPlayerCell
            cell.reloadView(presenter: presenter)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalConfirmLineupCell") as! GlobalConfirmLineupCell
            if let budget = presenter.playerLineupInfo.budget {
                cell.reloadView(budget, sumValue: presenter.sumValueOfPlayer)
            }
            cell.completeButton.isHidden = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        
        switch row {
        case LineupRowType.lineup.rawValue:
            return 70
        case LineupRowType.field.rawValue:
            return 414
        case LineupRowType.complete.rawValue:
            return 60
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

