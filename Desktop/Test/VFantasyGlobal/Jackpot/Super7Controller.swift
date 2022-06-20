//
//  Super7Controller.swift
//  PAN689
//
//  Created by Quang Tran on 12/14/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

class Super7Controller: UIViewController {

    @IBOutlet weak var navigationBar: GlobaNavigationBar!
    @IBOutlet weak var ivBackground: UIImageView!
    @IBOutlet weak var ivMoreJackpot: UIImageView!
    @IBOutlet weak var ivMoreTeam: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var ivTeam: UIImageView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblJackpotValue: UILabel!
    @IBOutlet weak var lblGameweek: UILabel!
    @IBOutlet weak var lblDeadline: UILabel!
    @IBOutlet weak var lblSelection: UILabel!
    @IBOutlet weak var lblWeekscore: UILabel!
    @IBOutlet weak var lblTotalscore: UILabel!
    @IBOutlet weak var lblRanking: UILabel!
    @IBOutlet weak var ivMoreRanking: UIImageView!
    @IBOutlet weak var btnAuto: UIButton!
    @IBOutlet weak var btnClaim: GradientButton!
    @IBOutlet weak var tbvList: UITableView!
    
    var createPopup: Super7CreateTeamPopup?
    var isCreating: Bool = false {
        didSet {
            self.ivBackground.image = VFantasyCommon.image(named: isCreating ? "bg_super7" : "bg_main_super_7")
            self.mainView.isHidden = isCreating
            self.navigationBar.ivAvatar.isHidden = true///isCreating
            if self.isCreating {
                self.gotoCreateTeam()
                self.footerView.isHidden = true
                self.isShowClaim = false
            } else {
                createPopup?.removeFromSuperview()
                createPopup = nil
            }
        }
    }
    var isShowClaim: Bool = false {
        didSet {
            self.btnClaim.isHidden = !isShowClaim
            self.tbvList.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isShowClaim ? 70 : 10, right: 0)
        }
    }
    var viewedTeam: MyTeamData?
    var viewedGameweek: Int?
    
    var presenter = Super7Presenter(service: Super7Service())
    var isUpdatingPitchView = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isUpdatingPitchView {
            self.initData()
        }
        isUpdatingPitchView = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        setupPresenter()
    }

    func initHeaderBar() {
        self.view.backgroundColor = UIColor(hex: 0x10003F)
        self.footerView.backgroundColor = UIColor(hex: 0x10003F)

        self.ivBackground.image = VFantasyCommon.image(named: "bg_main_super_7")
        navigationBar.headerTitle = "Super 9".localiz().uppercased()
        navigationBar.hasLeftBtn = self.viewedTeam != nil
        navigationBar.delegate = self.viewedTeam != nil ? self : nil
        navigationBar.ivAvatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onEditSuper7Team))
        navigationBar.ivAvatar.addGestureRecognizer(tapGesture)
        
        self.btnClaim.action = "Claim the prize".localiz().uppercased()
        self.btnClaim.delegate = self
        self.isShowClaim = false
    }
    
    @objc func onEditSuper7Team() {
        
    }
    
    func initUI() {
        initHeaderBar()
        
        self.tbvList.register(UINib(nibName: Super7PlayerMatchCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: Super7PlayerMatchCell.identifierCell)
    }
    
    func initData() {
        if let team = self.viewedTeam {
            self.ivMoreTeam.isHidden = true
            self.ivMoreJackpot.isHidden = true
            self.ivMoreRanking.isHidden = true
            self.lblJackpotValue.text = "€\(VFantasyCommon.formatPoint(team.super7_value))"
            if VFantasyManager.shared.isVietnamese() {
                self.lblJackpotValue.text = "\(VFantasyCommon.formatPoint(team.super7_value))"
            }
            self.presenter.real_round_id = viewedGameweek
            self.presenter.getDetailSuper7Team(team.id ?? 0, viewedGameweek ?? 0)
        } else {
            self.presenter.getInfoSuper7Team()
            self.presenter.getSuper7League()
        }
    }
    
    private func setupPresenter() {
        presenter.attachView(view: self)
    }
    
    private func updateDeadlineInfo(isEndDeadline: Bool, date: Date, gameweek: Int) {
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x1E2539), NSAttributedString.Key.font: UIFont(name: FontName.bold, size: 14) as Any]
        let suffixAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xF87221), NSAttributedString.Key.font: UIFont(name: FontName.bold, size: 14) as Any]
        let attributedString = NSMutableAttributedString(string: "\(!isEndDeadline ? ("Selection deadline".localiz()) : (String(format: "You can't change anything because gameweek %d is in progress. Enjoy the match and wait for the final result!".localiz(), gameweek)))", attributes: attributes)
        if !isEndDeadline {
            let format = "EEE, dd MMM yyyy - HH:mm"
            attributedString.append(NSAttributedString(string: " \(date.toString(format) ?? "")", attributes: suffixAttributes))
        }
        lblDeadline.attributedText = attributedString
        btnAuto.isHidden = isEndDeadline
        if viewedTeam != nil {
            btnAuto.isHidden = true
        }
    }
    
    private func updateSelection(_ number: Int) {
        self.lblSelection.text = String(format: "My selections (%d/%d)".localiz(), number, self.presenter.super7PitchData?.matches.count ?? 0)
    }
    
    private func gotoCreateTeam() {
        if createPopup == nil {
            createPopup = Super7CreateTeamPopup(frame: CGRect(x: 27, y: 115, width: UIScreen.SCREEN_WIDTH - 54, height: 185))
            createPopup?.delegate = self
            createPopup?.roundCorners(.allCorners, radius: 8.0)
            createPopup?.shadowView(color: UIColor(hex: 0xE07000), size: CGSize(width: 0, height: 10), radius: 15, opacity: 1.0)
            self.view.addSubview(createPopup!)
        }
    }
    
    @IBAction func onDreamTeam(_ sender: Any) {
        if self.viewedTeam != nil { return }
        guard let team = self.presenter.super7Team else { return }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Super7DreamTeamController") as? Super7DreamTeamController else {
            return
        }
        vc.super7Team = team
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onEditTeam(_ sender: Any) {
        if self.viewedTeam != nil { return }
        self.gotoSuper7TeamScreen(true)
    }
    
    @IBAction func onSelectGW(_ sender: Any) {
        if self.viewedTeam != nil { return }
        self.presenter.getListSuper7Gameweeks { data in
            if !data.isEmpty {
                let availableGWs: [CheckBoxData] = data.map({ return CheckBoxData("\($0.id ?? 0)", "\($0.round ?? 0)", $0.title ?? "") })
                var selectedGW: CheckBoxData?
                if let gw = self.presenter.currentGW {
                    selectedGW = CheckBoxData("\(gw.id ?? 0)", "\(gw.round ?? 0)", gw.title ?? "")
                }
                self.showPopupMenu(availableGWs, selectedGW)
            }
        }
    }
    
    @IBAction func onRanking(_ sender: Any) {
        if self.viewedTeam != nil { return }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Super7RankingController") as? Super7RankingController else { return }
        vc.hidesBottomBarWhenPushed = true
        vc.leagueId = presenter.super7Team?.league?.id ?? 0
        vc.myTeam = presenter.super7Team
        vc.currentGW = presenter.currentGW?.id ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onAutoSelect(_ sender: Any) {
        if self.viewedTeam != nil { return }
        self.presenter.autoPickPlayers()
    }
    
    private func showPopupMenu(_ data: [CheckBoxData], _ selected: CheckBoxData?) {
        if let controller = UIApplication.getTopController() {
            if let vc = instantiateViewController(storyboardName: .common, withIdentifier: "CheckBoxViewController") as? CheckBoxViewController {
                vc.delegate = self
                vc.updateItems(data, selected)
                
                let formSheetController = MZFormSheetPresentationViewController(contentViewController: vc)
                formSheetController.presentationController?.contentViewSize = CGSize(width:controller.view.frame.size.width - 40, height: vc.getHeight())
                formSheetController.presentationController?.shouldCenterVertically = true
                formSheetController.presentationController?.shouldCenterHorizontally = true
                formSheetController.contentViewControllerTransitionStyle = .fade
                formSheetController.presentationController?.didTapOnBackgroundViewCompletionHandler = {location in
                    formSheetController.dismiss(animated: true, completion: nil)
                }
                formSheetController.allowDismissByPanningPresentedView = true
                formSheetController.contentViewCornerRadius = 20
                formSheetController.willPresentContentViewControllerHandler = { vc in
                    
                }
                controller.present(formSheetController, animated: true) {
                    vc.scrollToSelectedItem()
                }
            }
        }
    }
}

