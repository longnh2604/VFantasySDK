//
//  CustomCellPlayerList.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/13/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

protocol CustomCellPlayerListDelegate: NSObjectProtocol {
    func onRemove(_ cell: CustomCellPlayerList)
    func onAdd(_ cell: CustomCellPlayerList)
}

class CustomCellPlayerList: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var club: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var minorPosition: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var displays: [FilterData]?
    var playerSelected = false
    var playerListType = PlayerListType.playerList
    
    weak var delegate: CustomCellPlayerListDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        //initView()
    }
    
    func loadView(model: PlayerModelView) {
        self.name.text = model.name
        self.club.text = model.club
        if let position = model.position {
            self.position.setPosition(position)
        }
        
        if let minorPosition = model.minorPosition {
            if minorPosition != -1 {
                self.minorPosition.isHidden = false
                self.minorPosition.setPosition(minorPosition)
            } else {
                self.minorPosition.isHidden = true
            }
        }
        
        playerSelected = model.selected ?? false
    }
    
    func createLabel() -> UILabel {
        let temp = UILabel()
        temp.font = UIFont(name: FontName.regular, size: 13)
        temp.textColor = #colorLiteral(red: 0.5137254902, green: 0.4862745098, blue: 0.5254901961, alpha: 1)
        temp.textAlignment = .center
        return temp
    }
        
    func createImageView() -> UIImageView {
        let temp = UIImageView()
        temp.tag = 1000
        temp.frame = CGRect.zero
        return temp
    }
    
    func createButton() -> CustomButtonKey {
        let button = CustomButtonKey()
        button.setTitleColor(#colorLiteral(red: 0.5137254902, green: 0.4862745098, blue: 0.5254901961, alpha: 1), for: .normal)
        
        button.titleLabel?.font = UIFont(name: FontName.bold, size: 13)
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.frame = CGRect.zero
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        return button
    }
    
    private func addButton(label: UILabel) {
        if playerListType == .playerPool {
            let addButton = self.createAddButton()
            addButton.autoPinEdge(.top, to: .bottom, of: label, withOffset: 5)
            addButton.autoAlignAxis(.vertical, toSameAxisOf: label)
        }
    }
    
    func loadData(displays: [FilterData], model: PlayerModelView) {
        self.displays = displays
        let maxColums = 3
        
        stackView.removeAllArrangedSubviews()
        
        if let statusPoint = self.contentView.viewWithTag(1000) {
            statusPoint.removeFromSuperview()
        }
        
        for index in 0 ..< maxColums {
            guard index < displays.count else {
                let label = self.createLabel()
                stackView.addArrangedSubview(label)
                if index == maxColums - 1 {
                    addButton(label: label)
                }
                continue
            }
            
            let data = displays[index]
            let key = data.key
            
            if let text = model.value(forKey: key) as? String {
                // create lable name
                let label = self.createLabel()
                
                if key == DisplayKey.value {
                    // show special with value of layer
                    if let intText = Int(text) {
                        label.text = intText.priceDisplay
                    }
                } else {
                    label.text = text
                }
                
                stackView.addArrangedSubview(label)
                
                if index == maxColums - 1 {
                    addButton(label: label)
                }
                
                // create status up, down for key Point
                if key == DisplayKey.point {
                    let statusImg = self.createImageView()
                    if let status = model.rank_status {
                        if status == -1 {
                            statusImg.image = VFantasyCommon.image(named: "ic_ArrowDown.png")
                        } else if status == 1 {
                            statusImg.image = VFantasyCommon.image(named: "ic_ArrowUpward_friend")
                        } else {
                            statusImg.image = nil
                        }
                    }
                    self.contentView.addSubview(statusImg)
                    
                    statusImg.autoSetDimensions(to: CGSize.init(width: 16, height: 16))
                    statusImg.autoPinEdge(.top, to: .bottom, of: label, withOffset: 5)
                    statusImg.autoAlignAxis(.vertical, toSameAxisOf: label)
                }
            }
        }
    }
    
    func setTextLabel(text: String, key: String, lable: UILabel) {
        if key == DisplayKey.value {
            if let intText = Int(text) {
                lable.text = intText.priceDisplay
            }
        } else {
            lable.text = text
        }
    }
    
    func addRemoveButton() {
        initImageButton(VFantasyCommon.image(named: "ic_remove_plain.png"), completion: {
            self.delegate?.onRemove(self)
        })
    }
    
    func createAddButton() -> UIButton {
        var addButton = UIButton()
        if playerSelected {
            addButton = initImageButton(VFantasyCommon.image(named: "ic_added_player.png")) {
                print("do nothing")
            }
        } else {
            addButton = initImageButton(VFantasyCommon.image(named: "ic_add_player.png"), completion: {
                self.delegate?.onAdd(self)
            })
        }
        return addButton
    }
    
    func addAddButton() {
        if playerSelected {
            initImageButton(VFantasyCommon.image(named: "ic_added_player.png")) {
                print("do nothing")
            }
        } else {
            initImageButton(VFantasyCommon.image(named: "ic_add_player.png"), completion: {
                self.delegate?.onAdd(self)
            })
        }
    }
    
    func removeAddButton() {
        for view in contentView.subviews {
            if view.tag == 100 {
                view.removeFromSuperview()
            }
        }
    }
    
    @discardableResult
    private func initImageButton(_ image: UIImage?, completion: @escaping () -> Void) -> UIButton {
        let button = UIButton(frame: CGRect.zero)
        button.setImage(image, for: .normal)
        button.tag = 100
        button.addAction {
            completion()
        }
        contentView.addSubview(button)
        
        button.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        button.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
        button.autoMatch(.width, to: .height, of: button)
        button.autoSetDimension(.height, toSize: 44)
        
        return button
    }
}
