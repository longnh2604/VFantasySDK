//
//  SquadNameCell.swift
//  PAN689
//
//  Created by David Tran on 12/26/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class SquadNameCell: Cell {

    private var nameLabel: UILabel!
    private var clubLabel: UILabel!
    private var positionView: UIButton!
    private var stackView: UIStackView!
    private var positionViewBottomConstraint: NSLayoutConstraint!

    static let cellId = "SquadNameCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }

    private func initialization() {
        super.awakeFromNib()

        nameLabel = createLabel()
        clubLabel = createLabel()
        positionView = createPositionView()
        
        nameLabel.font = UIFont(name: FontName.bold, size: FontSize.normal)
        clubLabel.font = UIFont(name: FontName.regular, size: FontSize.normal)
        clubLabel.textColor = UIColor(red: 73.0/255.0, green: 157.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        
        stackView = UIStackView(arrangedSubviews: [nameLabel, clubLabel])
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        addSubview(positionView)
        positionView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        positionViewBottomConstraint = positionView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -10)
        positionViewBottomConstraint.isActive = true
        positionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        positionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        let rightView = UIView()
        rightView.alpha = 0.7
        rightView.backgroundColor = .gray
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(rightView)
        rightView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rightView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rightView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        rightView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        let bottomView = UIView()
        bottomView.alpha = 0.3
        bottomView.backgroundColor = .lightGray
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomView)
        bottomView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    func setValue(player: Player, indexPath: IndexPath, indexOfFirstPositions: [Int]) {
        nameLabel.text = player.getNameDisplay()
        if let short = player.realClub?.shortName, !short.isEmpty {
            clubLabel.text = short
        } else {
            clubLabel.text = player.realClub?.name
        }
        if indexOfFirstPositions.contains(indexPath.row) {
            positionView.isHidden = false
            positionView.setTitle(player.positionName(), for: .normal)
            positionView.backgroundColor = player.positionColor()
            positionViewBottomConstraint.constant = -10
        } else {
            positionView.isHidden = true
            positionViewBottomConstraint.constant = 0
        }
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor(hexString: "#262626")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createPositionView() -> UIButton {
        let positionView = UIButton()
        positionView.layer.cornerRadius = 6
        positionView.layer.masksToBounds = true
        positionView.backgroundColor = .gray
        positionView.contentHorizontalAlignment = .left
        positionView.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        positionView.translatesAutoresizingMaskIntoConstraints = false
        positionView.titleLabel?.font = UIFont(name: FontName.black, size: FontSize.normal)
        return positionView
    }

}
