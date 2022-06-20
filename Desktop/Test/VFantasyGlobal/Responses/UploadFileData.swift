//
//  UploadFileData.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

struct UploadFileData: Codable {
    let meta: Meta?
    let response: UploadFileInfo?
}

struct UploadFileInfo: Codable {
    let url, fileName, fileMachineName, fileType: String?
    let fileMIMEType: String?
    let fileSize: Int?
    
    enum CodingKeys: String, CodingKey {
        case url
        case fileName = "file_name"
        case fileMachineName = "file_machine_name"
        case fileType = "file_type"
        case fileMIMEType = "file_mime_type"
        case fileSize = "file_size"
    }
}
