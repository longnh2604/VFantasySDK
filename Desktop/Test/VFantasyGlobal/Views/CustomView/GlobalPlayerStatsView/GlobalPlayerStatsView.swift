//
//  GlobalPlayerStatsView.swift
//  PAN689
//
//  Created by Quang Tran on 8/11/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

@objc protocol GlobalPlayerStatsViewDelegate {
    @objc func onViewAll(_ sender: GlobalPlayerStatsView)
    @objc func onDetail(_ playerId: Int)
}

class GlobalPlayerStatsView: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAll: UIButton!
    @IBOutlet weak var tbvList: UITableView!
    @IBOutlet weak var delegate: GlobalPlayerStatsViewDelegate?
    
    var type: PlayerStatsType = .goals
    
    var numberRows: Int {
        return self.players.count > 3 ? 3 : self.players.count
    }
    
    var players: [Player] = [] {
        didSet {
            self.tbvList.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = self.createFromNib()
        let contentView = views?.first as? UIView
        contentView?.backgroundColor = .clear
        contentView?.frame = self.bounds
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        setup()
    }
    
    func setup() {
        self.tbvList.register(UINib(nibName: GlobalPlayerStatCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: GlobalPlayerStatCell.identifierCell)
    }

    func updateData(_ type: PlayerStatsType, _ data: [Player]) {
        self.type = type
        self.lblTitle.text = type.title
        self.btnAll.isHidden = data.count <= 3
        self.players = data
    }
    
    @IBAction func onViewAll(_ sender: Any) {
        self.delegate?.onViewAll(self)
    }
}

extension GlobalPlayerStatsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GlobalPlayerStatCell.identifierCell) as? GlobalPlayerStatCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.updateData(players[indexPath.row])
        cell.contentToBottomLayout.constant = indexPath.row == numberRows - 1 ? 0.0 : 1.0
        return cell
    }
}

extension GlobalPlayerStatsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GlobalPlayerStatCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = self.players[indexPath.row]
        self.delegate?.onDetail(player.id ?? 0)
    }
}
