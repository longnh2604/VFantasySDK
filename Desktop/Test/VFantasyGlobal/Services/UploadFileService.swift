//
//  UploadFileService.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

struct RequestUploadFile {
    let filreName:String
    let storage:String
    let imageLocal:UIImage
}

class UploadFileService: BaseService {
    func uploadFile(_ model: RequestUploadFile, callBack: @escaping (_ response: AnyObject, _ status: Bool) -> Void) {
        
        let mimeType = model.filreName.components(separatedBy: ".").last
        let attached = UploadFile(fileType: .Image, fileName: model.filreName, withName: "file", mimeType: "image/\(mimeType!)", scale: 0.5, pathFile: nil, image: model.imageLocal, url: nil)
        let params = ["storage":model.storage]
        
        self.request(type: UploadFileData.self, method: .post, params: params, pathURL: CommonAPI.api_upload_file, attachData: [attached], uploadProgress: { (process) in
            print(process.completedUnitCount)
        }) { (data, status, statusCode) in
            callBack(data, status)
        }
    }
}
