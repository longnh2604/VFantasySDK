//
//  Super7GWDreamCell.swift
//  PAN689
//
//  Created by Quang Tran on 12/15/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol Super7GWDreamCellDelegate: NSObjectProtocol {
    func onDetailTeam(_ team: MyTeamData, _ gw: Int?)
}

class Super7GWDreamCell: UITableViewCell {

    @IBOutlet weak var lblGameweek: UILabel!
    @IBOutlet weak var winerTeam: UIStackView!
    @IBOutlet weak var ivAvatarWinerTeam: UIImageView!
    @IBOutlet weak var lblWinerTeam: UILabel!
    @IBOutlet weak var clvPlayers: UICollectionView!
    @IBOutlet weak var lblEmptyData: UILabel!
    @IBOutlet weak var btnTeamDetail: UIButton!

    var players: [Player] = []
    var numberRows = 0
    var delegate: Super7GWDreamCellDelegate?
    
    var dreamTeam: Super7DreamTeam! {
        didSet {
            self.lblGameweek.text = "\("Gameweek".localiz().upperFirstCharacter()) \(dreamTeam.gameweek?.round ?? 0)"
            #if VFANTASY || VFANTASY_Dev
            self.lblGameweek.text = "Tuần thi đấu \(dreamTeam.gameweek?.round ?? 0)"
            #endif
            self.winerTeam.isHidden = false
            self.ivAvatarWinerTeam.isHidden = false
            if dreamTeam.winners.count > 1 {
                self.lblWinerTeam.text = String(format: "%d winners".localiz(), dreamTeam.winners.count)
                self.ivAvatarWinerTeam.isHidden = true
            } else if let winner = dreamTeam.winners.first {
                self.updateDataWinner(winner)
            } else {
                self.winerTeam.isHidden = true
            }
            self.players = dreamTeam.players
            self.numberRows = self.players.count%2 == 1 ? self.players.count + 1 : self.players.count
            self.lblEmptyData.isHidden = !self.players.isEmpty
            self.clvPlayers.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblEmptyData.text = "No results updated.".localiz()
        self.lblEmptyData.isHidden = true
        self.clvPlayers.register(UINib(nibName: "Super7DreamPlayerCell", bundle: Bundle.sdkBundler()), forCellWithReuseIdentifier: "Super7DreamPlayerCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func updateDataWinner(_ winner: MyTeamData) {
        lblWinerTeam.text = winner.name
        ivAvatarWinerTeam.setPlayerAvatar(with: winner.logo)
    }
    
    @IBAction func onDetailTeam(_ sender: Any) {
        if self.dreamTeam.winners.count > 1 {
            //Show popup
            guard let window = UIApplication.getTopController()?.view else { return }
            let popup = Super7WinnersPopup(frame: window.bounds)
            popup.winners = self.dreamTeam.winners
            popup.delegate = self
            let basePopup = BasePopupView(frame: window.bounds, subView: popup, dataSource: popup, keyboardDataSource: nil)
            basePopup.show(root: window)
            popup.onAction = { _ in
                basePopup.hide()
            }
        } else if let winner = dreamTeam.winners.first {
            self.delegate?.onDetailTeam(winner, dreamTeam.gameweek?.id)
        }
    }
    
    static var identifierCell: String {
        return "Super7GWDreamCell"
    }
    
    static var heightCell: CGFloat {
        return 324.0
    }
    
}

extension Super7GWDreamCell: Super7WinnersPopupDelegate {
    func onChooseTeam(_ team: MyTeamData) {
        self.delegate?.onDetailTeam(team, dreamTeam.gameweek?.id)
    }
}

extension Super7GWDreamCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Super7DreamPlayerCell", for: indexPath) as! Super7DreamPlayerCell
        let isHiddenContent = indexPath.row >= self.players.count
        cell.ivAvatar.isHidden = isHiddenContent
        cell.lblName.isHidden = isHiddenContent
        cell.lblScore.isHidden = isHiddenContent
        cell.ivStar.isHidden = isHiddenContent
        
        if indexPath.row < self.players.count {
            cell.configData(self.players[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberRows
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < self.players.count {
            if let id = self.players[indexPath.row].id {
                guard let topVC = UIApplication.getTopController() else { return }
                if let controller = instantiateViewController(storyboardName: .player, withIdentifier: "PlayerDetailViewController") as? PlayerDetailViewController {
                    controller.hidesBottomBarWhenPushed = true
                    controller.setupPlayer(id)
                    controller.initBackView(title: "Super 9".localiz())
                    controller.setPlayerListType(.playerPool)
                    controller.setupTypePlayerStatistic(.statistic)
                    controller.setupIsPlayerStatsGlobal(false)
                    topVC.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
}

extension Super7GWDreamCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Super7DreamPlayerCell.sizeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}
