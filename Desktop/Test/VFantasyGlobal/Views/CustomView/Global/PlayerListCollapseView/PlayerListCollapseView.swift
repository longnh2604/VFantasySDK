//
//  PlayerListCollapseView.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/25/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol PlayerListCollapseViewDelegate: NSObjectProtocol {
    func onFilter()
}

class PlayerListCollapseView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var marginView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var positionSelectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var iconFilter: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: IBDCUISearchBar!
    
    var data = [PositionCountModel(pos: PlayerPositionType.goalkeeper, count: 0),
                PositionCountModel(pos: PlayerPositionType.defender, count: 0),
                PositionCountModel(pos: PlayerPositionType.midfielder, count: 0),
                PositionCountModel(pos: PlayerPositionType.attacker, count: 0)]
    
    var presenter: CreateTeamInfoPresenter!
    private var selectedPositionIndexPath: IndexPath = IndexPath(row: 0, column: 0)
    
    weak var delegate: PlayerListCollapseViewDelegate?

    @IBAction func onFilter(_ sender: Any) {
        delegate?.onFilter()
    }
    
    // MARK: Init View
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        let _ = Bundle.sdkBundler()?.loadNibNamed("PlayerListCollapseView", owner: self, options: nil)
        guard let content = containerView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(content)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initCollectionView()
        searchBar.delegate = self
        searchBar.placeholder = "search_player_placeholder".localiz()
        guard let customFont = UIFont(name: FontName.bold, size: FontSize.normal) else {
            return
        }
        searchBar.updateFontPlaceHolder(font: customFont)
    }
    
    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PositionTrackerCell", bundle: Bundle.sdkBundler()), forCellWithReuseIdentifier: "PositionTrackerCell")
        collectionView.register(UINib(nibName: "AllPlayerCell", bundle: Bundle.sdkBundler()), forCellWithReuseIdentifier: "AllPlayerCell")
    }
    
    // MARK: Public funcs
    func removePositionSelectionView() {
        positionSelectionViewHeight.constant = 0
    }
    
    func reloadData() {
        let info = presenter.playerListInfo
        if let statistic = info.statistic {
            data[0].updateCount(statistic.goalkeeper ?? 0)
            data[1].updateCount(statistic.defender ?? 0)
            data[2].updateCount(statistic.midfielder ?? 0)
            data[3].updateCount(statistic.attacker ?? 0)
        }
        collectionView.reloadData()
    }
    
    func stopEditing() {
        searchBar.showsCancelButton = false
    }
    
    func updateHeader(_ amount: CGFloat, _ percentage: CGFloat) {
        topConstraint.constant = -amount + 10
        self.searchBar.alpha = percentage
        self.collectionView.alpha = percentage
        self.searchBar.alpha = percentage
        self.iconFilter.alpha = percentage
    }
}

extension PlayerListCollapseView : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllPlayerCell", for: indexPath) as! AllPlayerCell
            let bg: UIColor = selectedPositionIndexPath.row == 0 ? .white : .gray
            let textColor: UIColor = selectedPositionIndexPath.row == 0 ? UIColor(hexString: "4A4A4A") : .white
            cell.allLabel.backgroundColor = bg
            cell.allLabel.textColor = textColor
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PositionTrackerCell", for: indexPath) as! PositionTrackerCell
        
        let datum = data[indexPath.row - 1]
        if selectedPositionIndexPath.row == 0 {
            cell.active(datum)
        } else if indexPath == selectedPositionIndexPath {
            cell.active(datum)
        } else {
            cell.inactive(datum)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            let index = indexPath.row
            if let trackerCell = cell as? PositionTrackerCell {
                let datum = data[index - 1]
                trackerCell.active(datum)
            }
            selectedPositionIndexPath = indexPath
            presenter.sortPosition(index - 1)
        }
    }
}

extension PlayerListCollapseView : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = 50 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 40)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension PlayerListCollapseView : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        presenter.searchText = text
        presenter.refreshPlayerList()
        
        self.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        presenter.searchText = ""
        presenter.refreshPlayerList()
        
        self.endEditing(true)
        searchBar.showsCancelButton = false
    }
}
