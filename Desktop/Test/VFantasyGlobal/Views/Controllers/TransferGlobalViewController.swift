//
//  TransferGlobalViewController.swift
//  PAN689
//
//  Created by Quang Tran on 12/28/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class TransferGlobalViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var navigationBar: CustomNavigationBar!
    @IBOutlet weak var setupTimeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var transferLeftTitleLabel: UILabel!
    @IBOutlet weak var transferLeftValueLabel: UILabel!
    @IBOutlet weak var completeButton: CustomButton!

    var presenter = TransferGlobalPresenter()

    fileprivate var transferPlayerListVC: TransferPlayerListViewController!

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "transfer".localiz().uppercased()
        transferLeftTitleLabel.text = "transfer_global_left".localiz().uppercased()
        completeButton.setTitle("complete_team".localiz().uppercased(), for: .normal)
        enableCompleteTeam()
        initDataMyTeam()
        presenter.attachView(view: self)
        addLineupViewController()
    }
    
    func initDataMyTeam() {
        navigationBar.delegate = self
        navigationBar.teamName.text = presenter.myTeam?.name
        navigationBar.avatarIcon.setPlayerAvatar(with: presenter.myTeam?.logo)
    }
    
    // MARK: - Init
    
    private func addLineupViewController() {
        transferPlayerListVC = instantiateViewController(storyboardName: .transferGlobal, withIdentifier: "TransferPlayerListViewController") as? TransferPlayerListViewController
        transferPlayerListVC.presenter = presenter
        transferPlayerListVC.delegate = self
        transferPlayerListVC.addObservers()
        addChild(transferPlayerListVC)
        transferPlayerListVC.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        containerView.addSubview(transferPlayerListVC.view)
        transferPlayerListVC.didMove(toParent: self)
        containerView.bringSubviewToFront(transferPlayerListVC.view)
    }
    
    // MARK: - ConfigsUI
    
    private func updateHeader() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.kyyyyMMdd_hhmmss
        guard let date = dateFormatter.date(from: presenter.transferGlobalModel.timeDeadline) else { return }
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        let stringDate = dateFormatter.string(from: date)
        setupTimeLabel.text = stringDate
        
        timeTitleLabel.text = String(format: "gameweek_deadline".localiz().uppercased(), presenter.nextGameWeek.round ?? 0)
        
        transferLeftValueLabel.text = String(presenter.transferLeft)
    }
    
    // MARK: - Actions
    
    @IBAction func resetTransferTapped(_ sender: Any) {
        presenter.fromListPlayerId = []
        presenter.toListPlayerId = []
        transferPlayerListVC.presenter.getTransferPlayerList()
    }
  
    @IBAction func onCompleted(_ sender: Any) {
      if presenter.transferStatus && presenter.transferLeft == 0 {
        return
      }
      let message = presenter.getMessageValidateForTransfer()
      guard message.isEmpty else {
          alertWithOkHavingTitle("transfer".localiz(), message.localiz())
          return
      }
      presenter.setPlayerListFromTo()
      presenter.handleTransfer()
    }
  
  func disableCompleteTeam() {
      completeButton.shadowLayer?.isHidden = true
      completeButton.setBackgroundImage(nil, for: .normal)
      completeButton.backgroundColor = .gray
      completeButton.isUserInteractionEnabled = false
  }
  
  func enableCompleteTeam() {
      completeButton.shadowLayer?.isHidden = false
      completeButton.setBackgroundImage(VFantasyCommon.image(named: "ic_bg_button.png"), for: .normal)
      completeButton.backgroundColor = .clear
      completeButton.isUserInteractionEnabled = true
  }
}

// MARK: - CustomNavigationBarDelegate

extension TransferGlobalViewController: CustomNavigationBarDelegate {
    
    func onBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - TransferPlayerListViewControllerDelegate

extension TransferGlobalViewController: TransferPlayerListViewControllerDelegate {
    
    func showPlayerList(position: PlayerPositionType, index: Int) {
        guard let playerList = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerListViewController") as? PlayerListViewController else { return }
        playerList.initBackView(title: "transfering_player".localiz())
        playerList.setupPlayerRemoves(presenter.playerRemoves)
        playerList.setPlayerListType(.playerPool)
        playerList.setBudgetTeam(presenter.playerLineupInfo.budget ?? 0)
        playerList.setSelectedPlayers(presenter.playerLineupInfo.players)
        playerList.setPosition(position)
        playerList.setCurrentIndex(index + 1)
        playerList.setTeamId(presenter.teamID)
        playerList.setMyTeam(presenter.myTeam)
        self.navigationController?.pushViewController(playerList, animated: true)
    }
    
  func resetTransfer() {
    self.resetTransferTapped(self)
  }
  
  func completeTransfer() {
    
  }
  
    
}

// MARK: - TransferGlobalView

extension TransferGlobalViewController: TransferGlobalView {
  func alert(_ message: String) {
    alertWithOkHavingTitle("remove_player_title".localiz(), message)
  }
  
    func reloadLineup() {
        transferPlayerListVC.reloadData()
    }
    
    func updateBudget() {
        transferPlayerListVC.reloadBudget()
    }
    
    func completedTransfer(_ status: Bool, _ message: String) {
      if status {
        presenter.fromListPlayerId = []
        presenter.toListPlayerId = []
        transferPlayerListVC.presenter.getTransferPlayerList()
      }
      alertWithOkHavingTitle("transfer", message.localiz()) {
      //            self.navigationController?.popViewController(animated: true)
      }
    }
    
    func reloadView() {
        transferPlayerListVC.reloadData()
        self.updateHeader()
        self.finishLoading()
    }
    
    // MARK: Process loading
    
    func startLoading() {
        self.startAnimation()
    }
    
    func finishLoading() {
        self.stopAnimation()
    }
    
    func alertMessage(_ message: String) {
        self.stopAnimation()
        self.showAlert(message: message)
    }
}
