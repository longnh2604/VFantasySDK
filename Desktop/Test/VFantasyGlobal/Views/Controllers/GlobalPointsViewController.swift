//
//  GlobalPointsViewController.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

class GlobalPointsViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: CustomNavigationBar!
    @IBOutlet weak var dropdownView: DropdownSelectionView!
    @IBOutlet weak var formationView: FormationView!
    @IBOutlet weak var playersView: PlayersBottomView!
    @IBOutlet weak var lblTotalPoints: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var pointsGradient: GradientView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var lblTransfers: UILabel!
    @IBOutlet weak var lblTeamValue: UILabel!
    @IBOutlet weak var lblTitleTransfers: UILabel!
    @IBOutlet weak var lblTitleTeamValue: UILabel!
    
    private var firstSet: Bool = false
    var timer: Timer?
    var myTeam: MyTeamData?
    var presenter = GlobalPointsPresenter(service: GlobalPointsService())
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pointsGradient.setup(.bottomLeftToTopRight, [UIColor(hexString: "F76B1C").cgColor, UIColor(hexString: "FAD961").cgColor])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initDataMyTeam()
        setupPresenter()
        setupDropdownView()
    }
    
    func initUI() {
        lblPoints.text = "points".localiz().lowercased()
        lblTitleTransfers.text = "TRANSFERS".localiz().lowercased()
        lblTitleTeamValue.text = "TEAM VALUE".localiz().lowercased()
        if VFantasyManager.shared.isVietnamese() {
            lblPoints.text = "points".localiz().uppercased()
            lblTitleTransfers.text = "TRANSFERS".localiz().uppercased()
            lblTitleTeamValue.text = "TEAM VALUE".localiz().uppercased()
            lblTitleTransfers.adjustsFontSizeToFitWidth = true
            lblTitleTeamValue.adjustsFontSizeToFitWidth = true
        }
        
        formationView.isPoints = true
        playersView.isPoints = true
        playersView.detailCompletion = { player in
            self.gotoDetailPlayer(player)
        }
        leftView.addRoundShadow(0)
        centerView.addRoundShadow(0)
        rightView.addRoundShadow(0)
    }
    
    func initDataMyTeam() {
        navigationBar.delegate = self
        navigationBar.teamName.text = myTeam?.name
        navigationBar.avatarIcon.setPlayerAvatar(with: myTeam?.logo)
    }
    
    func setupPresenter() {
        presenter.teamId = myTeam?.id ?? 0
        presenter.model.realRoundId = myTeam?.currentGW?.id
        presenter.attachView(view: self)
        presenter.getListGameweek(params: ["type": "points"])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.presenter.getInfoPoints()
        }
    }
    
    func setupDropdownView() {
        dropdownView.updateStyle(.blue)
        dropdownView.delegate = self
        dropdownView.titleLabel.textAlignment = .left
    }
    
    func  startTimeline() {
        stopTimeline()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(onTik(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTimeline() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func onTik(_ sender: Any) {
        formationView.updatePlayers(presenter.data?.players ?? [], presenter.data)
        playersView.updatePlayers(presenter.data?.morePlayers ?? [], presenter.data)
    }
    
    private func updateData() {
        if let data = presenter.data {
            navigationBar.teamName.text = data.team?.name
            navigationBar.avatarIcon.setPlayerAvatar(with: data.team?.logo)
        }
    }
    
    private func gotoDetailPlayer(_ player: Player) {
        if let id = player.id {
            if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                
                controller.setupPlayer(id)
                controller.initBackView(title: "Points".localiz())
                controller.setPlayerListType(.playerPool)
                controller.setupTeamId(presenter.teamId)
                controller.setupTypePlayerStatistic(.statistic)
                myTeam?.currentGW = self.presenter.data?.currentGW
                controller.setupMyTeam(myTeam)
                
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension GlobalPointsViewController: DropdownSelectionViewDelegate {
    func didChangeSort(_ tag: Int) {
        if let selected = dropdownView.selectedData {
            dropdownView.titleLabel.text = selected.name?.uppercased()
            presenter.model.realRoundId = Int(selected.key ?? "")
            presenter.getInfoPoints()
        }
    }
    
    func didTapDropdown(_ tag: Int) {
        guard presenter.isShowPlayerDetail else { return }
        dropdownView.showCheckBox(true)
    }
}

extension GlobalPointsViewController: CustomNavigationBarDelegate {
    func onBack() {
        stopTimeline()
        self.navigationController?.popViewController(animated: true)
    }
}

extension GlobalPointsViewController: GlobalPointsView {
    func startLoading() {
        startAnimation()
    }
    
    func finishLoading() {
        stopAnimation()
    }
    
    func alertMessage(_ message: String) {
        stopAnimation()
    }
    
    
    private func hardCodeGWIfNeed() {
        if let GW = myTeam?.currentGW, !firstSet {
            firstSet = true
            dropdownView.titleLabel.text = GW.title?.uppercased()
            if dropdownView.selectedData == nil {
                dropdownView.selectedData = CheckBoxData("\(GW.id ?? 0)", "\(GW.round ?? 0)", GW.title ?? "", true)
                dropdownView.updateSelection("\(GW.id ?? 0)")
            }
        }
    }
    
    func errorGetPitchTeam() {
        hardCodeGWIfNeed()
        formationView.delegate = nil
        formationView.removeOldData()
        stopTimeline()
        playersView.updatePlayers([], nil)
        lblTransfers.text = "-"
        lblTeamValue.text = "-"
        lblTotalPoints.text = "-"
    }
    
    func reloadPitchTeam() {
        hardCodeGWIfNeed()
        updateData()
        formationView.delegate = self
        if let GW = presenter.data?.currentGW {
            
            if !firstSet {
                firstSet = true
                dropdownView.titleLabel.text = GW.title?.uppercased()
                if dropdownView.selectedData == nil {
                    dropdownView.selectedData = CheckBoxData("\(GW.id ?? 0)", "\(GW.round ?? 0)", GW.title ?? "", true)
                    dropdownView.updateSelection("\(GW.id ?? 0)")
                }
            }
            
            if let point = GW.point {
                lblTotalPoints.text = "\(point)"
            } else {
                lblTotalPoints.text = "-"
            }
        } else {
            lblTotalPoints.text = "-"
        }
        if let formation = presenter.data?.team?.formation {
            formationView.updateFormation(FormationTeam(rawValue: formation) ?? .team_442)
        } else {
            formationView.removeOldData()
        }
        startTimeline()
        formationView.updatePlayers(presenter.data?.players ?? [], presenter.data)
        playersView.updatePlayers(presenter.data?.morePlayers ?? [], presenter.data)
        if let transferLeft = presenter.data?.transferPlayerLeft {
            lblTransfers.text = "\(transferLeft)"
        } else {
            lblTransfers.text = "-"
        }
        var currentValue: Double = 0.0
        for player in presenter.data?.players ?? [] {
            currentValue += Double(player.transferValue ?? 0)
        }
        for player in presenter.data?.morePlayers ?? [] {
            currentValue += Double(player.transferValue ?? 0)
        }
        if fabs(currentValue - 0.0) > Double.ulpOfOne {
            lblTeamValue.text = "€\(VFantasyCommon.budgetDisplay(currentValue, suffixMillion: "mio_suffix".localiz()))"
        } else {
            lblTeamValue.text = "-"
        }
    }
    
    func reloadWeekView(_ data: [CheckBoxData]) {
        dropdownView.data = data
    }
}

extension GlobalPointsViewController: PlayerViewDelegate {
    func onSelectPlayer(_ sender: PlayerView) {
        guard presenter.isShowPlayerDetail else { return }
        guard let player = sender.player else { return }
        self.gotoDetailPlayer(player)
    }
}
