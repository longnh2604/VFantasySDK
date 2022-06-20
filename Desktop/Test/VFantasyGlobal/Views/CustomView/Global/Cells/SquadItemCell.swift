//
//  SquadCell.swift
//  PAN689
//
//  Created by David Tran on 12/26/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class SquadItemCell: Cell {

    private var label: UILabel!
    private var iconImgView: UIImageView!

    static let cellId = "SquadItemCell"

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

        label = UILabel()
        label.textColor = UIColor(hexString: "#262626")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: FontName.regular, size: FontSize.normal)

        iconImgView = UIImageView()
        
        let stackView = UIStackView(arrangedSubviews: [label, iconImgView])
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -13).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomView)
        bottomView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        bottomView.backgroundColor = .lightGray
        bottomView.alpha = 0.4
    }

    func setValue(_ player: Player, for indexPath: IndexPath) {
        if indexPath.column == 1 {
            label.text = player.transferValue?.priceDisplay
        } else if indexPath.column == 2 {
            label.text = "\(player.point ?? 0)"
        } else {
            let index = indexPath.column - 3
            guard let gameweek = player.gameweeks?[safe: index] else { return }
            setValueForGameWeek(gameweek, player: player)
        }
    }
    
    func setValueForGameWeek(_ gameweek: GameWeek, player: Player) {
        label.text = getThreeCharacterOfString(team: gameweek.h2hShortName ?? (gameweek.h2hName ?? ""))
    }
    
    private func getThreeCharacterOfString(team: String?) -> String {
        guard let team = team else { return "" }
        if team.count < 3 {
            return team.uppercased()
        } else {
            return team[0..<3].uppercased()
        }
    }
}
