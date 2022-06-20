//
//  DropdownSelectionView.swift
//  PAN689
//
//  Created by Dinh Vu Nam on 6/20/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

protocol DropdownSelectionViewDelegate: NSObjectProtocol {
    func didChangeSort(_ tag: Int)
    func didTapDropdown(_ tag: Int)
}

class DropdownSelectionView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var imageBackground: UIImageView!
    
    var parentViewController: UIViewController?
    var data: [CheckBoxData]?
    var selectedData: CheckBoxData?
    weak var delegate: DropdownSelectionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        let _ = self.createFromNib()
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(content)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dropdownButton.addTarget(self, action: #selector(onDropdown), for: .touchUpInside)
    }
    
    private func setSelectedData(_ data: [CheckBoxData], _ isUppercased: Bool = false) {
        //If no selected box
        if selectedData == nil {
            //Select the first item
            if let first = data.first {
                selectedData = first
            }
        }
        //Set title
        titleLabel.text = isUppercased ? selectedData?.name?.uppercased() : selectedData?.name
    }
    
    func setData(_ data: [CheckBoxData], _ style: DropdownViewStyle = .blue, isUppercased: Bool = false) {
        self.data = data
        updateStyle(style)
        
        //Set selected data = selected box
        for box in data where box.selected {
            selectedData = box
            break
        }
        setSelectedData(data, isUppercased)
    }
    
    func updateSelection(_ selection: String) {
        if let data = data {
            selectedData = data.first { $0.key == selection }
            setSelectedData(data)
        }
    }
    
    func updateStyle(_ style: DropdownViewStyle) {
        if style == .white {
            contentView.backgroundColor = .white
            titleLabel.textColor = #colorLiteral(red: 0.2274509804, green: 0.2431372549, blue: 0.7607843137, alpha: 1)
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = #colorLiteral(red: 0.2899999917, green: 0.2899999917, blue: 0.2899999917, alpha: 0.3000000119).cgColor
        } else {
            titleLabel.textColor = .white
            imageBackground.image = VFantasyCommon.image(named: "ic_bgr_leagures")
        }
    }
    
    func disableSelection() {
        dropdownButton.isUserInteractionEnabled = false
        dropdownButton.isHidden = true
    }
    
    @objc func onDropdown() {
        delegate?.didTapDropdown(tag)
    }
    
    func showCheckBox(_ hiddenWhenSelect: Bool = false) {
        if let controller = UIApplication.getTopController(), let data = data {
            if let vc = instantiateViewController(storyboardName: .common, withIdentifier: "CheckBoxViewController") as? CheckBoxViewController {
                vc.delegate = self
                vc.updateItems(data, self.selectedData)
                
                let formSheetController = MZFormSheetPresentationViewController(contentViewController: vc)
                formSheetController.presentationController?.contentViewSize = CGSize(width:controller.view.frame.size.width - 40, height: vc.getHeight())
                formSheetController.presentationController?.shouldCenterVertically = true
                formSheetController.presentationController?.shouldCenterHorizontally = true
                formSheetController.contentViewControllerTransitionStyle = .fade
                formSheetController.presentationController?.didTapOnBackgroundViewCompletionHandler = {location in
                    formSheetController.dismiss(animated: true, completion: nil)
                }
                formSheetController.allowDismissByPanningPresentedView = true
                formSheetController.contentViewCornerRadius = 20
                formSheetController.willPresentContentViewControllerHandler = { vc in
                    
                }
                controller.present(formSheetController, animated: true, completion: nil)
            }
        }
    }
}

extension DropdownSelectionView : CheckBoxViewControllerDelegate {
    func didClickApply(_ item: CheckBoxData) {
        self.selectedData = item
        titleLabel.text = item.name
        
        delegate?.didChangeSort(self.tag)
    }
}
