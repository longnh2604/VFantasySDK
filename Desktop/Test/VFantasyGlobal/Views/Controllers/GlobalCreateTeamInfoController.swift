//
//  CreateTeamInfoViewController.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/11/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit
import HMSegmentedControl

class GlobalCreateTeamInfoController: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var segmentView: HMSegmentedControl!
    @IBOutlet weak var lblDeadlineTitle: UILabel!
    @IBOutlet weak var lblDeadlineValue: UILabel!
    @IBOutlet weak var lblTeamTitle: UILabel!
    @IBOutlet weak var lblTeamValue: UILabel!
    @IBOutlet weak var lblBankTitle: UILabel!
    @IBOutlet weak var lblBankValue: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var gradientView: GradientView!

    
    var presenter = GlobalCreateTeamInfoPresenter()
    var myTeam: MyTeamData?
    
    fileprivate var lineupVC: GlobalLineupViewController!
    fileprivate var playerListVC: GlobalTeamPlayerListViewController!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.setup(.bottomLeftToTopRight, [UIColor(hex: 0xF76B1C).cgColor, UIColor(hex: 0xFAD961).cgColor])
        gradientView.layer.cornerRadius = 8.0
        gradientView.layer.masksToBounds = true
    }
    
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
        presenter.attachView(view: self)
        addLineupViewController()
        addPlayerListViewController()
        loadLineup()
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: NotificationName.updateField, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeView), name: NotificationName.changeView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGW), name: NotificationName.updateGameWeek, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completeSetup), name: NotificationName.completeSetupTeam, object: nil)
    }
    
    func initUI() {
        self.view.backgroundColor = UIColor(hex: 0x10003F)
        self.lblHeader.textColor = .white
        self.lblHeader.font = UIFont(name: FontName.blackItalic, size: 24)
        self.lblHeader.text = "Pick players".localiz().uppercased()
        
        self.lblDeadlineTitle.textColor = .white
        self.lblDeadlineTitle.font = UIFont(name: FontName.regular, size: 14)
        self.lblDeadlineValue.textColor = UIColor(hex: 0xF87221)
        self.lblDeadlineValue.font = UIFont(name: FontName.bold, size: 14)
        self.lblDeadlineTitle.text = "-"
        self.lblDeadlineValue.text = "-"
        
        self.lblTeamTitle.textColor = .white
        self.lblTeamTitle.font = UIFont(name: FontName.regular, size: 14)
        self.lblTeamTitle.text = "Team Value".localiz()
        self.lblBankTitle.textColor = .white
        self.lblBankTitle.font = UIFont(name: FontName.regular, size: 14)
        self.lblBankTitle.text = "bank".localiz().upperFirstCharacter()
        
        self.btnComplete.titleLabel?.font = UIFont(name: FontName.bold, size: 18)
        
        self.setupSegmentView()
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
    
    func setupSegmentView() {
        segmentView.backgroundColor = .clear
        segmentView.sectionTitles = ["lineup".localiz(), "player_list".localiz()]
        segmentView.type = .text
        segmentView.selectionIndicatorColor = UIColor(hex: 0xF87221)
        segmentView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocation.bottom
        let selectedAttribute = [kCTForegroundColorAttributeName: UIColor(hex: 0xF87221),
                                 kCTFontAttributeName: UIFont(name: FontName.bold, size: 14)]
        let normalAttribute = [kCTForegroundColorAttributeName: UIColor(hex: 0x787C88),
                               kCTFontAttributeName: UIFont(name: FontName.bold, size: 14)]
        segmentView.selectedTitleTextAttributes = selectedAttribute as [AnyHashable : Any]
        segmentView.titleTextAttributes = normalAttribute as [AnyHashable : Any]
        segmentView.segmentWidthStyle = .fixed
        segmentView.selectionIndicatorHeight = 2.0
        segmentView.selectionStyle = .fullWidthStripe
        segmentView.indexChangeBlock = { index in
            index == 0 ? self.showLineupViewController() : self.showPlayerListViewController()
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        backToView()
    }
    
    @IBAction func onCompleteTeam(_ sender: Any) {
        if presenter.playerLineupInfo.fullLineup() {
            alertWithTwoOptions("", "confirm_create_team".localiz()) {
                self.presenter.completeLineup()
            }
        }
    }
    
    @objc private func completeSetup(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if (userInfo[NotificationKey.completeSetupTeam] as? Bool) != nil {
                if let vcs = self.navigationController?.viewControllers {
                    for controller in vcs {
                        if let vc = controller as? NewGlobalController {
                            vc.changeTeamId(self.presenter.teamID)
                            self.navigationController?.popToViewController(vc, animated: true)
                            return
                        } else if let vc = controller as? GlobalViewController {
                            vc.isCompletedTeam = true
                            self.navigationController?.popViewController(animated: true)
                            break
                        }
                    }
                }
            }
        }
    }
    
    @objc func changeView(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let indexPath = userInfo[NotificationKey.changeView] as? IndexPath {
                switch indexPath.row {
                case 0:
                    showLineupViewController()
                    break
                case 1:
                    showPlayerListViewController()
                    break
                case 2:
                    showTeamListViewController()
                    break
                default:
                    break
                }
                playerListVC.endEditing()
                
            }
        }
    }
    
    @objc private func updateBankView() {
        let budget = presenter.playerLineupInfo.budget
        let value = presenter.sumValueOfPlayer
        self.updateContent(in: lblBankValue, "€\(VFantasyCommon.budgetDisplay(budget, suffixMillion: "", suffixThousands: ""))", (budget ?? 0) >= 1000000 ? "m" : "k")
        self.updateContent(in: lblTeamValue, "€\(VFantasyCommon.budgetDisplay(value, suffixMillion: "", suffixThousands: ""))", value >= 1000000 ? "m" : "k")
        if VFantasyManager.shared.isVietnamese() {
            self.updateContent(in: lblBankValue, "\(VFantasyCommon.budgetDisplay(budget, suffixMillion: "", suffixThousands: ""))", (budget ?? 0) >= 1000000 ? "m" : "k")
            self.updateContent(in: lblTeamValue, "\(VFantasyCommon.budgetDisplay(value, suffixMillion: "", suffixThousands: ""))", value >= 1000000 ? "m" : "k")
        }
        self.updateCompletedButton()
    }
    
    @objc private func updateView(_ notification: Notification) {
        self.updateBankView()
        self.stopAnimation()
    }
    
    @objc private func updateGW(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let nextGameWeek = userInfo[NotificationKey.updateGameWeek] as? GameWeekInfo {
            lblDeadlineTitle.text = String(format: "gw_deadline".localiz(), nextGameWeek.round)
            playerListVC.myTeam?.currentGW = GameWeek(id: nextGameWeek.id, round: nextGameWeek.round, team1Result: nil, team2Result: nil, team1: nil, team2: nil, startAt: nextGameWeek.startAt, endAt: nextGameWeek.endAt, delayStartAt: nil, delayEndAt: nil, title: nextGameWeek.title, point: nil, avgPoint: nil, maxPoint: nil, h2hName: nil, h2hShortName: nil, maxTeamId: nil, transfer_deadline: nil)
            self.myTeam?.currentGW = GameWeek(id: nextGameWeek.id, round: nextGameWeek.round, team1Result: nil, team2Result: nil, team1: nil, team2: nil, startAt: nextGameWeek.startAt, endAt: nextGameWeek.endAt, delayStartAt: nil, delayEndAt: nil, title: nextGameWeek.title, point: nil, avgPoint: nil, maxPoint: nil, h2hName: nil, h2hShortName: nil, maxTeamId: nil, transfer_deadline: nil)
            //setupTimeLabel.text = nextGameWeek.startAt
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormat.kyyyyMMdd_hhmmss
            guard let date = dateFormatter.date(from: nextGameWeek.startAt) else {
                return
            }
            dateFormatter.dateFormat = "dd/MM/yyyy - HH:mm a"
            let stringDate = dateFormatter.string(from: date.addingTimeInterval(-30*60))
            lblDeadlineValue.text = stringDate.uppercased()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let page = presenter.currentPage
        if page == 2 {
//                        pageControlView.reloadData(at: page)
            showTeamListViewController()
        }
    }
    
    func setId(leagueID: Int, teamID: Int) {
        presenter.leagueID = leagueID
        presenter.teamID = teamID
    }
    
    func canPickLineup(_ canPick: Bool) {
        presenter.canPickLineup = canPick
    }
    
    func setCurrentPage(_ page: Int) {
        presenter.currentPage = page
    }
    
    // MARK: - Init
    private func addLineupViewController() {
        lineupVC = instantiateViewController(storyboardName: .global, withIdentifier: "GlobalLineupViewController") as? GlobalLineupViewController
        lineupVC.presenter = presenter
        lineupVC.myTeam = myTeam
        lineupVC.delegate = self
        lineupVC.addObservers()
        addChild(lineupVC)
        lineupVC.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        containerView.addSubview(lineupVC.view)
        lineupVC.didMove(toParent: self)
    }
    
    private func addPlayerListViewController() {
        playerListVC = instantiateViewController(storyboardName: .global, withIdentifier: "GlobalTeamPlayerListViewController") as? GlobalTeamPlayerListViewController
        playerListVC.isPopup = false
        playerListVC.presenter = presenter
        playerListVC.myTeam = myTeam
        playerListVC.delegate = self
        addChild(playerListVC)
        playerListVC.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        containerView.addSubview(playerListVC.view)
        playerListVC.didMove(toParent: self)
    }
    
    // MARK: - Lineup
    private func loadLineup() {
        showLineupViewController()
    }
    
    private func showLineupViewController() {
        lineupVC.view.isHidden = false
        playerListVC.view.isHidden = true
        containerView.bringSubviewToFront(lineupVC.view)
    }
    
    // MARK: - Player List
    private func showPlayerListViewController() {
        lineupVC.view.isHidden = true
        playerListVC.view.isHidden = false
        self.updateBankView()
        
        view.bringSubviewToFront(playerListVC.view)
    }
    
    private func reloadPlayerList() {
        //showing player list popup
        //update popup data
        if let nav = UIApplication.getTopController() as? UINavigationController {
            if let controller = nav.topViewController as? TeamPlayerListViewController {
                controller.reloadData()
            }
        } else {
            //if not, update second tab
            playerListVC.reloadData()
        }
    }
    func backToView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    // MARK: - Team List
    private func showTeamListViewController() {
        lineupVC.view.isHidden = true
        playerListVC.view.isHidden = true
    }
}

