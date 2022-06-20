//
//  FieldPreviewCell.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/11/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class GlobalFieldPreviewCell: UITableViewCell {
     
    @IBOutlet weak var contentTableView: UITableView!
    
    var presenter: GlobalCreateTeamInfoPresenter!
    var draftPresenter: TeamLineupDraftPresenter!
    //display mode  
    var showValue = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: NotificationName.updateField, object: nil)
    }
    
    @objc private func updateView(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let showValue = userInfo[NotificationKey.showValue] as? Bool {
                self.showValue = showValue
            }
        }
        contentTableView.reloadData()
    }
    
    func reloadView(presenter: GlobalCreateTeamInfoPresenter) {
        self.presenter = presenter
        contentTableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension GlobalFieldPreviewCell : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalLineupCell") as! GlobalLineupCell
        
        let row = indexPath.row
        switch row {
            case 0:
                cell.reloadData(.attacker, presenter, draftPresenter)
            case 1:
                cell.reloadData(.midfielder, presenter, draftPresenter)
            case 2:
                cell.reloadData(.defender, presenter, draftPresenter)
            default:
                cell.reloadData(.goalkeeper, presenter, draftPresenter)
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let size = CGSize(width: 375, height: 588)
        let height = (size.height*UIScreen.SCREEN_WIDTH/size.width)/4.0
        return indexPath.row == 3 ? height + 15.0 : height - 5.0
    }
}
