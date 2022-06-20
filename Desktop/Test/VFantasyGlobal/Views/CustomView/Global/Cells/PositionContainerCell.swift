//
//  PositionContainerCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/11/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol PositionContainerCellDelegate {
  func onResetTransfer(_ sender: PositionContainerCell)
}

class PositionContainerCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetLabel: UILabel!

    var delegate: PositionContainerCellDelegate?
  
    var data = [PositionCountModel(pos: PlayerPositionType.goalkeeper, count: 0),
                PositionCountModel(pos: PlayerPositionType.defender, count: 0),
                PositionCountModel(pos: PlayerPositionType.midfielder, count: 0),
                PositionCountModel(pos: PlayerPositionType.attacker, count: 0)]
    
    func reloadData(_ statistic: Statistic) {
        data[0].updateCount(statistic.goalkeeper ?? 0)
        data[1].updateCount(statistic.defender ?? 0)
        data[2].updateCount(statistic.midfielder ?? 0)
        data[3].updateCount(statistic.attacker ?? 0)
        
        collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        resetLabel?.text = "reset".localiz()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PositionTrackerCell", bundle: Bundle.sdkBundler()), forCellWithReuseIdentifier: "PositionTrackerCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NotificationName.updateStatistic, object: nil)
    }
    
    @objc private func updateData(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let statistic = userInfo[NotificationKey.statistic] as? Statistic {
            reloadData(statistic)
        }
    }
    
    @IBAction func onReset(_ sender: Any) {
      self.delegate?.onResetTransfer(self)
    }
  
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension PositionContainerCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PositionTrackerCell", for: indexPath) as! PositionTrackerCell
        
        let datum = data[indexPath.row]
        cell.active(datum)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
}

extension PositionContainerCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = 50 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 20 * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
