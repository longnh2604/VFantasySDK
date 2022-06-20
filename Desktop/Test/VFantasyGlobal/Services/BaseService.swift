//
//  BaseService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

class BaseService: BaseServiceManager {
    var limit = 40
    var offset = 0
    
    var page = 1
    var pageLimit = 5
    var per_page = 20
    
    var isFullData = false
    
    var pendingRequest = false
    
    override init() {
        super.init()
        
        _ = self.initWith(baseURL: VFantasyManager.shared.getBaseUrl())
        self.updateHeaderIfNeed(key: "Authorization", value: VFantasyManager.shared.getToken())
    }
}
