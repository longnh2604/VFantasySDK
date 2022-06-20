//
//  GlobalBankPlayerView.swift
//  PAN689
//
//  Created by Quang Tran on 7/14/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

class GlobalBankPlayerView: UIView {

    @IBOutlet weak var tbvList: UITableView!
    
    var players: [Player] = []
    var onDetailPlayer: OnDetailPlayer?
    var separateIndex: Int?
    
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
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.SCREEN_WIDTH, height: 50.0))
        header.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: 16, y: 8, width: header.bounds.width - 32, height: 42))
        label.text = "squad".localiz()
        label.font = UIFont(name: FontName.bold, size: 18)!
        label.textColor = UIColor(hex: 0x2C3653)
        header.addSubview(label)
        
        self.tbvList.tableHeaderView = header
        self.tbvList.register(UINib(nibName: GlobalBankPlayerCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: GlobalBankPlayerCell.identifierCell)
        self.tbvList.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }

    func update(_ players: [Player], _ separateIndex: Int?) {
        self.players.removeAll()
        self.players = players
        self.separateIndex = separateIndex
        self.tbvList.reloadData()
    }
    
}

extension GlobalBankPlayerView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.players.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GlobalBankPlayerCell.identifierCell) as? GlobalBankPlayerCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.configTitle()
            cell.lineView.backgroundColor = UIColor(hex: 0xF6F7FB)
        } else {
            let player = self.players[indexPath.row - 1]
            cell.updateData(player)
            if let index = self.separateIndex, index == indexPath.row {
                cell.lineViewHeightLayout.constant = 6.0
                cell.lineView.backgroundColor = UIColor(hex: 0xEDEAF6)
            } else {
                cell.lineViewHeightLayout.constant = 1.0
                cell.lineView.backgroundColor = UIColor(hex: 0xF6F7FB)
            }
        }
        return cell
    }
}

extension GlobalBankPlayerView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let index = self.separateIndex, index == indexPath.row {
            return GlobalBankPlayerCell.heightCell + 5.0
        }
        return GlobalBankPlayerCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let player = self.players[indexPath.row - 1]
            self.onDetailPlayer?(player)
        }
    }
}
