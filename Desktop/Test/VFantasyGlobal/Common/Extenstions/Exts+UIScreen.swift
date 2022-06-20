//
//  Exts+Screen.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

extension UIScreen {
    static var SCREEN_WIDTH: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static var SCALED_SCREEN_WIDTH: CGFloat {
        return UIScreen.SCREEN_WIDTH * UIScreen.main.scale
    }
    
    static var SCREEN_HEIGHT: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static var SCALED_SCREEN_HEIGHT: CGFloat {
        return UIScreen.SCREEN_HEIGHT * UIScreen.main.scale
    }
}

var KEY_WINDOW_SAFE_AREA_INSETS: UIEdgeInsets {
    if let keywindow = UIApplication.shared.keyWindow {
        return keywindow.mySafeAreaInsets()
    } else {
        return UIEdgeInsets.zero
    }
}
