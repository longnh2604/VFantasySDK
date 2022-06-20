//
//  Exts+Bundle.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation

extension Bundle {
    static func sdkBundler() -> Bundle? {
        let bundle = Bundle.init(identifier: "com.agile.VFantasyGlobal")
        return bundle
    }
}