extension GlobalCreateTeamInfoController: CustomNavigationBarDelegate {
    func onBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension GlobalCreateTeamInfoController : GlobalCreateTeamInfoView {
    func updateGameWeek(gameWeek: GameWeekInfo) {
        lblDeadlineTitle.text = String(format: "gw_deadline".localiz(), presenter.nextGameWeek.round)
        lblDeadlineValue.text = presenter.playerLineupInfo.time
    }
    
    func reloadLineup() {
        lineupVC.reloadData()
    }
    
    func updateCompletedButton() {
        //Update btn complete
        self.btnComplete.setTitle("\("complete".localiz()) (\(presenter.playerLineupInfo.players.count)/18)".uppercased(), for: .normal)
        if presenter.playerLineupInfo.fullLineup() {
            if presenter.completedLineup {
                self.btnComplete.isUserInteractionEnabled = false
            } else {
                self.btnComplete.isUserInteractionEnabled = true
            }
        } else {
            self.btnComplete.isUserInteractionEnabled = false
        }
    }
    
    func completeLineup() {
    }
    
    func updatePlayerInfo() {
        playerListVC.reloadSelectedCell()
    }
    
    func updateBudget() {
        lineupVC.reloadBudget()
    }
    
    func onChangedSort() {
        reloadPlayerList()
    }
    
    func reloadView(_ index: Int) {
        switch index {
        case 0:
            lineupVC.reloadData()
            lblDeadlineTitle.text = String(format: "gw_deadline".localiz(), presenter.nextGameWeek.round)
            lblDeadlineValue.text = presenter.playerLineupInfo.time
            self.finishLoading()
            self.updateCompletedButton()
            break
        case 1:
            reloadPlayerList()
            break
        case 2:
            //            teamListVC.reloadData()
            break
        default:
            break
        }
    }
    
    func didSelectPageControl(_ pos: Int) {
        switch pos {
        case 0:
            showLineupViewController()
            break
        case 1:
            showPlayerListViewController()
            break
        case 2:
            showTeamListViewController()
            break
        default:
            break
        }
        playerListVC.endEditing()
    }
    
    func startLoading() {
        if self.segmentView.selectedSegmentIndex == 0 {
            lineupVC.startAnimation()
        } else {
            playerListVC.startAnimation()
        }
    }
    
    func finishLoading() {
        if self.segmentView.selectedSegmentIndex == 0 {
            lineupVC.stopAnimation()
        } else {
            playerListVC.stopAnimation()
        }
    }
    
    func alertMessage(_ message: String) {
        lineupVC.stopAnimation()
        lineupVC.showAlert(message: message)
    }
}

extension GlobalCreateTeamInfoController : GlobalLineupViewControllerDelegate {
    
    func showPlayerList(position: PlayerPositionType, index: Int) {
        let controller = instantiateViewController(storyboardName: .global, withIdentifier: "NewGlobalTeamPlayerListController") as! NewGlobalTeamPlayerListController
        controller.hidesBottomBarWhenPushed = true
        controller.playerLineupInfo = self.presenter.playerLineupInfo
        controller.myTeam = self.myTeam
        controller.leagueId = presenter.leagueID
        controller.seasonId = presenter.playerLineupInfo.seasonId ?? 0
        controller.fixedPosition = position
        controller.pickingIndex = index
        controller.delegate = self
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

extension GlobalCreateTeamInfoController: GlobalTeamPlayerListViewControllerDelegate {
    func onAddPlayer(_ player: Player) {
        presenter.addPlayer(player)
    }
}

extension GlobalCreateTeamInfoController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
