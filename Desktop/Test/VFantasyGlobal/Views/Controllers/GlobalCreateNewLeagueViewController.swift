//
//  GlobalCreateNewLeagueViewController.swift
//  PAN689
//
//  Created by David Tran on 12/30/19.
//  Copyright © 2019 PAN689. All rights reserved.
//

import UIKit
import Photos
import ALCameraViewController

class GlobalCreateNewLeagueViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var leagueLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var gameweekTitleLabel: UILabel!
    @IBOutlet weak var gameweekLabel: UILabel!
    @IBOutlet weak var leagueTextField: IBDCTextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var descBgView: UIView!
    @IBOutlet weak var descPlaceholderLabel: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var createButton: CustomButton!
    
    var presenter: GlobalCreateNewLeaguePresenter!
    var isCreate: Bool = false
    
    var successUpdatingLeagueClosure: ((_ league: GlobalLeagueModelView) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.attachView(view: self)
        presenter.getGameweeks()
        updateUILeague()
    }
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        changeAvatar()
    }
    
    @IBAction func gameweekButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        showPickerViewSelectGameweek()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if isCreate {
            navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func createLeagueButtonTapped(_ sender: Any) {
        presenter.leagueName = leagueTextField.text ?? ""
        presenter.leagueDesc = descTextView.text ?? ""
        let message = presenter.validateInputData()
        if !message.isEmpty {
            self.showAlert(message: message)
        }
        self.view.endEditing(true)
    }

    func setSelectedImage(_ image: UIImage?) {
        avatarImgView.image = image
        presenter.startUploadingAvatar()
    }
    
    func setSelectedGameweek(_ gameweek: GameWeek) {
        gameweekLabel.text = gameweek.title
    }
    
    func setupUI() {
        leagueLabel.text = "LEAGUE NAME & LOGO *".localiz()
        descLabel.text = "DESCRIPTION".localiz()
        gameweekTitleLabel.text = "STARTING GAMEWEEK".localiz()
        leagueTextField.placeholder = "enter_league_name".localiz()
        descPlaceholderLabel.text = "description_placeholder_league".localiz()
        let title = presenter.globalLeagueMode == .new ? "create_league_1".localiz().uppercased() : "update_league".localiz()
        createButton.setTitle(title, for: .normal)
        headerLabel.text = presenter.globalLeagueMode == .new ? "create_new_league".localiz().uppercased() : "update_league".localiz()
    }
    
    func updateUILeague() {
        if presenter.globalLeagueMode == .update {
            leagueTextField.text = presenter.leagueModel.name
            descTextView.text = presenter.leagueModel.desc
            avatarImgView.sd_setImage(with: URL(string: presenter.leagueModel.avatar), completed: nil)
            gameweekLabel.text = presenter.leagueModel.gameweekTitle
            descPlaceholderLabel.isHidden = !presenter.leagueModel.desc.isEmpty
        }
    }
}

extension GlobalCreateNewLeagueViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        descBgView.backgroundColor = UIColor(hexString: "DDD7E9")
        if descTextView.text.isEmpty {
            descTextView.text = ""
            hidePlaceholderLabel()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        descBgView.backgroundColor = .white
        if descTextView.text.isEmpty {
            showPlaceholderLabel()
        }
        descPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
    
    private func showPlaceholderLabel() {
        descPlaceholderLabel.alpha = 1.0
        descPlaceholderLabel.isHidden = false
        descPlaceholderLabel.textColor = UIColor(hexString: "3A3DBD")
    }
    
    private func hidePlaceholderLabel() {
        descPlaceholderLabel.alpha = 0.7
        descPlaceholderLabel.isHidden = false
        descPlaceholderLabel.textColor = .lightGray
    }
}

extension GlobalCreateNewLeagueViewController {
    
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: false, minimumSize: CGSize(width: 60, height: 60))
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
        let cameraViewController = CameraViewController { [weak self] image, asset in
            if image != nil {
                self?.presenter?.selectedImage = image
                self?.presenter?.filename = self?.filename(of: asset) ?? ""
                self?.setSelectedImage(image)
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        self.present(cameraViewController, animated: true, completion: nil)
    }
    
    func openLibrary() {
        let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParameters) { [weak self] image, asset in
            if image != nil {
                self?.presenter?.selectedImage = image
                self?.presenter?.filename = self?.filename(of: asset) ?? ""
                self?.setSelectedImage(image)
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        self.present(libraryViewController, animated: true, completion: nil)
    }
    
    private func filename(of asset: PHAsset?) -> String {
        guard let asset = asset else { return "" }
        return PHAssetResource.assetResources(for: asset).first?.originalFilename ?? ""
    }
}

extension GlobalCreateNewLeagueViewController {
    
    func showPickerViewSelectGameweek() {
        let alert = UIAlertController(style: .alert, title: "STARTING GAMEWEEK".localiz(), message: "")
        
        let numberOfGameweek: [String] = presenter.gameweeks.compactMap ({ $0.title })
        let pickerViewValues: [[String]] = [numberOfGameweek]
        let selected = selectedIndex(if: numberOfGameweek)
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: selected)
        alert.addPickerView(values: pickerViewValues,
                            initialSelection: pickerViewSelectedValue) { [weak self] vc, picker, index, values in
                                print(index, values)
                                guard let self = self else { return }
                                let gameweek = self.presenter.gameweeks[index.row]
                                self.setSelectedGameweek(gameweek)
                                self.presenter?.selectedGameweek = gameweek
        }
        alert.addAction(title: "Done".localiz(), style: .cancel)
        alert.show()
    }
    
    private func selectedIndex(if gameweeks: [String]) -> Int {
        if presenter.globalLeagueMode == .new {
            return gameweeks.indexes(of: presenter.selectedGameweek?.title ?? "").first ?? 0
        } else {
            if let first = gameweeks.first(where: { $0 == presenter.leagueModel.gameweekTitle }) {
                return gameweeks.indexes(of: first).first ?? 0
            }
        }
        return 0
    }
}

extension GlobalCreateNewLeagueViewController: GlobalNewLeagueView {
    
    func startLoading() {
        startAnimation()
    }
    
    func alertMessage(_ message: String) {
      stopAnimation()
      showAlert(message: message)
    }
    
    func finishLoading() {
        stopAnimation()
    }
    
    func finishLoadingGameweeks() {
        stopAnimation()
        if presenter.globalLeagueMode == .new {
            if let gameweek = presenter.gameweeks.first {
                presenter.selectedGameweek = gameweek
                gameweekLabel.text = gameweek.title
            }
        } else {
            if let gameweek = presenter.gameweeks.first(where: { $0.id == presenter.leagueModel.gameweekId }) {
                presenter.selectedGameweek = gameweek
                gameweekLabel.text = gameweek.title
            } else {
                gameweekLabel.text = presenter.leagueModel.gameweekTitle
            }
        }
    }
    
    func successCreateGlobalLeague() {
        stopAnimation()
        
        self.alertWithOk("Create Successfully".localiz()) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func successUpdateGlobalLeague(_ league: GlobalLeagueModelView) {
        stopAnimation()
        successUpdatingLeagueClosure?(league)
        
        self.alertWithOk("Update Successfully".localiz()) { [weak self] in
            self?.cancelButtonTapped(league)
        }
    }
}

extension GlobalCreateNewLeagueViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
