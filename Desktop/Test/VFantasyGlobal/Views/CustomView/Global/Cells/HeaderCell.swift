//
//  HeaderCell.swift
//  PAN689
//
//  Created by AgileTech on 12/2/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

protocol HeaderCellDelegate {
  func onEdit()
}

class HeaderCell: UITableViewCell {

    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
  
    var delegate: HeaderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblHeader.text = "Global League".localiz()
        btnEdit.setTitle("edit_action".localiz(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func onProfile(_ sender: Any) {
    }
    
    @IBAction func onEdit(_ sender: Any) {
      self.delegate?.onEdit()
    }
    
    func setup(_ data: MyTeamData?) {
        if let data = data {
            editView.isHidden = false
            ivAvatar.isHidden = false
            ivAvatar.setPlayerAvatar(with: data.logo)
            lblName.text = data.name
        } else {
            editView.isHidden = true
            ivAvatar.isHidden = true
        }
    }
    
    static var heightCell: CGFloat {
        return 86
    }
    
}
