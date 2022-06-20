//
//  LineupTransferCell.swift
//  PAN689
//
//  Created by Quang Tran on 12/28/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class LineupTransferCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy private var positionType: PlayerPositionType = .attacker
    lazy private var players = [Player?]()
    
    private var presenter: TransferGlobalPresenter!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func reloadData(_ positionType: PlayerPositionType, _ presenter: TransferGlobalPresenter) {
        self.presenter = presenter
        self.positionType = positionType
        
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

// MARK: - DataSource, Delegate

extension LineupTransferCell : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GlobalPlayerLineupCell", for: indexPath) as! GlobalPlayerLineupCell
        cell.index = indexPath.row
        cell.delegate = self
        return transferForItemAt(cell: cell, indexPath)
    }
    
    private func transferForItemAt(cell: GlobalPlayerLineupCell, _ indexPath: IndexPath) -> GlobalPlayerLineupCell {
        cell.reloadView(positionType, players[indexPath.row], false)
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
        selectPlayerInTransferMode(indexPath)
    }
    
    /// 2 conditions:
    /// - Can pick (before setup time): If tap to a player cell -> remove player. If tap to a non-player cell -> pick player
    /// - Cannot pick: If tap to a player cell ->  show player detail. If tap to a non-player cell -> show alert message
    ///
    /// - Parameter indexPath: indexPath of picking index
    private func selectPlayerInTransferMode(_ indexPath: IndexPath) {
        let userInfo = [NotificationKey.position : positionType,
                        NotificationKey.index : indexPath.row] as [String : Any]
        if let player = players[indexPath.row] {
            NotificationCenter.default.post(name: NotificationName.showPlayerDetail, object: nil, userInfo: [NotificationKey.player : player])
        } else {
            NotificationCenter.default.post(name: NotificationName.pickPlayer, object: nil, userInfo: userInfo)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LineupTransferCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let isIphone5 = VFantasyCommon.isIphone5()
        let spacing = isIphone5 ? 0 : 5
        let itemWidth = isIphone5 ? 55 : 58
        
        let totalCellWidth = itemWidth * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = spacing * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = VFantasyCommon.isIphone5() ? 55 : 58
        
        return CGSize(width: itemWidth, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let spacing: CGFloat = VFantasyCommon.isIphone5() ? 0 : 5
        return spacing
    }
}

// MARK: GlobalPlayerLineupCellDelegate

extension LineupTransferCell: GlobalPlayerLineupCellDelegate {

    func tappedPlayer(index: Int, player: Player?) {
        
    }
    
    func removePlayer(index: Int, player: Player?) {
        if let player = players[index] {
            NotificationCenter.default.post(name: NotificationName.removePlayer, object: nil, userInfo: [NotificationKey.player : player])
        }
    }
}

