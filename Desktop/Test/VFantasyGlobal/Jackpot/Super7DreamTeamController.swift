//
//  Super7DreamTeamController.swift
//  PAN689
//
//  Created by Quang Tran on 12/15/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class Super7DreamTeamController: UIViewController {

    @IBOutlet weak var navigationBar: GlobaNavigationBar!
    @IBOutlet weak var tbvList: UITableView!
    
    var presenter: Super7Presenter?
    var index: Int = 0
    var gameweeks: [GameWeek] = []
    var super7Team: MyTeamData!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        setupPresenter()
    }
    
    func initHeaderBar() {
        self.view.backgroundColor = UIColor(hex: 0x10003F)

        navigationBar.headerTitle = "dream team".localiz().uppercased()
        navigationBar.delegate = self
    }
    
    func initUI() {
        initHeaderBar()
        
        self.tbvList.register(UINib(nibName: Super7GWDreamCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: Super7GWDreamCell.identifierCell)
        self.tbvList.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    private func setupPresenter() {
        self.presenter = Super7Presenter(service: Super7Service())
        self.presenter!.attachView(view: self)
        self.presenter!.getListSuper7Gameweeks { data in
            self.gameweeks.removeAll()
            self.gameweeks = data
            self.index = data.count - 1
            self.initData(showHUD: true)
        }
    }
    
    func initData(showHUD: Bool) {
        if index > 0 {
            self.presenter?.getSuper7DreamTeams(real_round_id: self.gameweeks[index].id ?? 0, showHUD: showHUD)
            self.index -= 1
        }
    }
    
    override func loadMore() {
        if let presenter = self.presenter, !presenter.isLoading {
            self.initData(showHUD: true)
        }
    }
}

extension Super7DreamTeamController: GlobaNavigationBarDelegate {
    func onLeftOnClick(_ sender: GlobaNavigationBar) {
        self.presenter = nil
        self.navigationController?.popViewController(animated: true)
    }
}

extension Super7DreamTeamController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = self.presenter else { return 0 }
        return presenter.super7DreamTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let presenter = self.presenter else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Super7GWDreamCell.identifierCell) as? Super7GWDreamCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.dreamTeam = presenter.super7DreamTeams[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension Super7DreamTeamController: Super7GWDreamCellDelegate {
    func onDetailTeam(_ team: MyTeamData, _ gw: Int?) {
        let super7Storyboard = UIStoryboard(name: "Super7", bundle: Bundle.sdkBundler())
        let super7ViewController = (super7Storyboard.instantiateInitialViewController() as! Super7Controller)
        super7ViewController.viewedTeam = team
        super7ViewController.viewedGameweek = gw
        self.navigationController?.pushViewController(super7ViewController, animated: true)
    }
}

extension Super7DreamTeamController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = self.presenter else { return 0 }
        let dreamTeam = presenter.super7DreamTeams[indexPath.row]
        var rows = dreamTeam.players.count/2
        if dreamTeam.players.count%2 == 1 {
            rows += 1
        }
        let totalContent: CGFloat = Super7DreamPlayerCell.sizeCell.height * CGFloat(rows)
        return (rows == 0 ? 75.0 : 68.0) + totalContent
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension Super7DreamTeamController: Super7GlobalView {
    func reloadPlayerList() { }
    
    func reloadSuper7DreamTeams() {
        DispatchQueue.main.async {
            self.tbvList.reloadData()
        }
        if self.tbvList.contentSize.height < UIScreen.SCREEN_HEIGHT - 100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard let presenter = self.presenter else { return }
                if !presenter.isLoading {
                    self.initData(showHUD: false)
                }
            }
        }
    }
    
    func reloadSuper7PitchView() { }
    
    func updatedSuper7Team() { }
    
    func reloadSuper7Team() { }
    
    func reloadSuper7League() { }
    
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
