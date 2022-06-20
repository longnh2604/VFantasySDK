//
//  Exts+UIViewController.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit
import SwiftDate
import SDWebImage
import MBProgressHUD

extension UIViewController {
    static func createFromNib() -> Self {
        let name = String(describing: self)
        return self.init(nibName: name, bundle: Bundle.sdkBundler())
    }
    
    func startAnimation() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func stopAnimation() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    @objc func popToViewController() {
        guard let nav = self.navigationController else { return }
        
        nav.popViewController(animated: true)
    }
    
    func initBackView(title:String, _ tintColor: UIColor? = nil, _ selector: Selector? = nil) {
        guard let customFont = UIFont(name: FontName.regular, size: FontSize.big) else {
            return
        }
        var widthLeftButton = 100
        if let image = VFantasyCommon.image(named: "ic_back") {
            widthLeftButton = Int(image.size.width + title.sizeOfString(usingFont: customFont).width) + 35
        }
        
        let color = tintColor ?? #colorLiteral(red: 0.2310000062, green: 0.2469999939, blue: 0.7609999776, alpha: 1)
        var icon = "ic_back"
        if color == .white {
            icon = "ic_back_white"
        }
        
        leftBarButtonItem(imageName: icon, title: title.localiz(), frame: CGRect(x: 0, y: 0, width: widthLeftButton, height: 30), colorText: color, font: customFont, target: self, action: selector ?? #selector(popToViewController))
    }
    
    func leftButtonItem(imageName: String, title:String="", colorText:UIColor = UIColor.white, font:UIFont=UIFont.systemFont(ofSize: 14), frame:CGRect, target:Any, action:Selector) {
        let leftBt = UIButton.initWithImageTitleColor(name: imageName, title: title, colorText: colorText, font: font, frame: frame, target: target, action: action)
        
        leftBt.transform = CGAffineTransform(translationX: -10, y: 0)
        
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: leftBt.frame)
        suggestButtonContainer.addSubview(leftBt)
        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
        
        self.navigationItem.leftBarButtonItem = suggestButtonItem
    }
    
    func leftBarButtonItem(imageName: String, frame:CGRect, target:Any, action:Selector) {
        let leftBt = UIButton.initWithImageName(name: imageName, frame: frame, target: target, action: action)
        
        leftBt.transform = CGAffineTransform(translationX: -10, y: 0)
        
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: leftBt.frame)
        suggestButtonContainer.addSubview(leftBt)
        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
        
        self.navigationItem.leftBarButtonItem = suggestButtonItem
    }
    
    func leftBarButtonItem(title: String, frame:CGRect, target:Any, action:Selector) {
        let leftBt = UIButton.initWithTitle(title: title, hexColor: nil, font: UIFont.systemFont(ofSize: 15), frame: frame, target: target, action: action)
        
        leftBt.transform = CGAffineTransform(translationX: 0, y: 0)
        
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: leftBt.frame)
        suggestButtonContainer.addSubview(leftBt)
        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
        
        self.navigationItem.leftBarButtonItem = suggestButtonItem
    }
    
    func leftBarButtonItem(imageName:String, title:String, frame:CGRect, colorText:UIColor, font:UIFont, target:Any, action:Selector) {
        let leftBt = UIButton.initWithImageTitleColor(name: imageName, title: title, colorText: colorText, font: font, frame: frame, target: target, action: action)
        leftBt.transform = CGAffineTransform(translationX: 0, y: 0)
        
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: leftBt.frame)
        suggestButtonContainer.addSubview(leftBt)
        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
        
        self.navigationItem.leftBarButtonItem = suggestButtonItem
    }
    
    func alertWithOk(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localiz().uppercased(), style: .cancel, handler: { action in
            if let escape = completion {
                escape()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func alertWithOkHavingTitle(_ title: String, _ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title.localiz(), message: message.localiz(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localiz().uppercased(), style: .cancel, handler: { action in
            if let escape = completion {
                escape()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if yVelocity < 0 {
            // UP
            if (offset - maxOffset) >= 10.0 {
                loadMore()
            }
        }else if yVelocity > 0 {
            // DOWN
        }else{
            // UN Define
        }
    }
    
    @objc func loadMore() {
        
    }
    
    func alertWithTwoOptions(_ title: String, _ message: String, handleOKAction okCallback: @escaping() -> Void) {
        alertWithTwoOptions(title, message, handleOKAction: okCallback, handleCancelAction: nil)
    }
    
    func alertWithTwoOptions(_ title: String, _ message: String, okAction: String = "ok".localiz().uppercased(), cancelAction: String = "Cancel".localiz(), handleOKAction okCallback: @escaping() -> Void, handleCancelAction cancelCallback: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelAction, style: .cancel, handler: { action in
            if let callBack = cancelCallback {
                callBack()
            }
        }))
        alert.addAction(UIAlertAction(title: okAction, style: .default, handler: { action in
            okCallback()
        }))
        
        if let presentedVC = self.presentedViewController {
            presentedVC.present(alert, animated: true, completion: nil)
        } else {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlert(message:String!) {
        let alert = UIAlertController(title: "", message:message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 2.5
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Hide Keyboard when tap anywhere in view
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    /// Selector for hideKeyboard
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    /// Screen Shot UIViewController
    ///
    /// - Returns: UIImage
    func screenShotMethod() -> UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
