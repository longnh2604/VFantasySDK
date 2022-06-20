//
//  MyRankingCell.swift
//  PAN689
//
//  Created by AgileTech on 12/10/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

protocol MyRankingCellDelegate: NSObjectProtocol {
    func onMyRanking(_ index: Int)
}

class MyRankingCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var data: MyTeamData?
    weak var delegate: MyRankingCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle.text = "my_ranking".localiz().uppercased()
        collectionView.cornerRadius = 8
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "SubRankingCell", bundle: Bundle.sdkBundler())
        collectionView.register(nib, forCellWithReuseIdentifier: "SubRankingCell")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setup(_ data: MyTeamData?) {
        self.data = data
        self.collectionView.reloadData()
    }
    
    static var heightCell: CGFloat {
        return UITableView.automaticDimension
    }
    
    private func isShowRanking(_ index: Int) -> Bool {
        if index == 0 {
            return data?.globalRanking?.global != nil
        } else if index == 1 {
            return data?.globalRanking?.city != nil
        } else if index == 2 {
            return data?.globalRanking?.country != nil
        } else if index == 3 {
            return data?.globalRanking?.club != nil
        }
        return true
    }
    
}

extension MyRankingCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubRankingCell", for: indexPath) as? SubRankingCell else {
            return UICollectionViewCell()
        }
        if indexPath.row == 0 {
            cell.setup(data?.globalRanking?.global)
            cell.lblName.text = "Global".localiz().uppercased()
        } else if indexPath.row == 1 {
            cell.setup(data?.globalRanking?.city)
        } else if indexPath.row == 2 {
            cell.setup(data?.globalRanking?.country)
        } else if indexPath.row == 3 {
            cell.setup(data?.globalRanking?.club)
            if data?.globalRanking?.club?.name?.lowercased() == "none" || (data?.globalRanking?.club?.id ?? 0) <= 0 {
                cell.lblName.text = "No favourite club".uppercased()
            }
        }
        return cell
    }
}
extension MyRankingCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width/2
        let height = CGFloat(ceilf(Float(collectionView.frame.size.height/2)))
        return CGSize(width: width, height: height)
    }
}

// MARK: - UICollectionViewDelegate

extension MyRankingCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isShowRanking(indexPath.row) else { return }
        delegate?.onMyRanking(indexPath.row)
    }
}
