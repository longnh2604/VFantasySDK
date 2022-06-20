//
//  LineupCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/11/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

extension PlayerPositionType {
    var topTitle: String {
        switch self {
        case .attacker:
            if VFantasyManager.shared.isVietnamese() {
                return "TD"
            }
            return "ATK"
        case .defender:
            if VFantasyManager.shared.isVietnamese() {
                return "HV"
            }
            return "DEF"
        case .goalkeeper:
            if VFantasyManager.shared.isVietnamese() {
                return "TM"
            }
            return "GK"
        case .midfielder:
            if VFantasyManager.shared.isVietnamese() {
                return "TV"
            }
            return "MID"
        default:
            return ""
        }
    }
}

class GlobalLineupCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblPosition: UILabel!
    
    lazy private var positionType: PlayerPositionType = .attacker
    lazy private var players = [Player?]()
    
    //display mode
    lazy private var showValue = false
    lazy private var canPick = true //True if current time is valid time, false otherwise
    
    private var presenter: GlobalCreateTeamInfoPresenter!
    private var draftPresenter: TeamLineupDraftPresenter!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblPosition.font = UIFont(name: FontName.regular, size: 18)
        collectionView.register(UINib(nibName: "GlobalPickPlayerCell", bundle: Bundle.sdkBundler()), forCellWithReuseIdentifier: "GlobalPickPlayerCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func reloadData(_ positionType: PlayerPositionType, _ presenter: GlobalCreateTeamInfoPresenter, _ draftPresenter: TeamLineupDraftPresenter? = nil) {
        self.presenter = presenter
        self.positionType = positionType
        
        self.lblPosition.text = positionType.topTitle
        self.canPick = presenter.canPickLineup
        
        if let draftPresenter = draftPresenter {
            self.draftPresenter = draftPresenter
        }
        
        switch positionType {
        case .attacker:
            self.players = presenter.attackers
        case .midfielder:
            self.players = presenter.midfielders
        case .defender:
            self.players = presenter.defenders
        default:
            self.players = presenter.goalkeepers
        }
        collectionView.reloadData()
    }
}

extension GlobalLineupCell : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GlobalPickPlayerCell", for: indexPath) as! GlobalPickPlayerCell
        cell.reloadView(positionType, players[indexPath.row])
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }
    
    private func draftForItemAt(cell: GlobalPlayerLineupCell, _ indexPath: IndexPath) -> GlobalPlayerLineupCell {
        if let player = players[indexPath.row] {
            var hideRemoveButton = true
            
            if draftPresenter != nil, let pickingPlayer = draftPresenter.socketPickingPlayer {
                //If show picking player
                if player.id == pickingPlayer.id {
                    hideRemoveButton = false
                }
            }
            cell.reloadView(positionType, player, hideRemoveButton)
        } else {
            cell.reloadView(positionType, nil, !canPick)
        }
        
        return cell
    }
    
    private func transferForItemAt(cell: GlobalPlayerLineupCell, _ indexPath: IndexPath) -> GlobalPlayerLineupCell {
        cell.reloadView(positionType, players[indexPath.row], !canPick)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch positionType {
        case .attacker:
            return 4
        case .midfielder:
            return 6
        case .defender:
            return 6
        default:
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        if presenter.playerLineupInfo.gameplay == .Draft {
        //            selectPlayerInDraftMode(indexPath)
        //        } else {
        //            selectPlayerInTransferMode(indexPath)
        //        }
    }
    
    /// Only allows to handle with one picking player per round.
    ///
    /// - Parameter indexPath: indexPath of picking index
    private func selectPlayerInDraftMode(_ indexPath: IndexPath) {
        if !canPick {
            if let player = players[indexPath.row] {
                NotificationCenter.default.post(name: NotificationName.showPlayerDetail, object: nil, userInfo: [NotificationKey.player : player])
            } else {
                NotificationCenter.default.post(name: NotificationName.showPlayerDetail, object: nil)
            }
            return
        }
        
        //If that player is picking player, remove that player
        if draftPresenter != nil, let pickingPlayer = draftPresenter.socketPickingPlayer {
            //If tap at cell that already contains a player
            if let player = players[indexPath.row] {
                if player.id == pickingPlayer.id {
                    NotificationCenter.default.post(name: NotificationName.removePlayer, object: nil, userInfo: [NotificationKey.player : player])
                } else {
                    NotificationCenter.default.post(name: NotificationName.showPlayerDetail, object: nil, userInfo: [NotificationKey.player : player])
                }
            }
        } else {
            if let player = players[indexPath.row] {
                NotificationCenter.default.post(name: NotificationName.showPlayerDetail, object: nil, userInfo: [NotificationKey.player : player])
            } else {
                let userInfo = [NotificationKey.position : positionType,
                                NotificationKey.index : indexPath.row] as [String : Any]
                NotificationCenter.default.post(name: NotificationName.pickPlayer, object: nil, userInfo: userInfo)
            }
        }
    }
    
    /// 2 conditions:
    /// - Can pick (before setup time): If tap to a player cell -> remove player. If tap to a non-player cell -> pick player
    /// - Cannot pick: If tap to a player cell ->  show player detail. If tap to a non-player cell -> show alert message
    ///
    /// - Parameter indexPath: indexPath of picking index
    private func selectPlayerInTransferMode(_ indexPath: IndexPath) {
        let userInfo = [NotificationKey.position : positionType,
                        NotificationKey.index : indexPath.row] as [String : Any]
        if canPick {
            if let player = players[indexPath.row] {
                NotificationCenter.default.post(name: NotificationName.removePlayer, object: nil, userInfo: [NotificationKey.player : player])
            } else {
                NotificationCenter.default.post(name: NotificationName.pickPlayer, object: nil, userInfo: userInfo)
            }
        } else {
            if let player = players[indexPath.row] {
                NotificationCenter.default.post(name: NotificationName.showPlayerDetail, object: nil, userInfo: [NotificationKey.player : player])
            } else {
                NotificationCenter.default.post(name: NotificationName.showPlayerDetail, object: nil)
            }
        }
    }
}

extension GlobalLineupCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let isIphone5 = VFantasyCommon.isIphone5()
        let spacing = 5
        let itemWidth = isIphone5 ? 46 : 52
        
        let totalCellWidth = itemWidth * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = spacing * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = VFantasyCommon.isIphone5() ? 46 : 52
        
        return CGSize(width: itemWidth, height: 94)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension GlobalLineupCell: GlobalPlayerLineupCellDelegate {
    
    func removePlayer(index: Int, player: Player?) {
        if let player = player {
            NotificationCenter.default.post(name: NotificationName.removePlayer, object: nil, userInfo: [NotificationKey.player : player])
        }
    }
    
    func tappedPlayer(index: Int, player: Player?) {
        let userInfo = [NotificationKey.position : positionType,
                        NotificationKey.index : index] as [String : Any]
        if let player = player {
            NotificationCenter.default.post(name: NotificationName.showPlayerDetail, object: nil, userInfo: [NotificationKey.player : player])
        } else {
            NotificationCenter.default.post(name: NotificationName.pickPlayer, object: nil, userInfo: userInfo)
        }
    }
}
