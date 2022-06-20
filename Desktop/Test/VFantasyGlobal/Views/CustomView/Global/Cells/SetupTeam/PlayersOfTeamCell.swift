//
//  PlayersOfTeamCell.swift
//  PAN689
//
//  Created by AgileTech on 12/16/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit
protocol PlayersOfTeamCellDelegate: NSObject {
    func showListPlayer(position: PlayerPositionType, index: Int)
}
class PlayersOfTeamCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var numberOfItem: Int!
    weak var delegate: PlayersOfTeamCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "PlayerCell", bundle: Bundle.sdkBundler())
        collectionView.register(nib, forCellWithReuseIdentifier: "PlayerCell")
        numberOfItem = 24
        collectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension PlayersOfTeamCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0, 5, 18, 19, 22, 23:
            break
        case 1, 2, 3, 4:
            delegate?.showListPlayer(position: .attacker, index: indexPath.row)
        case 6, 7, 8, 9, 10, 11:
            delegate?.showListPlayer(position: .midfielder, index: indexPath.row)
        case 12, 13, 14, 15, 16, 17:
            delegate?.showListPlayer(position: .defender, index: indexPath.row)
        case 20, 21:
            delegate?.showListPlayer(position: .goalkeeper, index: indexPath.row)
        default:
            break
        }
       // delegate?.showListPlayer(position: .all, index: indexPath.row)
    }
}
extension PlayersOfTeamCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItem
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCell", for: indexPath) as? PlayerCell else {
            return UICollectionViewCell()
        }
        switch indexPath.row {
        case 0, 5, 18, 19, 22, 23:
            cell.avatarButton.isHidden = true
            cell.removeButton.isHidden = true
        case 1, 2, 3, 4:
            cell.setupCell(position: .attacker)
        case 6, 7, 8, 9, 10, 11:
            cell.setupCell(position: .midfielder)
        case 12, 13, 14, 15, 16, 17:
            cell.setupCell(position: .defender)
        case 20, 21:
            cell.setupCell(position: .goalkeeper)
        default:
            break
        }
        //cell.setupCell(isNil: false)
        return cell
    }
    
    
}
extension PlayersOfTeamCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/6
        let height = collectionView.frame.height/4
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
