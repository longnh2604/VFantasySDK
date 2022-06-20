//
//  TransferPlayerCell.swift
//  PAN689
//
//  Created by Quang Tran on 12/28/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class TransferPlayerCell: UITableViewCell {
     
    @IBOutlet weak var contentTableView: UITableView!
    
    var presenter: TransferGlobalPresenter!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.separatorStyle = .none
    }
    
    func reloadView(presenter: TransferGlobalPresenter) {
        self.presenter = presenter
        contentTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TransferPlayerCell : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LineupTransferCell") as! LineupTransferCell
        
        let row = indexPath.row
        switch row {
        case 0:
            cell.reloadData(.attacker, presenter)
        case 1:
            cell.reloadData(.midfielder, presenter)
        case 2:
            cell.reloadData(.defender, presenter)
        default:
            cell.reloadData(.goalkeeper, presenter)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 4))
    }
}

