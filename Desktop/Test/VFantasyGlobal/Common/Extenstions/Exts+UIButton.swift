//
//  VFantasyGlobalExtension.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

extension UIButton {
    /// initWithImageName
    ///
    /// - Parameters:
    ///   - name: String
    ///   - frame: CGRect
    ///   - target: Any
    ///   - action: Selecter
    class func initWithImageName(name: String, frame:CGRect, target:Any, action:Selector) -> UIButton {
        let button = UIButton.init(type: .custom)
        button.frame = frame
        button.setImage(VFantasyCommon.image(named: name), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
    
    class func initWithTitle(title: String?, hexColor: String?, font:UIFont?, frame:CGRect, target:Any, action:Selector) -> UIButton {
        let button = UIButton.init(type: .custom)
        button.frame = frame
        if title != nil {
            button.setTitle(title, for: .normal)
        }
        if hexColor != nil {
            button.setTitleColor(UIColor(hexString: hexColor!), for: .normal)
        }
        if font != nil {
            button.titleLabel?.font = font
        }
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
    
    class func initWithImageTitleColor(name: String, title:String = "", colorText:UIColor = UIColor.white, font:UIFont=UIFont.systemFont(ofSize: 14), frame:CGRect, target:Any, action:Selector) -> UIButton {
        let button = UIButton.init(type: .custom)
        button.frame = frame
        let image = VFantasyCommon.image(named: name)
        button.setImage(image, for: .normal)
        if !title.isEmpty {
            button.setTitle(title, for: .normal)
            button.setTitleColor(colorText, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
        }
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
    
    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
                return
            }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
}