extension Super7Controller: GlobaNavigationBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationBar) {
        if let _ = self.viewedTeam {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - GlobalPitchViewDelegate
extension Super7Controller : CheckBoxViewControllerDelegate {
    func didClickApply(_ item: CheckBoxData) {
        let round = Int(item.key ?? "") ?? 0
        self.presenter.real_round_id = round
        self.presenter.getSuper7PitchData()
    }
}

extension Super7Controller: GradientButtonDelegate {
    func onClick(_ sender: GradientButton) {
        guard let window = UIApplication.getTopController()?.view else { return }
        let popup = Super7ClaimPrizePopup(frame: window.bounds)
        popup.rootVC = self
        popup.teamID = self.presenter.teamId
        popup.real_round_id = self.presenter.currentGW?.id ?? 0
        let basePopup = BasePopupView(frame: window.bounds, subView: popup, dataSource: popup, keyboardDataSource: popup)
        basePopup.show(root: window)
        popup.onAction = { _ in
            basePopup.hide()
        }
    }
}

extension Super7Controller: Super7CreateTeamPopupDelegate {
    func onCreateTeam() {
        self.gotoSuper7TeamScreen(false)
    }
    
    private func gotoSuper7TeamScreen(_ isEdit: Bool) {
        if self.viewedTeam != nil { return }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateSuper7TeamController") as? CreateSuper7TeamController else {
            return
        }
        vc.isEdit = isEdit
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension Super7Controller: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.matchRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Super7PlayerMatchCell.identifierCell) as? Super7PlayerMatchCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        
        cell.contentToBottomLayout.constant = indexPath.row == self.presenter.matchRows - 1 ? 0.0 : 1.0
        if indexPath.row == 0 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.topLeft, .topRight], 16.0)
        } else if indexPath.row == self.presenter.matchRows - 1 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.bottomLeft, .bottomRight], 16.0)
        } else {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, .allCorners, 0.0)
        }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        if let matches = self.presenter.super7PitchData?.matches, indexPath.row < matches.count {
            cell.configData(matches[indexPath.row], self.presenter.isEndDeadline)
        }
        
        return cell
    }
}

