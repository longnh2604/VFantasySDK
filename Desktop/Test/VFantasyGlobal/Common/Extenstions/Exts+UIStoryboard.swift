//
//  Exts+UIStoryboard.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

enum StoryboardNames: String {
    case global = "Global"
    case player = "Player"
    case common = "Common"
    case newGlobal = "NewGlobal"
    case leaugeDetail = "LeagueDetail"
    case transferGlobal = "TransferGlobal"
    case super7 = "Super7"
}

extension UIStoryboard {
    convenience init(name: StoryboardNames, bundle storyboardBundleOrNil: Bundle?) {
        self.init(name: name.rawValue, bundle: storyboardBundleOrNil)
    }
}

func instantiateViewController(storyboardName: StoryboardNames, withIdentifier: String) -> Any {
    let storyBoard : UIStoryboard = UIStoryboard(name: storyboardName.rawValue, bundle: Bundle.sdkBundler())
    let controller = storyBoard.instantiateViewController(withIdentifier: withIdentifier)
    return controller
}
