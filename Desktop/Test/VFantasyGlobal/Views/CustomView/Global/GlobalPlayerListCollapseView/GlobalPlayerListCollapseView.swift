//
//  PlayerListCollapseView.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/25/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol GlobalPlayerListCollapseViewDelegate: NSObjectProtocol {
    func onFilter()
    func toggleSort()
}

class GlobalPlayerListCollapseView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var lblPlayers: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ivSort: UIImageView!
    
    var isDesc: Bool = true
    var data: [PlayerPositionType] = [.all, .goalkeeper, .defender, .midfielder, .attacker]
    var totalCount: Int = 0 {
        didSet {
            self.lblPlayers.text = "\(totalCount) \("players".localiz())"
        }
    }
    
    var presenter: GlobalCreateTeamInfoPresenter!
    private var selectedPosition: PlayerPositionType = .all
    
    weak var delegate: GlobalPlayerListCollapseViewDelegate?

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
        let _ = Bundle.sdkBundler()?.loadNibNamed("GlobalPlayerListCollapseView", owner: self, options: nil)
        guard let content = containerView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(content)
        
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 16.0
        searchBar.layer.masksToBounds = true
        searchBar.tfSearch.placeholder(text: "Search name".localiz(), color: .white)
        lblPlayers.font = UIFont(name: FontName.regular, size: 18)!
        totalCount = 0
        
        initCollectionView()
    }
    
    func initCollectionView() {
        collectionView.register(UINib(nibName: "GlobalPlayerListPositionCell", bundle: Bundle.sdkBundler()), forCellWithReuseIdentifier: "GlobalPlayerListPositionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: Public funcs
    func reloadData() {
        let info = presenter.playerListInfo
        var total = 0
        if let statistic = info.statistic {
            total += statistic.goalkeeper ?? 0
            total += statistic.defender ?? 0
            total += statistic.midfielder ?? 0
            total += statistic.attacker ?? 0
        }
        self.totalCount = total
    }
    
    @IBAction func onSort(_ sender: Any) {
        self.isDesc = !isDesc
        UIView.animate(withDuration: 0.3) {
            self.ivSort.transform = self.isDesc ? .identity : CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }
        self.delegate?.toggleSort()
    }
}

extension GlobalPlayerListCollapseView: SearchBarDelegate {
    func onSearch(_ key: String) {
        presenter.searchText = key
        presenter.refreshPlayerList()
    }
}

extension GlobalPlayerListCollapseView : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GlobalPlayerListPositionCell", for: indexPath) as! GlobalPlayerListPositionCell
        let position = self.data[indexPath.row]
        cell.lblPosition.text = position.title
        cell.isActive = position == selectedPosition
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let position = self.data[indexPath.row]
        if position != selectedPosition {
            selectedPosition = position
            presenter.sortPosition(indexPath.row - 1)
            presenter.refreshPlayerList()
            collectionView.reloadData()
            
            //Scroll to center
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension GlobalPlayerListCollapseView : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = self.data[indexPath.row].title
        let font = UIFont(name: FontName.bold, size: 14)!
        let width = title.width(withConstrainedHeight: 30.0, font: font)
        return CGSize(width: width + 24.0, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
