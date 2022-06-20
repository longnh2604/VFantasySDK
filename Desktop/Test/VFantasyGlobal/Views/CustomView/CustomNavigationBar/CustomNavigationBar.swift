//
//  CustomNavigationBar.swift
//  PAN689
//
//  Created by AgileTech on 12/13/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

protocol CustomNavigationBarDelegate {
    func onBack()
}

class CustomNavigationBar: UIView {
    @IBOutlet weak var avatarIcon: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    var delegate: CustomNavigationBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() {
        let _ = self.createFromNib()
        addSubview(containerView)
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func onBack(_ sender: Any) {
        delegate?.onBack()
    }
}
