//
//  TeamOverViewCell.swift
//  PAN689
//
//  Created by AgileTech on 12/11/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class TeamOverViewCell: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "MyLeagueDetailCell", bundle: Bundle.sdkBundler())
        tableView.register(nib, forCellReuseIdentifier: "MyLeagueDetailCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
extension TeamOverViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyLeagueDetailCell", for: indexPath) as? MyLeagueDetailCell else {
            return UITableViewCell()
        }
        cell.status.isHidden = true
        return cell
    }
    
    
}
extension TeamOverViewCell: UITableViewDelegate {
    
}
