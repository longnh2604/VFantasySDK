//
//  ChooseSuccessorViewController.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 5/23/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol ChooseSuccessorViewControllerDelegate: NSObjectProtocol {
    func onDoneSelectedTeam(_ team: Team)
}

class ChooseSuccessorViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var presenter = ChooseSuccessorPresenter()
    fileprivate var selectedTeam: Team?
    
    weak var delegate: ChooseSuccessorViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 40
        tableView.separatorStyle = .none
        
        initUI()
        loadData()
    }
    
    fileprivate func initUI() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done) {
            if let team = self.selectedTeam {
                self.dismiss(animated: true, completion: {
                    self.delegate?.onDoneSelectedTeam(team)
                })
            }
        }
        let cancelButton = UIBarButtonItem(title: "Cancel".localiz()) {
            self.dismiss(animated: true, completion: nil)
        }
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        
        presenter.attachView(self)
    }
    
    fileprivate func loadData() {
        presenter.listSuccessor()
    }
    
    func setLeagueID(_ id: Int) {
        presenter.leagueID = String(id)
    }
    
    func setShowFromGlobalDetailLeague(_ isShow: Bool) {
        presenter.isShowFromDetailGlobalLeague = isShow
    }
}

extension ChooseSuccessorViewController  : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SuccessorTableViewCell
        cell.tickButton.imageView?.image = VFantasyCommon.image(named: "ic_successor_ticked")
        selectedTeam = presenter.successors[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SuccessorTableViewCell
        cell.tickButton.imageView?.image = VFantasyCommon.image(named: "ic_successor_untick")
    }
}

extension ChooseSuccessorViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuccessorTableViewCell") as! SuccessorTableViewCell
        
        let team = presenter.successors[indexPath.row]
        cell.teamLabel.text = team.name
        cell.ownerLabel.text = team.user?.displayName
        if presenter.isShowFromDetailGlobalLeague, let logo = team.logo {
            cell.thumbnailImage.sd_setImage(with: URL(string: logo), completed: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.successors.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ChooseSuccessorViewController : ChooseSuccessorView {
    func alertMessage(_ message: String) {
        stopAnimation()
        showAlert(message: message)
    }
    
    func reloadView() {
        tableView.reloadData()
    }
    
    func startLoading() {
        self.startAnimation()
    }
    
    func finishLoading() {
        self.stopAnimation()
    }
}

extension ChooseSuccessorViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
