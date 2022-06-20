//
//  ShadowData.swift
//  LetsPlay360
//
//  Created by Quang Tran on 11/13/19.
//  Copyright © 2019 quangtran. All rights reserved.
//

import UIKit

enum FormationTeam: String {
    case team_442   = "4-4-2"
    case team_424   = "4-2-4"
    case team_433   = "4-3-3"
    case team_343   = "3-4-3"
    case team_4231  = "4-2-3-1"
    case team_352   = "3-5-2"
    case team_4222  = "4-2-2-2"
    case team_4321  = "4-3-2-1"
    case team_4132  = "4-1-3-2"
    case team_4411  = "4-4-1-1"
    case team_4141  = "4-1-4-1"
    case team_532   = "5-3-2"
    case team_541   = "5-4-1"
}

enum PositionType: String {
    case GK, CB, DM, CM, CF
    
    var position: Int {
        switch self {
        case .GK:
            return 0
        case .CB:
            return 1
        case .CM:
            return 2
        default:
            return 3
        }
    }
}

extension PositionType {
    var iconMask: UIImage? {
        switch self {
        case .GK:
            return VFantasyCommon.image(named: "ic_goalkeeeper_border")
        case .CB:
            return VFantasyCommon.image(named: "ic_defender_border")
        case .CM:
            return VFantasyCommon.image(named: "ic_midfielder_border")
        case .CF:
            return VFantasyCommon.image(named: "ic_attacker_border")
        default:
            return nil
        }
    }
    
    var iconAdd: UIImage? {
        switch self {
        case .GK:
            return VFantasyCommon.image(named: "add_goalkeeper")
        case .CB:
            return VFantasyCommon.image(named: "add_defender")
        case .CM:
            return VFantasyCommon.image(named: "add_midfielder")
        case .CF:
            return VFantasyCommon.image(named: "add_attacker")
        default:
            return nil
        }
    }
}

struct PositionPlayer {
    var type: PositionType = .GK
    var index: Int = 0
}

struct Point {
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    
    func rect(from rect: CGRect) -> CGRect {
        return CGRect(x: x * rect.size.width - ShadowData.sizeItem.width/2,
                      y: y * rect.size.height - ShadowData.sizeItem.height/2,
                      width: ShadowData.sizeItem.width,
                      height: ShadowData.sizeItem.height)
    }
    
    func rectGlobal(from rect: CGRect) -> CGRect {
        return CGRect(x: x * rect.size.width - ShadowData.sizePlayerItem.width/2,
                      y: y * rect.size.height - ShadowData.sizePlayerItem.height/2,
                      width: ShadowData.sizePlayerItem.width,
                      height: ShadowData.sizePlayerItem.height)
    }
}

class ShadowData: NSObject {
    
    static func formats() -> [FormationTeam] {
        return [.team_442, .team_433, .team_343, .team_4231, .team_352, .team_4222, .team_4321, .team_4132, .team_4411, .team_4141, .team_532]
    }
    
    //  static func types() -> [BaseItem] {
    //    var items: [BaseItem] = []
    //    for index in 0..<ShadowData.formats().count {
    //      items.append(BaseItem(index, ShadowData.formats()[index].rawValue))
    //    }
    //    return items
    //  }
    
    static var sizeItem: CGSize {
        return CGSize(width: 55, height: 90)
    }
    
    static var sizePlayerItem: CGSize {
        return CGSize(width: 65, height: 62)
    }
    
