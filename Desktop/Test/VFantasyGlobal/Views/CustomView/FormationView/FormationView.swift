//
//  FormationView.swift
//  LetsPlay360
//
//  Created by Quang Tran on 11/13/19.
//  Copyright © 2019 quangtran. All rights reserved.
//

import UIKit

class FormationView: UIView {
    
    var players: [PlayerView] = []
    var delegate: PlayerViewDelegate?
    var isPoints: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = self.createFromNib()
        if let containerView = views?.first as? UIView {
            containerView.backgroundColor = .clear
            containerView.frame = self.bounds
            addSubview(containerView)
        }
    }
    
    func removeOldData() {
        for player in players {
            player.removeFromSuperview()
        }
        self.players.removeAll()
    }
    
    func updateFormation(_ formation: FormationTeam) {
        removeOldData()
        guard let data = ShadowData.getFormations(key: "\(formation.rawValue)") else { return }
        let positions: [PositionType] = [.GK, .CB, .DM, .CM, .CF]
        for position in positions {
            guard let points = data["\(position.rawValue)"] as? [Point] else { continue }
            for index in 0..<points.count {
                let point = points[index]
                let player: PlayerView = PlayerView(frame: point.rect(from: CGRect(x: 0, y: 0, width: UIScreen.SCREEN_WIDTH, height: UIScreen.SCREEN_WIDTH * 1.104)))
                player.isPoints = self.isPoints
                player.position = PositionPlayer(type: position, index: index + 1)
                player.delegate = self.delegate
                self.players.append(player)
                self.addSubview(player)
            }
        }
    }
    
    func updatePlayers(_ players: [Player], _ pitchData: PitchTeamData?) {
        for index in 0..<self.players.count {
            guard let player = getPlayer(self.players[index].position.type, self.players[index].position.index, players) else { continue }
            self.players[index].update(player, pitchData)
        }
    }
    
    func getPlayer(_ position: PositionType, _ order: Int?, _ players: [Player]) -> Player? {
        return players.filter({ return $0.position == position.position && $0.order == order }).first
    }
    
}
