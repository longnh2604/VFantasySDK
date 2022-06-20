//
//  GlobalLeagueDetailViewController.swift
//  PAN689
//
//  Created by David Tran on 1/4/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit

enum GlobalLeagueDetailType: Int {
    case info = 0, point, invite
}

class GlobalLeagueDetailViewController: UIViewController {

    @IBOutlet weak var leagueNameLabel: UILabel!
    @IBOutlet weak var pageControlView: CustomPageContol!
    @IBOutlet weak var leagueDetailContainer: UIView!
    @IBOutlet weak var inviteFriendContainer: UIView!
    @IBOutlet weak var leaguePointContainer: UIView!
    
    var leagueId: Int?
    var presenter: GlobalLeagueDetailPresenter!
    var globalLeagueInfoVC: GlobalLeagueInfoViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBackView(title: "Global league".localiz())
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.initDataControl(GlobalLeagueDetailType.point.rawValue)
        }
        presenter.attachView(view: self)
    }

    func initDataControl(_ index: Int) {
        guard let customFont = UIFont(name: FontName.blackItalic, size: FontSize.large) else {
            return
        }
        var titles = ["League information".localiz(),
                      "Points".localiz()]
        if presenter.leagueModel.isOwner {
            titles.append("Invite friends".localiz())
        }
        CurrentColor.unSelect = .lightGray
        CurrentColor.detailUnselected = #colorLiteral(red: 0.8, green: 0.8078431373, blue: 0.937254902, alpha: 1)
        pageControlView.delegate = self
        pageControlView.isLeagueDetail = true
        pageControlView.loadData(data: titles,
                                 indexPath: IndexPath(row: index, section: 0),
                                 font: customFont)
        pageControlView.setCurrentPageControl(currentPage: index)
        updateDisplay(index: index)
    }
