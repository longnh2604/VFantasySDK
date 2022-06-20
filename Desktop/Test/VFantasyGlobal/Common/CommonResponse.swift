//
//  CommonResponse.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

struct Meta: Codable {
    let success: Bool?
    var message: String?
    let code: Int?
}

struct User: Codable {
    let id: Int?
    let name, firstName, lastName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case firstName = "first_name"
        case lastName = "last_name"
    }
    
    var displayName: String {
        if let id = id, let name = name {
            if String(id) == "\(VFantasyManager.shared.getUserId())" {
                return "me".localiz()
            }
            return name
        }
        return ""
    }
    
    var isLoggedIn: Bool {
        if let id = id {
            return String(id) == "\(VFantasyManager.shared.getUserId())"
        }
        return false
    }
}

class JSONNull: Codable {
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class CommonResponse {
    static func handleResponseFail(_ response: AnyObject, _ model: BaseViewProtocol?) {
        if let model = model {
            if let message = response as? String {
                model.alertMessage(message.localiz())
            } else if let error = response as? NSError, error.domain == NSURLErrorDomain {
                model.alertMessage("no_internet".localiz())
            }
        }
    }
}
