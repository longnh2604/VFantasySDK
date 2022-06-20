//
//  GlobalPitchView.swift
//  PAN689
//
//  Created by Quang Tran on 7/13/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol GlobalPitchViewDelegate {
    func gotoHomeScreen()
    func gotoTransferScreen()
    func gotoPlayerStatsScreen()
    func gotoTeamOTWeek()
    func gotoPlayDay()
    func onChangeFormation()
    func onChangeTeam()
    func onChangeGW()
}

class GlobalPitchView: UIView {
    
    @IBOutlet weak var formationView: GlobalFormationView!
    @IBOutlet weak var lblFormation: UILabel!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblGameWeek: UILabel!
    @IBOutlet weak var btnTeamOTWeek: UIButton!
    @IBOutlet weak var formationViewHeightLayout: NSLayoutConstraint!
    
    @IBOutlet weak var btnTransfer: UIButton!
    @IBOutlet weak var btnNextRound: UIButton!

    var playerDelegate: GlobalPlayerViewDelegate?
    var delegate: GlobalPitchViewDelegate?
    var currentFormation: FormationTeam = .team_442 {
        didSet {
            self.lblFormation.text = currentFormation.rawValue
        }
    }
    var isTeamOTWeek: Bool = false {
        didSet {
            self.btnTeamOTWeek.setTitleColor(isTeamOTWeek ? UIColor(hex: 0x1E2539) : .white, for: .normal)
            self.btnTeamOTWeek.backgroundColor = !isTeamOTWeek ? UIColor(white: 1.0, alpha: 0.2) : .white
        }
    }
    
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
        self.lblFormation.text = nil
        self.lblTeamName.text = nil
        self.lblGameWeek.text = nil
        let formationHeight: CGFloat = (UIScreen.SCREEN_WIDTH - 32) * 318.0/343.0
        self.formationViewHeightLayout.constant = formationHeight
        
        self.btnNextRound.setTitle("transfer".localiz(), for: .normal)
        self.btnTransfer.setTitle("Next Play Day".localiz(), for: .normal)
    }
    
    func update(data: PitchTeamData?, formation: FormationTeam) {
        self.isTeamOTWeek = false
        self.currentFormation = formation
        self.lblTeamName.text = data?.team?.name
        self.formationView.updateFormation(formation, data?.players ?? [], data, true)
        self.formationView.delegate = self.playerDelegate
    }
    
    func updateTeamOTWeek(formation: FormationTeam, _ players: [Player]) {
        self.isTeamOTWeek = true
        self.currentFormation = formation
        self.formationView.updateFormation(formation, players, nil, false)
    }
    
    @IBAction func onChangeTeam(_ sender: Any) {
        self.delegate?.onChangeTeam()
    }
    
    @IBAction func onChangeGW(_ sender: Any) {
        self.delegate?.onChangeGW()
    }
    
    @IBAction func onChangeFormation(_ sender: Any) {
        self.delegate?.onChangeFormation()
    }

    @IBAction func onClickHome(_ sender: Any) {
        self.delegate?.gotoHomeScreen()
    }
    
    @IBAction func onClickTransfer(_ sender: Any) {
        self.delegate?.gotoPlayDay()
    }
    
    @IBAction func onClickPlayerStats(_ sender: Any) {
        self.delegate?.gotoPlayerStatsScreen()
    }
    
    @IBAction func onClickTeamOT(_ sender: Any) {
        self.delegate?.gotoTeamOTWeek()
    }
    
    @IBAction func onClickPlayDay(_ sender: Any) {
        self.delegate?.gotoTransferScreen()
    }
    
}