    static func getFormations(key: String, _ isNew: Bool = false) -> [String: Any]? {
        switch key {
        case FormationTeam.team_442.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.192, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.4, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.608, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.816, y: isNew ? 0.65 : 0.746)],
                PositionType.CM.rawValue : [Point(x: 0.192, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.4, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.608, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.816, y: isNew ? 0.42 : 0.484)],
                PositionType.CF.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.19 : 0.238),
                                            Point(x: isNew ? 0.608: 0.699, y: isNew ? 0.19 : 0.238)]
            ]
        case FormationTeam.team_424.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.192, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.4, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.608, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.816, y: isNew ? 0.65 : 0.746)],
                PositionType.CM.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.42 : 0.484),
                                            Point(x: isNew ? 0.608: 0.699, y: isNew ? 0.42 : 0.484)],
                PositionType.CF.rawValue : [Point(x: 0.192, y: isNew ? 0.19 : 0.238),
                                            Point(x: 0.4, y: isNew ? 0.19 : 0.238),
                                            Point(x: 0.608, y: isNew ? 0.19 : 0.238),
                                            Point(x: 0.816, y: isNew ? 0.19 : 0.238)],
            ]
        case FormationTeam.team_433.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.192, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.4, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.608, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.816, y: isNew ? 0.65 : 0.746)],
                PositionType.CM.rawValue : [Point(x: 0.232, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.5, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.776, y: isNew ? 0.42 : 0.484)],
                PositionType.CF.rawValue : [Point(x: 0.232, y: isNew ? 0.19 : 0.238),
                                            Point(x: 0.5, y: isNew ? 0.19 : 0.238),
                                            Point(x: 0.776, y: isNew ? 0.19 : 0.238)]
            ]
        case FormationTeam.team_343.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.232, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.5, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.776, y: isNew ? 0.65 : 0.746)],
                PositionType.CM.rawValue : [Point(x: 0.192, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.4, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.608, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.816, y: isNew ? 0.42 : 0.484)],
                PositionType.CF.rawValue : [Point(x: 0.232, y: isNew ? 0.19 : 0.238),
                                            Point(x: 0.5, y: isNew ? 0.19 : 0.238),
                                            Point(x: 0.776, y: isNew ? 0.19 : 0.238)]
            ]
        case FormationTeam.team_4231.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.192, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.4, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.608, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.816, y: isNew ? 0.69 : 0.746)],
                PositionType.DM.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.5 : 0.5422),
                                            Point(x: isNew ? 0.608 : 0.699, y: isNew ? 0.5 : 0.5422)],
                PositionType.CM.rawValue : [Point(x: 0.232, y: isNew ? 0.3 : 0.3558),
                                            Point(x: 0.5, y: isNew ? 0.3 : 0.3558),
                                            Point(x: 0.776, y: isNew ? 0.3 : 0.3558)],
                PositionType.CF.rawValue : [Point(x: 0.5, y: isNew ? 0.1 : 0.1651)]
            ]
        case FormationTeam.team_352.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.232, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.5, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.776, y: isNew ? 0.69 : 0.746)],
                PositionType.CM.rawValue : [Point(x: 0.1546, y: isNew ? 0.29 : 0.3784),
                                            Point(x: 0.232, y: isNew ? 0.49 : 0.5384),
                                            Point(x: 0.5, y: isNew ? 0.49 : 0.5384),
                                            Point(x: 0.776, y: isNew ? 0.49 : 0.5384),
                                            Point(x: 0.856, y: isNew ? 0.29 : 0.3784)],
                PositionType.CF.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.1 : 0.178),
                                            Point(x: isNew ? 0.608 : 0.699, y: isNew ? 0.1 : 0.178)]
            ]
        case FormationTeam.team_4222.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.192, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.4, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.608, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.816, y: isNew ? 0.69 : 0.746)],
                PositionType.DM.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.5 : 0.5422),
                                            Point(x: isNew ? 0.608 : 0.699, y: isNew ? 0.5 : 0.5422)],
                PositionType.CM.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.3 : 0.3558),
                                            Point(x: isNew ? 0.608 : 0.699, y: isNew ? 0.3 : 0.3558)],
                PositionType.CF.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.1 : 0.1651),
                                            Point(x: isNew ? 0.608 : 0.699, y: isNew ? 0.1 : 0.1651)]
            ]
        case FormationTeam.team_4321.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.192, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.4, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.608, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.816, y: isNew ? 0.69 : 0.746)],
                PositionType.DM.rawValue : [Point(x: 0.232, y: isNew ? 0.5 : 0.5422),
                                            Point(x: 0.5, y: isNew ? 0.5 : 0.5422),
                                            Point(x: 0.776, y: isNew ? 0.5 : 0.5422)],
                PositionType.CM.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.3 : 0.3558),
                                            Point(x: isNew ? 0.608 : 0.699, y: isNew ? 0.3 : 0.3558)],
                PositionType.CF.rawValue : [Point(x: 0.5, y: isNew ? 0.1 : 0.1651)]
            ]
        case FormationTeam.team_4132.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.192, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.4, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.608, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.816, y: isNew ? 0.69 : 0.746)],
                PositionType.DM.rawValue : [Point(x: 0.5, y: isNew ? 0.5 : 0.5422)],
                PositionType.CM.rawValue : [Point(x: 0.232, y: isNew ? 0.3 : 0.3558),
                                            Point(x: 0.5, y: isNew ? 0.3 : 0.3558),
                                            Point(x: 0.776, y: isNew ? 0.3 : 0.3558)],
                PositionType.CF.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.1 : 0.1651),
                                            Point(x: isNew ? 0.608 : 0.699, y: isNew ? 0.1 : 0.1651)]
            ]
        case FormationTeam.team_4411.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.192, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.4, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.608, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.816, y: isNew ? 0.69 : 0.746)],
                PositionType.DM.rawValue : [Point(x: 0.192, y: isNew ? 0.5 : 0.5422),
                                            Point(x: 0.4, y: isNew ? 0.5 : 0.5422),
                                            Point(x: 0.608, y: isNew ? 0.5 : 0.5422),
                                            Point(x: 0.816, y: isNew ? 0.5 : 0.5422)],
                PositionType.CM.rawValue : [Point(x: 0.5, y: isNew ? 0.3 : 0.3558)],
                PositionType.CF.rawValue : [Point(x: 0.5, y: isNew ? 0.1 : 0.1651)]
            ]
        case FormationTeam.team_4141.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.192, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.4, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.608, y: isNew ? 0.69 : 0.746),
                                            Point(x: 0.816, y: isNew ? 0.69 : 0.746)],
                PositionType.DM.rawValue : [Point(x: 0.5, y: isNew ? 0.5 : 0.5422)],
                PositionType.CM.rawValue : [Point(x: 0.192, y: isNew ? 0.3 : 0.3558),
                                            Point(x: 0.4, y: isNew ? 0.3 : 0.3558),
                                            Point(x: 0.608, y: isNew ? 0.3 : 0.3558),
                                            Point(x: 0.816, y: isNew ? 0.3 : 0.3558)],
                PositionType.CF.rawValue : [Point(x: 0.5, y: isNew ? 0.1 : 0.1651)]
            ]
        case FormationTeam.team_532.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.1, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.3, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.5, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.7, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.9, y: isNew ? 0.65 : 0.746)],
                PositionType.CM.rawValue : [Point(x: 0.232, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.5, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.776, y: isNew ? 0.42 : 0.484)],
                PositionType.CF.rawValue : [Point(x: isNew ? 0.4 : 0.309, y: isNew ? 0.19 : 0.238),
                                            Point(x: isNew ? 0.608 : 0.699, y: isNew ? 0.19 : 0.238)]
            ]
        case FormationTeam.team_541.rawValue:
            return [
                PositionType.GK.rawValue : [Point(x: 0.5, y: isNew ? 0.884 : 0.9)],
                PositionType.CB.rawValue : [Point(x: 0.1, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.3, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.5, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.7, y: isNew ? 0.65 : 0.746),
                                            Point(x: 0.9, y: isNew ? 0.65 : 0.746)],
                PositionType.CM.rawValue : [Point(x: 0.192, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.4, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.608, y: isNew ? 0.42 : 0.484),
                                            Point(x: 0.816, y: isNew ? 0.42 : 0.484)],
                PositionType.CF.rawValue : [Point(x: 0.5, y: isNew ? 0.19 : 0.238)]
            ]
        default:
            return nil
        }
    }
    
}
