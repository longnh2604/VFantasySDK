//
//  BaseViewProtocol.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import UIKit

typealias OnDetailPlayer = (_ player: Player) -> Void
typealias OnPickedPlayer = (_ player: Player) -> Void

typealias MatchGroup = (key: String, value: [RealMatch])

protocol FilterClubViewControllerDelegate: NSObjectProtocol {
    func didClickBack(position: [FilterData], club: [FilterData])
}

protocol CheckBoxViewControllerDelegate: NSObjectProtocol {
    func didClickApply(_ item: CheckBoxData)
}

protocol PlayerDetailViewControllerDelegate: NSObjectProtocol {
    func onPick(_ player: Player)
    func onPick(_ id: Int)
}

protocol BaseViewProtocol: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func alertMessage(_ message: String)
}

protocol CustomCellPlayerDetailInfoDelegate: NSObjectProtocol {
    func didClickSeason(_ item: CheckBoxData)
    func didPickGameweek(_ item: CheckBoxData)
    func didPickPlayer()
    func showInfo()
}

protocol ConfirmLineupCellDelegate: NSObjectProtocol {
    func onCompleteLineup()
}

protocol GlobalConfirmLineupCellDelegate: NSObjectProtocol {
    func onCompleteLineup()
}
