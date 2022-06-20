//
//  GlobalCreateNewLeaguePresenter.swift
//  VFantasyGlobal
//
//  Created by User on 26/05/2022.
//
import UIKit

enum GlobalLeagueMode: Int {
    case new = 0
    case update = 1
}

protocol GlobalNewLeagueView: BaseViewProtocol {
    func finishLoadingGameweeks()
    func successCreateGlobalLeague()
    func successUpdateGlobalLeague(_ league: GlobalLeagueModelView)
}

class GlobalCreateNewLeaguePresenter: NSObject {
    var service: GlobalNewLeagueService?
    var superView: GlobalNewLeagueView?
    var gameweeks = [GameWeek]()
    var selectedImage: UIImage?
    var filename = ""
    var selectedGameweek: GameWeek?
    var leagueName = ""
    var leagueDesc = ""
    var storageName = ""
    var teamId = 0
    var globalLeagueMode = GlobalLeagueMode.new
    var leagueModel = GlobalLeagueModelView()
    
    init(service: GlobalNewLeagueService) {
        self.service = service
    }
    
    func attachView(view: GlobalNewLeagueView) {
        self.superView = view
    }
    
    func getGameweeks() {
        superView?.startLoading()
        service?.getAllGameweekList(callback: { (result, status) in
          self.handleGameweekCallback(result, status)
        })
    }
    
    private func handleGameweekCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleGameweeksResponseSuccess(result)
        }
    }
    
    private func handleGameweeksResponseSuccess(_ response: AnyObject) {
        if let result = response as? GlobalGameWeekModel {
            guard let meta = result.meta else {
                superView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    superView?.finishLoading()
                    return
                }
                superView?.alertMessage(message.localiz())
                return
            }
            
            self.gameweeks = result.response?.data ?? []
            superView?.finishLoadingGameweeks()
        }
    }
    
    func validateInputData() -> String {
        if leagueName.isEmpty {
            return "required_fields".localiz()
        }
        
//        if globalLeagueMode == .new && selectedImage == nil {
//            return "required_fields".localiz()
//        }
        
        startUploadingLeagueInfo()
        return ""
    }
    
    private func startUploadingLeagueInfo() {
        superView?.startLoading()
        switch globalLeagueMode {
        case .new:
            createGlobalLeagueInfo()
        case .update:
            updateGlobalLeagueInfo()
        }
    }
    
    func startUploadingAvatar() {
        guard let image = selectedImage else { return }
        superView?.startLoading()
        let request = RequestUploadFile(filreName: filename,
                                        storage: StorageKey.league,
                                        imageLocal: image)
        
        UploadFileService().uploadFile(request) { [weak self] (response, status) in
            if status == true {
                if let data = response as? UploadFileData {
                    self?.storageName = data.response?.fileMachineName ?? ""
                }
            }
            self?.superView?.finishLoading()
        }
    }
}

// MARK: - Create new Global League

extension GlobalCreateNewLeaguePresenter {
    
    func createGlobalLeagueInfo() {
        let model = GlobalLeagueModelView(name: leagueName,
                                          avatar: storageName,
                                          desc: leagueDesc,
                                          gameweekId: selectedGameweek?.id ?? 0)
        service?.createNewLeague(model, callBack: { [weak self] (result, status) in
            self?.handleCreateLeagueCallback(result, status)
        })
    }
    
    private func handleCreateLeagueCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleCreateLeagueResponseSuccess(result)
        }
    }
    
    private func handleCreateLeagueResponseSuccess(_ response: AnyObject) {
        if let result = response as? GlobalLeagueModel {
            guard let meta = result.meta else {
                superView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    superView?.finishLoading()
                    return
                }
                superView?.alertMessage(message.localiz())
                return
            }
            
            superView?.successCreateGlobalLeague()
        }
    }
}

// MARK: - Edit Global League

extension GlobalCreateNewLeaguePresenter {
    
    func updateGlobalLeagueInfo() {
        let gameweekId = selectedGameweek?.id ?? leagueModel.id
        let gameweekTitle = selectedGameweek?.title ?? leagueModel.gameweekTitle
        let model = GlobalLeagueModelView(id: leagueModel.id,
                                          name: leagueName,
                                          avatar: storageName,
                                          desc: leagueDesc,
                                          gameweekId: gameweekId,
                                          gameweekTitle: gameweekTitle)
        service?.updateGlobalLeague(model, callBack: { [weak self] (result, status) in
            self?.handleUpdateLeagueCallback(result, status)
        })
    }
    
    private func handleUpdateLeagueCallback(_ result: AnyObject, _ status: Bool) {
        if !status {
            CommonResponse.handleResponseFail(result, superView)
        } else {
            self.handleUpdateLeagueResponseSuccess(result)
        }
    }
    
    private func handleUpdateLeagueResponseSuccess(_ response: AnyObject) {
        if let result = response as? GlobalLeagueModel {
            guard let meta = result.meta else {
                superView?.finishLoading()
                return
            }
            if meta.success == false {
                guard let message = meta.message else {
                    superView?.finishLoading()
                    return
                }
                superView?.alertMessage(message.localiz())
                return
            }
            let league = GlobalLeagueModelView(league: result.response)
            superView?.successUpdateGlobalLeague(league)
        }
    }
}
