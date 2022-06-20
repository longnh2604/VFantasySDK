//
//  FormationView.swift
//  LetsPlay360
//
//  Created by Quang Tran on 11/13/19.
//  Copyright © 2019 quangtran. All rights reserved.
//

import UIKit

class GlobalFormationView: UIView {
    
    var players: [GlobalPlayerView] = []
    var delegate: GlobalPlayerViewDelegate?
    
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
    
    func updateFormation(_ formation: FormationTeam, _ players: [Player], _ pitchData: PitchTeamData?, _ isLineup: Bool) {
        removeOldData()
        guard let data = ShadowData.getFormations(key: "\(formation.rawValue)", true) else { return }
        let rect = CGRect(x: 0, y: 0, width: UIScreen.SCREEN_WIDTH - 32, height: (UIScreen.SCREEN_WIDTH - 32) * 318.0/343.0)
        let positions: [PositionType] = [.GK, .CB, .DM, .CM, .CF]
        for position in positions {
            guard let points = data["\(position.rawValue)"] as? [Point] else { continue }
            for index in 0..<points.count {
                let point = points[index]
                let player: GlobalPlayerView = GlobalPlayerView(frame: point.rectGlobal(from: rect))
                player.position = PositionPlayer(type: position, index: index + 1)
                player.delegate = self
                self.players.append(player)
                self.addSubview(player)
            }
        }
        if isLineup {
            self.updatePlayers(players, pitchData, isLineup)
        } else {
            self.updatePlayersForTeamOTWeek(players, nil, isLineup)
        }
    }
    
    func updatePlayers(_ players: [Player], _ pitchData: PitchTeamData?, _ isLineup: Bool) {
        for index in 0..<self.players.count {
            guard let player = getPlayer(self.players[index].position.type, isLineup ? self.players[index].position.index : nil, players) else { continue }
            self.players[index].update(player, pitchData, isLineup)
        }
    }
    
    func updatePlayersForTeamOTWeek(_ players: [Player], _ pitchData: PitchTeamData?, _ isLineup: Bool) {
        for index in 0..<players.count {
            guard let playerView = self.getPlayerView(players[index].mainPosition ?? 0) else { continue }
            playerView.update(players[index], nil, false)
        }
    }

    func getPlayer(_ position: PositionType, _ order: Int?, _ players: [Player]) -> Player? {
        return players.filter({ return $0.position == position.position && $0.order == order }).first
    }
    
    func getPlayerView(_ mainPosition: Int) -> GlobalPlayerView? {
        return self.players.filter({ return $0.position.type.position == mainPosition && $0.player == nil }).first
    }
}

extension GlobalFormationView: GlobalPlayerViewDelegate {
    func onSelectPlayer(_ sender: GlobalPlayerView) {
        self.delegate?.onSelectPlayer(sender)
    }
}
