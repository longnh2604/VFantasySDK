//
//  IBDCTextField.swift
//  TextFieldEffects
//
//  Created by Quach Ngoc Tam on 5/4/18.
//  Copyright © 2018 Raul Riera. All rights reserved.
//

import UIKit

@IBDesignable class IBDCTextField: TextFieldEffects {
    private let borderLayer = CALayer()
    private var textFieldInsets = CGPoint(x: 0, y: 0)
    let colorActive = UIColor.init(red: 208/255.0, green: 198/255.0, blue: 226/255.0, alpha: 1)
    let colorInActive = UIColor.init(red: 59/255.0, green: 63/255.0, blue: 194/255.0, alpha: 1)
    
    /* to change color boder
     by default get color setup in storyboard if forceColor is nil
     */
    var forceColorBorder:UIColor?
    
    /*
     default forceColorPlaceholder is nil
     by default get color setup in storyboad if forceColorPlaceholder is nil
     */
    var forceColorPlaceholder:UIColor?
    
    override func drawViewsForRect(_ rect: CGRect) {
        updateBorder()
        updateBackground()
        updatePlaceHolder()
        layer.insertSublayer(borderLayer, at: 0)
    }
    
    private func updateBorder() {
        borderLayer.frame = rectForBounds(bounds)
        borderLayer.borderWidth = borderSize
        borderLayer.cornerRadius = _cornerRadius
        borderLayer.masksToBounds = true
        
        if forceColorBorder != nil {
            borderLayer.borderColor = forceColorBorder!.cgColor
        }else{
            borderLayer.borderColor = isFirstResponder ? activeBorderColor.cgColor : inactiveBorderColor.cgColor
        }
        
        if isFirstResponder {
            self.layer.masksToBounds = false
            self.layer.shadowRadius = _shadowRadius
            self.layer.shadowColor = shadowBackgroundColor.cgColor
            self.layer.shadowOffset = _shadowOffset
            self.layer.shadowOpacity = _shadowOpacity
        }else{
            self.layer.shadowColor = UIColor.clear.cgColor
            self.layer.shadowOffset = CGSize.init(width: 0.0, height: 0.0)
            self.layer.shadowOpacity = 0.0
        }
        
    }
    
    
    /// update text color placeholder, default get color from storyboard if forceColorPlaceholder is nil
    private func updatePlaceHolder() {
        if isDefault == true {
            self.attributedPlaceholder = NSAttributedString.init(string: self.placeholder ?? "", attributes:[NSAttributedString.Key.foregroundColor: colorInActive])
            return
        }
        
        if forceColorPlaceholder != nil {
            self.attributedPlaceholder = NSAttributedString.init(string: self.placeholder ?? "", attributes:[NSAttributedString.Key.foregroundColor: forceColorPlaceholder!])
        }else{
            let color = isFirstResponder ? colorActive : colorInActive
            self.attributedPlaceholder = NSAttributedString.init(string: self.placeholder ?? "", attributes:[NSAttributedString.Key.foregroundColor: color])
        }
    }
    
    private func rectForBounds(_ bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height)
    }
    
    /*
     force change color border
     */
    func setBolderColor(color:UIColor?) {
        forceColorBorder = color
        updateBorder()
    }
    
    // change background layer
    func setBackgroundLayer(_ color:UIColor) {
        borderLayer.backgroundColor = color.cgColor
    }
    
    /*
     force change color placeholder
     */
    func setColorPlaceHolder(color:UIColor?) {
        forceColorPlaceholder = color
        updatePlaceHolder()
    }
    //MARK:- IBInspectable
    
    @IBInspectable var isDefault: Bool = false {
        didSet {
            updatePlaceHolder()
        }
    }
    
    @IBInspectable var placeHolderFontActive: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            updatePlaceHolder()
        }
    }
    
    @IBInspectable var placeHolderFontInActive: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            updatePlaceHolder()
        }
    }
    
    @IBInspectable var borderSize: CGFloat = 2.0 {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable var _cornerRadius: CGFloat = 0.0 {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable dynamic var textFieldInset: CGPoint = .zero {
        didSet {
            textFieldInsets = textFieldInset
        }
    }
    
    @IBInspectable dynamic var activeBorderColor: UIColor = .clear {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable dynamic var inactiveBorderColor: UIColor = .clear {
        didSet {
            updateBorder()
        }
    }
    
    @IBInspectable dynamic var activeBackgroundColor: UIColor = .clear {
        didSet {
            updateBackground()
        }
    }
    
    @IBInspectable dynamic var inactiveBackgroundColor: UIColor = .clear {
        didSet {
            updateBackground()
        }
    }
    
    @IBInspectable dynamic var shadowBackgroundColor: UIColor = .clear {
        didSet {
            updateBorder()
            updateBackground()
        }
    }
    
    @IBInspectable dynamic var _shadowOpacity: Float = 0.0 {
        didSet {
            updateBorder()
            updateBackground()
        }
    }
    
    @IBInspectable dynamic var _shadowOffset: CGSize = .zero {
        didSet {
            updateBorder()
            updateBackground()
        }
    }
    
    @IBInspectable dynamic var _shadowRadius: CGFloat = 0.0 {
        didSet {
            updateBorder()
            updateBackground()
        }
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: textFieldInsets.x, dy: textFieldInsets.y)
    }
    
    private func updateBackground() {
        if isDefault == true {
            borderLayer.backgroundColor = inactiveBackgroundColor.cgColor
            return
        }
        if isFirstResponder || text!.isNotEmpty {
            borderLayer.backgroundColor = activeBackgroundColor.cgColor
        } else {
            borderLayer.backgroundColor = inactiveBackgroundColor.cgColor
        }
    }
    
    // MARK: - Overrides
    override var bounds: CGRect {
        didSet {
            updateBorder()
            updateBackground()
        }
    }
    
    private func animateViews() {
        UIView.animate(withDuration: 0.2, animations: {
            // Prevents a "flash" in the placeholder
            if self.text!.isEmpty {
                
            }
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.updateBorder()
                self.updatePlaceHolder()
                self.updateBackground()
            }, completion: { _ in
                self.animationCompletionHandler?(self.isFirstResponder ? .textEntry : .textDisplay)
            })
        }
    }
    
    // MARK: - TextFieldEffects
    
    override func animateViewsForTextEntry() {
        animateViews()
    }
    
    override func animateViewsForTextDisplay() {
        animateViews()
    }
}
