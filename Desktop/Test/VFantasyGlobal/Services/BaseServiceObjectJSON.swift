//
//  BaseServiceObjectJSON.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit
import Alamofire

protocol TimeoutAlamofire {
    func timeout()
    func handleCode(code:Int)
}

struct StatusCodeResponse {
    static let success = 1
    static let fail = 0
    static let code_success = 200
}

struct HeadersParams {
    static let content_type = "Content-Type"
    static let accept = "Accept"
    static let token = "token"
    static let authorization = "Authorization"
    static let bearer = "Bearer"
    static let application_json = "application/json"
    static let application_form_urlencoded = "application/x-www-form-urlencoded"
    static let application_form_data = "application/form-data"
    static let textHtml = "text/html"
    static let timezone = "Timezone"
    static let timestamp = "Timestamp"
}

struct ModelUploadFile {
    let name:String
    let nameFile:String
    let pathImage:String
    let iconLink:NSURL
    let image:UIImage
    let withName:String
}

class BaseServiceObjectJSON: NSObject {
    var sessionManager: Session!
    var baseURL:String = ""
    var headers:HTTPHeaders = [:]
    let timeOut = 20
    var delegateTimeOut: TimeoutAlamofire?
    override init() {
        super.init()
        configuration(url_base: baseURL)
    }
    
    /// Change base url default
    ///
    /// - Parameter url_base: BaseServiceObjectJSON
    func initWithURLBase(url_base:String) -> BaseServiceObjectJSON {
        configuration(url_base: url_base)
        return self
    }
    
    /// Set config: Timeout, Token
    ///
    /// - Parameters:
    ///   - url_base: Base URL
    ///   - token: Token Auth
    func configuration(url_base:String, token:String="") -> Void {
        
        //sonht: use default header of Alamorfire
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(self.timeOut)
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        sessionManager = Session(configuration: configuration)
        
        // setup base url
        baseURL = url_base
        
        // setup hearder base
        updateHeaderIfNeed(key: HeadersParams.authorization, value: "\(HeadersParams.bearer) \(token)")
        updateHeaderIfNeed(key: HeadersParams.timezone, value: TimeZone.current.identifier)
        updateHeaderIfNeed(key: HeadersParams.timestamp, value: "\(Int(Date().timeIntervalSince1970))")
    }
    
    func URLWihtPath(path:String) -> String {
        let fullPath = baseURL + path
        print("-----> fullPath: " + fullPath)
        return fullPath
    }
    
    // MARK:- update headerIfNeed
    func updateHeaderIfNeed(key:String!, value:String!) -> Void {
        print("\(key!):\(value!)")
        headers.update(name: key, value: value)
    }
    
    func getJsonString(json:String?) -> String {
        if json != nil {
            print("-----> json: " + json!)
            return json!
        }
        print("json: ")
        return String()
    }
    
    // MARK:- method delete
    func requestDelete(jsonString:String?, path:String, complete:@escaping (_ response:AnyObject, _ status:Bool) -> Void) {
        let json = getJsonString(json: jsonString)
        sessionManager.request(URLWihtPath(path: path), method: .delete, encoding: json, headers: headers).validate().responseJSON { response in
            self.handleResponse(response: response) { response, status in
                complete(response, status)
            }
        }
    }
    
    func requestDeleteParams(params:[String:Any], path:String, complete:@escaping (_ response:AnyObject, _ status:Bool) -> Void) {
        sessionManager.request(URLWihtPath(path: path), method: .delete, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            self.handleResponse(response: response, complete: { (response, status) in
                complete(response, status)
            })
        }
    }
    
    // MARK:- method get
    func requestGet(jsonString:String?, path:String, complete:@escaping (_ response:AnyObject, _ status:Bool) -> Void) {
        let json = getJsonString(json: jsonString)
        sessionManager.request(URLWihtPath(path: path), method: .get, encoding: json, headers: headers).validate().responseJSON { (response:AFDataResponse<Any>) in
            self.handleResponse(response: response, complete: { (response, status) in
                complete(response, status)
            })
        }
    }
    
