//
//  VFantasyGlobal.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

enum Environment {
    case dev, staging, production
    
    func getUrlConfigs() -> (serverUrl: String, socketUrl: String) {
        switch self {
        case .dev:
            return ("http://dev2.vitex.asia", "http://dev2.vitex.asia")
        case .staging:
            return ("https://api.be.stage.panna.sportsfantasygames.be", "https://socket.be.stage.panna.sportsfantasygames.be")
        case .production:
            return ("https://api.be.panna.sportsfantasygames.be", "https://socket.be.panna.sportsfantasygames.be")
        }
    }
}

public class VFantasyManager: NSObject {
    
    public static let shared: VFantasyManager = VFantasyManager()
    
    private var environment: Environment = .staging
    
    override init() {
        super.init()
        loadFonts()
        fixLayout()
    }
    
    private func loadFonts() {
        UIFont.jbs_registerFont(withFilenameString: "SF-Pro-Display-Black.ttf", bundle: Bundle.sdkBundler()!)
        UIFont.jbs_registerFont(withFilenameString: "SF-Pro-Display-BlackItalic.ttf", bundle: Bundle.sdkBundler()!)
        UIFont.jbs_registerFont(withFilenameString: "SF-Pro-Display-Bold.ttf", bundle: Bundle.sdkBundler()!)
        UIFont.jbs_registerFont(withFilenameString: "SF-Pro-Display-Heavy.ttf", bundle: Bundle.sdkBundler()!)
        UIFont.jbs_registerFont(withFilenameString: "SF-Pro-Display-HeavyItalic.ttf", bundle: Bundle.sdkBundler()!)
        UIFont.jbs_registerFont(withFilenameString: "SF-Pro-Display-Regular.ttf", bundle: Bundle.sdkBundler()!)
        UIFont.jbs_registerFont(withFilenameString: "SF-Pro-Display-RegularItalic.ttf", bundle: Bundle.sdkBundler()!)
        
        self.changeLanguage(.vi)
    }
    
    private func fixLayout() {
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0.0
        }
    }
    
    //Handling token for requesting apis
    private var token: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjE2MSwiaXNzIjoiaHR0cDovL2RldjIudml0ZXguYXNpYS9hcGkvdjEvbG9naW4iLCJpYXQiOjE2NTQ3NDMwNjMsImV4cCI6MTY1NzMzNTA2MywibmJmIjoxNjU0NzQzMDYzLCJqdGkiOiJmcDdZSElsN2ZVT3JqaGhCIn0.GdthnTclCBbaODaKiCcJZJfjgBOM9MBtSq5GT3Zu-c4"
    
    private var token_Staging: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjE2MSwiaXNzIjoiaHR0cHM6Ly9hcGkuYmUuc3RhZ2UucGFubmEuc3BvcnRzZmFudGFzeWdhbWVzLmJlL2FwaS92MS9sb2dpbiIsImlhdCI6MTY1NDc0MzgyNiwiZXhwIjoxNjU3MzM1ODI2LCJuYmYiOjE2NTQ3NDM4MjYsImp0aSI6ImFVVEVnNFpuelhteDZ6YjAifQ.vgVa75cYc551M7aJN8uuSpOwHhD2OvqeMCcgr-fjqOE"
    
    public func getBaseUrl() -> String {
        return environment.getUrlConfigs().serverUrl
    }
    
    public func getSocketUrl() -> String {
        return environment.getUrlConfigs().socketUrl
    }
    
    public func getToken() -> String {
        return environment == .dev ? token : token_Staging
    }
    
    public func getUserId() -> Int {
        return 0
    }
    
    public func updateToken(_ token: String) {
        self.token = token
    }

    //Handling change languages
    public func changeLanguage(_ language: Languages) {
        MNLocalizable.shared.setLanguage(language: language)
    }
    
    func isVietnamese() -> Bool {
        return MNLocalizable.shared.currentLanguage == .vi
    }
}

//MARK: - Functions -
extension VFantasyManager {
    public func showGlobalView() {
        guard let topVC = UIApplication.getTopController() else { return }
        self.checkGlobalTeamCompleted(topVC) { isCompleted, teamId in
            if isCompleted {
                guard let globalVC = instantiateViewController(storyboardName: .newGlobal, withIdentifier: NewGlobalController.className) as? NewGlobalController else { return }
                globalVC.changeTeamId(teamId)
                let naviGlobal = UINavigationController(rootViewController: globalVC)
                naviGlobal.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async {
                    topVC.present(naviGlobal, animated: true, completion: nil)
                }
            } else {
                guard let globalVC = instantiateViewController(storyboardName: .global, withIdentifier: GlobalViewController.className) as? GlobalViewController else { return }
                globalVC.changeTeamId(teamId)
                let naviGlobal = UINavigationController(rootViewController: globalVC)
                naviGlobal.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async {
                    topVC.present(naviGlobal, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    private func checkGlobalTeamCompleted(_ topVC: UIViewController, _ completion: @escaping (_ isCompleted: Bool, _ teamId: Int) -> Void) {
        var isCompletedTeam = false
        var teamId = 0
        topVC.startAnimation()
        GlobalServices().getMyTeam { (response, success) in
            if let result = response as? GlobalMyTeam, let res = result.response {
                if let isCompleted = res.isCompleted, isCompleted == true {
                    isCompletedTeam = true
                }
                teamId = result.response?.id ?? 0
            }
            topVC.stopAnimation()
            completion(isCompletedTeam, teamId)
        }
    }
}

//MARK: - Jackpot -
extension VFantasyManager {
    #if Jackpot
    public func showJackpotVC() {
        // init super7
        guard let topVC = UIApplication.getTopController() else { return }
        guard let super7ViewController = instantiateViewController(storyboardName: .super7, withIdentifier: Super7Controller.className) as? Super7Controller else { return }
        let naviSuper7 = UINavigationController(rootViewController: super7ViewController)
        naviSuper7.setNavigationBarHidden(true, animated: false)
        naviSuper7.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            topVC.present(naviSuper7, animated: true, completion: nil)
        }
    }
    #endif
}
