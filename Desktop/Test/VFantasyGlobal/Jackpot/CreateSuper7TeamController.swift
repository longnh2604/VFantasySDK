//
//  CreateYourGlobalTeamViewController.swift
//  PAN689
//
//  Created by AgileTech on 12/11/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit
import ALCameraViewController
import Photos

class CreateSuper7TeamController: UIViewController, UINavigationControllerDelegate {
    
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
    @IBOutlet weak var btnAction: GradientButton!
    
    var presenter = Super7Presenter(service: Super7Service())
    var isEdit: Bool = false
    
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
        self.lblHeader.text = "Create your Super 9 team".localiz().uppercased()
        self.btnAction.action = "Submit".localiz().uppercased()
        self.btnAction.delegate = self
        nameTextField.delegate = self
        presenter.attachView(view: self)
        if isEdit {
            presenter.getInfoSuper7Team()
            lblHeader.text = "Edit your Super 9 team".localiz().uppercased()
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
            self.presenter.super7CreateModel.logo = image
            currentController.dismiss(animated: true, completion: {
            })
        }
        
        DispatchQueue.main.async {
            currentController.present(cameraViewController, animated: true, completion: nil)
        }
    }
    
    func openLibrary() {
        guard let currentController = UIApplication.getTopController() else {
            return
        }
        let croppingParameters = CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: false, minimumSize: CGSize(width: 120, height: 120))
        let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParameters) { image, asset in
            self.avatarImage.image = image
            self.presenter.super7CreateModel.logo = image
            currentController.dismiss(animated: true, completion: {
            })
        }
        
        DispatchQueue.main.async {
            currentController.present(libraryViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func showAvatarAction(_ sender: Any) {
        changeAvatar()
    }
    
    @IBAction func textDidChanged(_ sender: Any) {
        presenter.super7CreateModel.name = nameTextField.text ?? ""
    }
}

extension CreateSuper7TeamController: GradientButtonDelegate {
    func onClick(_ sender: GradientButton) {
        if presenter.super7CreateModel.name?.isEmpty ?? false {
            return
        }
        if isEdit {
            presenter.editSuper7Team()
        } else {
            presenter.createSuper7Team()
        }
    }
}

extension CreateSuper7TeamController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateSuper7TeamController: Super7GlobalView {
    func reloadSuper7DreamTeams() { }
    
    func reloadPlayerList() { }
    
    func updatedSuper7Team() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func reloadSuper7PitchView() { }
    
    func reloadSuper7Team() {
        self.presenter.super7CreateModel.teamId = presenter.super7Team?.id
        self.presenter.super7CreateModel.avatar = presenter.super7Team?.logo
        self.presenter.super7CreateModel.name = presenter.super7Team?.name
        self.nameTextField.text = presenter.super7Team?.name
        self.avatarImage.setPlayerAvatar(with: presenter.super7Team?.logo ?? "")
    }
    
    func reloadSuper7League() { }
    
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
}