    func requestGetParams(params:[String:Any], path:String, complete:@escaping (_ response:AnyObject, _ status:Bool) -> Void) {
        sessionManager.request(URLWihtPath(path: path), method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response:AFDataResponse<Any>) in
            self.handleResponse(response: response, complete: { (response, status) in
                complete(response, status)
            })
        }
    }
    
    // MARK:- method put
    func requestPut(jsonString:String?, path:String, complete:@escaping (_ response:AnyObject, _ status:Bool) -> Void) {
        let json = getJsonString(json: jsonString)
        sessionManager.request(URLWihtPath(path: path), method: .put, encoding: json, headers: headers).validate().responseJSON { (response:AFDataResponse<Any>) in
            self.handleResponse(response: response, complete: { (response, status) in
                complete(response, status)
            })
        }
    }
    
    func requestPutParams(params:[String:Any], path:String, complete:@escaping (_ response:AnyObject, _ status:Bool) -> Void) {
        sessionManager.request(URLWihtPath(path: path), method: .put, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response:AFDataResponse<Any>) in
            self.handleResponse(response: response, complete: { (response, status) in
                complete(response, status)
            })
        }
    }
    
    // MARK:- method post
    func requestPost(jsonString:String?, path:String, complete:@escaping (_ response:AnyObject, _ status:Bool) -> Void) {
        let json = getJsonString(json: jsonString)
        sessionManager.request(URLWihtPath(path: path), method: .post, encoding: json, headers: headers).validate().responseJSON { (response:AFDataResponse<Any>) in
            self.handleResponse(response: response, complete: { (response, status) in
                complete(response, status)
            })
        }
    }
    
    
    func requestPostParams(params:[String:Any], path:String, complete:@escaping (_ response:AnyObject, _ status:Bool) -> Void) {
        sessionManager.request(URLWihtPath(path: path), method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response:AFDataResponse<Any>) in
            self.handleResponse(response: response, complete: { (response, status) in
                complete(response, status)
            })
        }.validate(contentType: ["application/json"])
    }
    
    // MARK:- method post with http code
    func requestPostWithHTTPCode(jsonString:String?, path:String, complete:@escaping (_ response:AnyObject, _ status:Bool, _ statusCode: Int?) -> Void) {
        let json = getJsonString(json: jsonString)
        sessionManager.request(URLWihtPath(path: path), method: .post, encoding: json, headers: headers).validate().responseJSON { (response:AFDataResponse<Any>) in
            self.handleResponseWithHTTPCode(response: response, complete: { (response, status, statusCode) in
                complete(response, status, statusCode)
            })
        }
    }
    
    func requestPostWithParamsHTTPCode(params:[String:Any], path:String, complete:@escaping (_ response:AnyObject, _ status:Bool, _ statusCode: Int?) -> Void) {
        sessionManager.request(URLWihtPath(path: path), method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate().responseJSON { (response:AFDataResponse<Any>) in
            self.handleResponseWithHTTPCode(response: response, complete: { (response, status, statusCode) in
                complete(response, status, statusCode)
            })
        }.validate(contentType: ["application/json"])
    }
    // MARK: - Delegate
    func timeout() {
        if delegateTimeOut != nil {
            self.delegateTimeOut!.timeout()
        }
    }
    
    //MARK:- handle response
    func handleResponse(response: AFDataResponse<Any>, complete:@escaping (_ response:AnyObject, _ status:Bool)->Void) {
        self.delegateTimeOut?.handleCode(code: response.response?.statusCode ?? 0)
        switch(response.result) {
        case .success(let value):
            complete(value as AnyObject, true)
            break
        case .failure(let error):
            self.timeout()
            complete(error.localizedDescription as AnyObject, false)
            break
        }
    }
    
    //MARK:- handle response with http code
    func handleResponseWithHTTPCode(response:AFDataResponse<Any>, complete:@escaping (_ response:AnyObject, _ status:Bool, _ statusCode: Int?)->Void) {
        self.delegateTimeOut?.handleCode(code: response.response?.statusCode ?? 0)
        switch(response.result) {
        case .success(let value):
            complete(value as AnyObject, true, response.response?.statusCode)
            break
        case .failure(let error):
            self.timeout()
            complete(error.localizedDescription as AnyObject, false, response.response?.statusCode)
            break
        }
    }
    
    func uploadFileOBJ(url:String = "",pathFile:String, complete:@escaping (_ response:AnyObject, _ status:Bool)->Void) {
        // Use Alamofire to upload the image
        let imageToUploadURL = URL(string: pathFile)
        
        sessionManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageToUploadURL!, withName: "file", fileName: "imageFileName.jpg", mimeType: "image/jpeg")
        }, to: URLWihtPath(path: url))
            .responseJSON { response in
                self.handleResponse(response: response, complete: complete)
            }
    }
    
    //MARK:- upload file with param
    func uploadFileUsingDictionaryParams(attachImageArray: Array<ModelUploadFile> ,params:[String: String], path:String, scale:NSInteger, complete:@escaping (_ response:AnyObject, _ status:Bool)->Void) {
        
        let parameter = params
        
        sessionManager.upload(multipartFormData: { multipartFormData in
            for attach in attachImageArray {
                let attachFile = attach
                let image = attachFile.image
                if let imageData = image.jpegData(compressionQuality: CGFloat(scale)) {
                    multipartFormData.append(imageData, withName: attachFile.withName, fileName: attachFile.name , mimeType: "image/jpeg")
                }
            }
            
            for (key, value) in parameter {
                multipartFormData.append(((value ).data(using: .utf8))!, withName: key )
            }
        }, to: URLWihtPath(path: path), method: .post, headers: headers)
            .responseJSON { response in
                self.handleResponse(response: response, complete: complete)
            }
    }
    
    //MARK:- upload file with param
    func uploadFile(attachImageArray: Array<ModelUploadFile> ,params:String, path:String, scale:NSInteger, complete:@escaping (_ response:AnyObject, _ status:Bool)->Void) {
        let json = getJsonString(json: params)
        let parameter = ["payload": json]
        
        sessionManager.upload(multipartFormData: { multipartFormData in
            for attachFile in attachImageArray {
                let image = attachFile.image
                
                if let imageData = image.jpegData(compressionQuality:CGFloat(scale)) {
                    multipartFormData.append(imageData, withName: attachFile.withName, fileName: attachFile.name , mimeType: "image/jpeg")
                }
            }
            
            for (key, value) in parameter {
                multipartFormData.append(((value ).data(using: .utf8))!, withName: key )
            }
        }, to: URLWihtPath(path: path), method: .post, headers: headers)
            .responseJSON { response in
                self.handleResponse(response: response, complete: complete)
            }
    }
}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}
