//
//  CreateYourGlobalTeamViewController.swift
//  PAN689
//
//  Created by AgileTech on 12/11/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit
import Photos
import ALCameraViewController

protocol CreateYourGlobalTeamViewControllerDelegate {
    func onCreateNewTeamSuccessful(_ teamId: Int)
}

class CreateYourGlobalTeamViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.layer.cornerRadius =  20
            nameTextField.layer.borderColor = UIColor(hexString: "#EDE9F3").cgColor
            nameTextField.layer.borderWidth = 1
            let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 2.0))
            nameTextField.leftView = leftView
            nameTextField.leftViewMode = .always
        }
    }
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    
    var presenter = GlobalLeaguePresenter(service: GlobalServices())
    var isEdit: Bool = false
    var teamId: Int = 0
    var delegate: CreateYourGlobalTeamViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: true)
        let newBtn = UIBarButtonItem(title: "Cancel".localiz(), style: .plain, target: self, action: #selector(onBack))
        newBtn.tintColor = UIColor(hexString: "#4B4EC7")
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = newBtn
        nameTextField.delegate = self
        presenter.attachView(view: self)
        presenter.teamId = self.teamId
        lblHeader.text = "CREATE YOUR GLOBAL TEAM".localiz().uppercased()
        if isEdit {
            presenter.getInfoMyTeam()
            lblHeader.text = "EDIT YOUR GLOBAL TEAM".localiz().uppercased()
        }
    }
    
    @objc func onBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func changeAvatar() {
        guard let topVC = UIApplication.getTopController() else { return }
        VFantasyCommon.showAlertPickingPhoto(in: topVC) { action in
            if action == .camera {
                self.showCamera()
            } else if action == .photo {
                self.openLibrary()
            }
        }
    }
    
    func showCamera() {
        guard let currentController = UIApplication.getTopController() else {
            return
        }
        let cameraViewController = CameraViewController {image, asset in
            // Do something with your image here.
            self.avatarImage.image = image
            self.presenter.globalLeague.logo = image
            currentController.dismiss(animated: true, completion: {
            })
        }
        
        currentController.present(cameraViewController, animated: true, completion: nil)
    }
    
    func openLibrary() {
        guard let currentController = UIApplication.getTopController() else {
            return
        }
        let croppingParameters = CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: false, minimumSize: CGSize(width: 120, height: 120))
        let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParameters) { image, asset in
            self.avatarImage.image = image
            self.presenter.globalLeague.logo = image
            currentController.dismiss(animated: true, completion: {
            })
        }
        
        currentController.present(libraryViewController, animated: true, completion: nil)
    }
    
    @IBAction func showAvatarAction(_ sender: Any) {
        changeAvatar()
    }
    @IBAction func submitAction(_ sender: Any) {
        if presenter.globalLeague.name?.isEmpty ?? false {
            return
        }
        if isEdit {
            presenter.editGlobalLeague()
        } else {
            presenter.createGlobalLeague()
        }
    }
    
    @IBAction func textDidChanged(_ sender: Any) {
        presenter.globalLeague.name = nameTextField.text ?? ""
    }
}
extension CreateYourGlobalTeamViewController: GlobalLeagueView {
    func gotoTransferPlayer(_ deletedPlayer: [Player]) {
        
    }
    
    func reloadMyTeams() {
        
    }
    
    func reloadMyLeagues() {
        
    }
    
    func goBackGlobal(_ teamId: Int) {
        self.delegate?.onCreateNewTeamSuccessful(teamId)
        self.onBack()
    }
    
    func startLoading() {
        startAnimation()
    }
    
    func finishLoading() {
        stopAnimation()
    }
    
    func alertMessage(_ message: String) {
        stopAnimation()
        showAlert(message: message)
    }
    
    func reloadGlobalTeam(_ isSwitchTeam: Bool) {
        self.nameTextField.text = presenter.globalLeague.name
        self.avatarImage.setPlayerAvatar(with: presenter.globalLeague.avatar ?? "")
    }
    
    func reloadData() {
        
    }
    
    func gotoCreateTeam() {
        
    }
    
    func gotoPickPlayers() {
        
    }
    
    func redeemLeague(_ data: LeagueDatum?) {
        
    }
    
}
extension CreateYourGlobalTeamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateYourGlobalTeamViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
