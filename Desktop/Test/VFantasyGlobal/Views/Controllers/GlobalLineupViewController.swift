//
//  LineupViewController.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/11/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

//enum LineupRowType: Int {
//    case lineup = 0, field, complete
//}

protocol GlobalLineupViewControllerDelegate: NSObjectProtocol {
    func showPlayerList(position: PlayerPositionType, index: Int)
}

class GlobalLineupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var myTeam: MyTeamData?
    var presenter: GlobalCreateTeamInfoPresenter!
    weak var delegate: GlobalLineupViewControllerDelegate?
    var gameplay = GamePlay.Transfer
    var sections: [LineupRowType] = [.field]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.getLineup()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        
        //presenter.getLineup()
    }
    func addObservers() {
        //receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(openPlayerList), name: NotificationName.pickPlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openPlayerDetail), name: NotificationName.showPlayerDetail, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removePlayer), name: NotificationName.removePlayer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: NotificationName.updateField, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NotificationName.updateStatistic, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        presenter.detachView()
    }
    
    @objc private func updateData(_ notification: Notification) {
        presenter.getLineup()
        tableView.reloadData()
    }
    @objc private func updateView(_ notification: Notification) {
        tableView.reloadData()
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
    
    @objc func openPlayerDetail(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            //No player object is passed, it means surpassed setup time and current cell is not a player
            //-> Show message
            showAlert(message: "cant_pick_after_setup_time".localiz())
            return
        }
        
        if let player = userInfo[NotificationKey.player] as? Player {
            if let id = player.id {
                if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                    controller.setupPlayer(id)
                    controller.setupTypePlayerStatistic(.statistic)
                    controller.initBackView(title: "lineup".localiz())
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    @objc func removePlayer(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let player = userInfo[NotificationKey.player] as? Player {
            alertWithTwoOptions("remove_player_title".localiz(), "alert_remove_player_from_lineup".localiz()) {
                self.presenter.removePlayer(player)
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
    
    @IBAction func onAutoPick(_ sender: Any) {
        self.presenter.autoPickPlayers()
    }
    
    @IBAction func onRemoveAutoPick(_ sender: Any) {
        self.presenter.removeAutoPickPlayers()
    }
}

extension GlobalLineupViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.row]
        switch section {
        case .lineup:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PositionContainerCell") as! PositionContainerCell
            if let statistic = presenter.playerLineupInfo.statistic {
                cell.reloadData(statistic)
            }
            return cell
        case .field:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalFieldPreviewCell") as! GlobalFieldPreviewCell
            cell.reloadView(presenter: presenter)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalConfirmLineupCell") as! GlobalConfirmLineupCell
            if let budget = presenter.playerLineupInfo.budget {
                cell.reloadView(budget, sumValue: presenter.sumValueOfPlayer)
            }
            if !presenter.canPickLineup {
                cell.hideCompleteButton()
            } else {
                //disable complete team button when user not select enough players
                if presenter.playerLineupInfo.fullLineup() {
                    if presenter.completedLineup {
                        cell.disableCompleteTeam()
                    } else {
                        cell.enableCompleteTeam()
                    }
                } else {
                    cell.disableCompleteTeam()
                }
            }
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.row]
        
        switch section {
        case .lineup:
            return 70
        case .field:
            let size = CGSize(width: 375, height: 588)
            return size.height*UIScreen.SCREEN_WIDTH/size.width
        case .complete:
            return 152
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension GlobalLineupViewController : GlobalConfirmLineupCellDelegate {
    func onCompleteLineup() {
        if presenter.playerLineupInfo.fullLineup() {
            alertWithTwoOptions("", "confirm_create_team".localiz()) {
                self.presenter.completeLineup()
            }
        }
    }
}
extension GlobalLineupViewController: GlobalCreateTeamInfoView {
    func didSelectPageControl(_ pos: Int) {
      
    }
    
    func onChangedSort() {
      
    }
    
    func updateBudget() {
      
    }
    
    func completeLineup() {
      
    }
  
    func updateGameWeek(gameWeek: GameWeekInfo) {
        print("Nguyennvvvvvv")
    }
    
    func reloadView(_ index: Int) {
        reloadData()
    }
    func updatePlayerInfo() {
        presenter.refreshPlayerList()
        reloadData()
    }
    func reloadLineup() {
    }
    
    func startLoading() {
        self.startAnimation()
    }
    
    func finishLoading() {
        self.stopAnimation()
    }
    
    func alertMessage(_ message: String) {
    }
}

extension GlobalLineupViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
