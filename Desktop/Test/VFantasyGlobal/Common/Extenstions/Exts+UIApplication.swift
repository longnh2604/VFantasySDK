//
//  Exts+UIApplication.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

extension UIApplication {
    static func getTopController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopController(base: presented)
        }
        return base
    }
}
