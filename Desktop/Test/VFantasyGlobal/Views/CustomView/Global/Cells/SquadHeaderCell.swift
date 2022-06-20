//
//  SquadHeaderCell.swift
//  PAN689
//
//  Created by David Tran on 12/27/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit

class SquadHeaderCell: Cell {

    private var label: UILabel!
    private var leftView: UIView!

    static let cellId = "SquadHeaderCell"

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
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: FontName.bold, size: FontSize.normal)

        addSubview(label)
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        leftView = UIView()
        leftView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(leftView)
        leftView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        leftView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        leftView.backgroundColor = .lightGray
        leftView.alpha = 0.7
        
        backgroundColor = UIColor(hexString: "EDEAF6")
    }

    func setValue(player: Player?, for indexPath: IndexPath) {
        if indexPath.column == 0 {
            label.text = "Name/Club/Position".localiz()
        } else if indexPath.column == 1 {
            label.text = "Value".localiz()
        } else if indexPath.column == 2 {
            label.text = "Point".localiz()
        } else if indexPath.column == 3 {
          if let player = player {
            label.text = gameWeekTitle(of: player, at: 0)
          } else {
            label.text = nil
          }
        } else if indexPath.column == 4 {
            if let player = player {
              label.text = gameWeekTitle(of: player, at: 1)
            } else {
              label.text = nil
            }
        } else if indexPath.column == 5 {
            if let player = player {
              label.text = gameWeekTitle(of: player, at: 2)
            } else {
              label.text = nil
            }
        }
        leftView.isHidden = indexPath.column != 0
    }
    
    private func gameWeekTitle(of player: Player, at index: Int) -> String {
        guard let gameweek = player.gameweeks?[safe: index] else { return "" }
        return "GW\(gameweek.round ?? 0)"
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