extension Super7Controller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Super7PlayerMatchCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.viewedTeam != nil { return }
        if presenter.isEndDeadline { return }
        guard let team = self.presenter.super7Team else { return }
        if let matches = self.presenter.super7PitchData?.matches, indexPath.row < matches.count {
            if matches[indexPath.row].isEnded { return }
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Super7SelectPlayerController") as? Super7SelectPlayerController else {
                return
            }
            vc.match = matches[indexPath.row]
            vc.super7Team = team
            vc.delegate = self
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension Super7Controller: Super7PlayerListViewDelegate {
    func onSelectedPlayer(_ player: Player, _ clubId: Int, _ matchId: Int) {
        self.isUpdatingPitchView = true
        self.presenter.updateSuper7PitchView(player, matchId)
    }
}

extension Super7Controller: Super7GlobalView {
    func reloadPlayerList() { }
    
    func reloadSuper7DreamTeams() { }
    
    func reloadSuper7PitchView() {
        DispatchQueue.main.async {
            self.updateSelection(self.presenter.selectionPlayers.count)
            let gw = self.presenter.super7PitchData?.currentGW?.round ?? 0
            self.lblGameweek.text = "\("Gameweek".localiz().upperFirstCharacter()) \(gw)"
            self.lblWeekscore.text = "\(self.presenter.super7PitchData?.currentGW?.point ?? 0)"
            self.updateDeadlineInfo(isEndDeadline: self.presenter.isEndDeadline, date: self.presenter.deadline, gameweek: gw)
            self.tbvList.reloadData()
            self.mainContentView.isHidden = false
            self.footerView.isHidden = false
            self.isShowClaim = self.presenter.super7PitchData?.canClaimThePrize ?? false
            
            let isEmptyData = self.presenter.super7PitchData == nil
            self.lblSelection.isHidden = isEmptyData
            self.lblDeadline.isHidden = isEmptyData
            if isEmptyData {
                self.btnAuto.isHidden = true
                self.isShowClaim = false
            }
        }
    }
    
    func updatedSuper7Team() { }
    
    func reloadSuper7Team() {
        self.lblTeamName.text = presenter.super7Team?.name
        self.ivTeam.setPlayerAvatar(with: presenter.super7Team?.logo ?? "")
        self.lblWeekscore.text = "\(presenter.super7Team?.currentGW?.point ?? 0)"
        self.lblTotalscore.text = "\(presenter.super7Team?.totalPoint ?? 0)"
        self.lblRanking.text = "\(presenter.super7Team?.rank ?? 0)"
        guard let _ = self.presenter.super7Team else {
            self.isCreating = true
            return
        }
        self.isCreating = false
        self.presenter.getSuper7PitchData()
    }
    
    func reloadSuper7League() {
        self.lblJackpotValue.text = "€\(VFantasyCommon.formatPoint(self.presenter.super7League?.budgetValue))"
        if VFantasyManager.shared.isVietnamese() {
            self.lblJackpotValue.text = "\(VFantasyCommon.formatPoint(self.presenter.super7League?.budgetValue))"
        }
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
