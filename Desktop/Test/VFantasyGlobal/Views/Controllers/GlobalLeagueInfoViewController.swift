//
//  GlobalLeagueInfoViewController.swift
//  PAN689
//
//  Created by David Tran on 1/4/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit
import SDWebImage

typealias GetLeagueCompletion = (_ league: LeagueDatum?) -> Void

class GlobalLeagueInfoViewController: UITableViewController {
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var nameValueLabel: UILabel!
    @IBOutlet weak var codeTitleLabel: UILabel!
    @IBOutlet weak var codeValueLabel: UILabel!
    @IBOutlet weak var gameweekTitleLabel: UILabel!
    @IBOutlet weak var gameweekValueLabel: UILabel!
    @IBOutlet weak var descTitleLabel: UILabel!
    @IBOutlet weak var descValueLabel: UILabel!
    
    var leagueId: Int?
    var presenter: GlobalLeagueInfoPresenter!
    var loadCompletion: GetLeagueCompletion?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if leagueId != nil {
            presenter.detailLeague(leagueId: leagueId!)
        } else {
            setupLeagueInfo()
        }
        presenter.attachView(view: self)
        presenter.getGameweeks()
    }
    
    func setupUI() {
        nameTitleLabel.text = "name".localiz().uppercased()
        codeTitleLabel.text = "CODE".localiz()
        gameweekTitleLabel.text = "STARTING GAMEWEEK".localiz()
        descTitleLabel.text = "DESCRIPTION".localiz()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    func setupLeagueInfo() {
        nameValueLabel.text = presenter.leagueModel.name
        codeValueLabel.text = presenter.leagueModel.code
        descValueLabel.text = presenter.leagueModel.desc
        let url = URL(string: presenter.leagueModel.avatar)
        avatarImgView.sd_setImage(with: url, completed: nil)
        updateGameweek()
        self.tableView.reloadData()
    }
  
  func updateGameweek() {
    if let gameweek = presenter.gameweeks.first(where: { $0.id == presenter.leagueModel.gameweekId }) {
        gameweekValueLabel.text = "GW\(gameweek.round ?? 0)"
      } else {
        gameweekValueLabel.text = "--"
    }
  }
    
    func updateNewLeague(_ league: GlobalLeagueModelView) {
        presenter.leagueModel = league
        setupLeagueInfo()
    }
    
    @IBAction func codeValueButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = presenter.leagueModel.code
        self.showAlert(message: "Copied to clipboard".localiz())
    }
}

extension GlobalLeagueInfoViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 148.0
        } else if indexPath.row == 1 || indexPath.row == 3 {
            return 60.0
        } else if indexPath.row == 2 {
          return presenter.leagueModel.isOwner ? 60 : 0
        }
        return UITableView.automaticDimension
    }
}

extension GlobalLeagueInfoViewController: GlobalLeagueInfoView {
    
    func startLoading() {
        startAnimation()
    }
    
    func alertMessage(_ message: String) {
      stopAnimation()
//      showAlert(message: message)
    }
    
    func finishLoading() {
        stopAnimation()
    }
    
    func finishLoadingGameweeks() {
        stopAnimation()
        updateGameweek()
    }
    
    func getDetailLeague(_ league: LeagueDatum?) {
        if let completion = self.loadCompletion {
            completion(league)
        }
    }
}

extension GlobalLeagueInfoViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
