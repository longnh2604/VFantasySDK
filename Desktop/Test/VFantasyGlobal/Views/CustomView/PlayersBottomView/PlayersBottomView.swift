//
//  PlayersBottomView.swift
//  PAN689
//
//  Created by Quang Tran on 12/28/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class PlayersBottomView: UIView {
    
    @IBOutlet weak var playersCollectionView: UICollectionView!
    @IBOutlet weak var lblNoData: UILabel!
    
    var data: PitchTeamData?
    var players: [Player] = []
    var pickCompletion: OnPickedPlayer?
    var detailCompletion: OnDetailPlayer?
    var isPoints: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = self.createFromNib()
        if let containerView = views?.first as? UIView {
            containerView.backgroundColor = .clear
            containerView.frame = self.bounds
            addSubview(containerView)
        }
        playersCollectionView.register(UINib(nibName: PlayerBottomCell.identifierCell, bundle: Bundle.sdkBundler()), forCellWithReuseIdentifier: PlayerBottomCell.identifierCell)
        lblNoData.isHidden = true
    }
    
    func updatePlayers(_ players: [Player], _ pitchData: PitchTeamData?) {
        self.lblNoData.isHidden = !players.isEmpty
        self.data = pitchData
        self.players.removeAll()
        self.players.append(contentsOf: players)
        self.playersCollectionView.reloadData()
    }
}

//MARK: UICollectionViewDataSource

extension PlayersBottomView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerBottomCell.identifierCell, for: indexPath) as? PlayerBottomCell else { return UICollectionViewCell() }
        cell.playerView.isPoints = self.isPoints
        cell.playerView.update(players[indexPath.row], data)
        cell.playerView.delegate = self
        return cell
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension PlayersBottomView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return PlayerBottomCell.sizeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
}

extension PlayersBottomView: PlayerViewDelegate {
    func onSelectPlayer(_ sender: PlayerView) {
        guard let player = sender.player else { return }
        if let detailCompletion = self.detailCompletion {
            detailCompletion(player)
        } else {
            if !sender.viewLock.isHidden {
                guard let topVC = UIApplication.getTopController() else { return }
                topVC.showAlert(message: "This player has been locked because his real match has started.".localiz())
            } else {
                if let completion = self.pickCompletion {
                    completion(sender.player!)
                }
            }
        }
    }
}