//
    private func updateDisplay(index: Int) {
        switch index {
        case GlobalLeagueDetailType.info.rawValue:
            leagueDetailContainer.isHidden = false
            leaguePointContainer.isHidden = true
            inviteFriendContainer.isHidden = true
        case GlobalLeagueDetailType.point.rawValue:
            leagueDetailContainer.isHidden = true
            leaguePointContainer.isHidden = false
            inviteFriendContainer.isHidden = true
        case GlobalLeagueDetailType.invite.rawValue:
            leagueDetailContainer.isHidden = true
            leaguePointContainer.isHidden = true
            inviteFriendContainer.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func menuDetailTapped(_ sender: Any) {
        showActionSheet()
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: "league_detail_action".localiz(), preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "edit_action".localiz(), style: .default, handler: { [weak self] action in
            self?.gotoEditLeague()
        })
        let leaveAction = UIAlertAction(title: "leave_action".localiz(), style: .default, handler: { [weak self] action in
            self?.leaveLeagueAction()
        })
        let stopAction = UIAlertAction(title: "stop_action".localiz(), style: .destructive, handler: { [weak self] action in
            self?.stopLeagueAction()
        })
        let cancelAction = UIAlertAction(title: "Cancel".localiz(), style: .cancel, handler: nil)
        
        if presenter.leagueModel.isOwner {
            actionSheet.addAction(editAction)
        }
        actionSheet.addAction(leaveAction)
        if presenter.leagueModel.isOwner {
            actionSheet.addAction(stopAction)
        }
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func stopLeagueAction() {
        self.alertWithTwoOptions("Panna".localiz(), "All the information related to this league will be removed. Are you sure you want to delete this league?".localiz()) { [weak self] in
            self?.presenter.stopLeague(isLeave: false)
        }
    }
    
    private func leaveLeagueAction() {
        if presenter.leagueModel.isOwner {
            if presenter.leagueModel.currentNumberOfUser > 1 {
                showChooseSuccesser()
            } else {
                self.alertWithTwoOptions("Panna".localiz(), "leave_league_alert_message".localiz()) { [weak self] in
                    self?.presenter.stopLeague(isLeave: true)
                }
            }
        } else {
            presenter.leaveLeague(nil)
        }
    }
    
    func gotoEditLeague() {
        guard let vc = instantiateViewController(storyboardName: .global, withIdentifier: GlobalCreateNewLeagueViewController.className) as? GlobalCreateNewLeagueViewController else {
            return
        }
        let service = GlobalNewLeagueService()
        vc.presenter = GlobalCreateNewLeaguePresenter(service: service)
        vc.presenter.teamId = presenter.teamId
        vc.presenter.globalLeagueMode = .update
        vc.presenter.leagueModel = self.globalLeagueInfoVC?.presenter.leagueModel ?? presenter.leagueModel
        vc.hidesBottomBarWhenPushed = true
        self.present(vc, animated: true, completion: nil)
        vc.successUpdatingLeagueClosure = { [weak self] league in
            self?.globalLeagueInfoVC?.updateNewLeague(league)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGlobalLeaugeInfo" {
            let infoVC = segue.destination as? GlobalLeagueInfoViewController
            infoVC?.presenter = GlobalLeagueInfoPresenter(league: presenter.leagueModel)
            infoVC?.presenter.teamId = presenter.teamId
            infoVC?.leagueId = leagueId
            globalLeagueInfoVC = infoVC
            infoVC?.loadCompletion = { league in
                guard let league = league else {
                  self.navigationController?.popViewController(animated: true)
                  return
                }
                let leagueModel = GlobalLeagueModelView(league: league)
                self.presenter.leagueModel = leagueModel
                infoVC?.presenter.leagueModel = leagueModel
                infoVC?.setupLeagueInfo()
            }
        }
        
        if segue.identifier == "leaguePointContainerSegue" {
            let pointVC = segue.destination as? GlobalLeaguePointViewController
            pointVC?.setLeagueId(presenter.leagueId)
            pointVC?.setLeague(presenter.league)
        }
        
        if segue.identifier == "inviteFriendContainerSegue" {
            let inviteVC = segue.destination as? GlobalLeagueInviteFriendViewController
            inviteVC?.setLeagueId(presenter.leagueId)
            inviteVC?.successInviteFriendClosure = { [weak self] in
                guard let self = self else { return }
                if self.presenter.leagueModel.currentNumberOfUser <= 1 {
                    self.presenter.leagueModel.currentNumberOfUser = 2
                }
            }
        }
    }
    
    private func showChooseSuccesser() {
        guard let controller = instantiateViewController(storyboardName: .leaugeDetail, withIdentifier: ChooseSuccessorViewController.className) as? ChooseSuccessorViewController else { return }
        controller.delegate = self
        controller.setShowFromGlobalDetailLeague(true)
        controller.setLeagueID(presenter.leagueModel.id)
        let nav = UINavigationController(rootViewController: controller)
        self.present(nav, animated: true, completion: nil)
    }
}

extension GlobalLeagueDetailViewController: CustomPageControlDelegate {
    
    func currentIndex(indexPath: IndexPath) {
        updateDisplay(index: indexPath.row)
    }
}

extension GlobalLeagueDetailViewController: GlobalLeagueDetailView {
    
    func startLoading() {
        startAnimation()
    }
    
    func alertMessage(_ message: String) {
      stopAnimation()
      showAlert(message: message)
    }
    
    func finishLoading() {
        stopAnimation()
    }
    
    func finishStopLeague(isLeave: Bool) {
        stopAnimation()
        let title = isLeave ? "Leave league Successfully".localiz() : "Stop league Successfully".localiz()
        self.alertWithOk(title) { [weak self] in
            self?.popToViewController()
        }
    }
    
    func leftLeague() {
        self.alertWithOk("left_league_alert".localiz()) {
            self.popToViewController()
        }
    }
    
    func participantLeftLeague() {
        popToViewController()
    }
    
    override func popToViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GlobalLeagueDetailViewController: ChooseSuccessorViewControllerDelegate {
    func onDoneSelectedTeam(_ team: Team) {
        if let id = team.id {
            self.alertWithTwoOptions("Panna".localiz(), "leave_league_alert_message".localiz()) { [weak self] in
                self?.presenter.leaveLeague(id)
            }
        }
    }
}

extension GlobalLeagueDetailViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
