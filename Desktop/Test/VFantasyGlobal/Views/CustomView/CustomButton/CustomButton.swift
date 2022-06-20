//
//  CustomButton.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit
import PureLayout

@IBDesignable class CustomButton: UIButton {
    var shadowAdded: Bool = false
    var colorShadow: UIColor = .black
    var shadowLayer: UIView? = nil
    
    @IBInspectable var cornerRadiusButton: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadiusButton
            layer.masksToBounds = cornerRadiusButton > 0
        }
    }
    
    @IBInspectable var colorShadowButton: UIColor = UIColor(hexString: "#E07000") {
        didSet {
            colorShadow = colorShadowButton
        }
    }
    
    func hidden(_ isHidden: Bool) {
        self.isHidden = isHidden
        self.shadowLayer?.isHidden = isHidden
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if shadowAdded { return }
        shadowAdded = true
        
        self.shadowLayer = UIView(frame: .zero)
        self.shadowLayer?.layer.shadowColor = colorShadow.cgColor
        self.shadowLayer?.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadiusButton).cgPath
        self.shadowLayer?.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.shadowLayer?.layer.shadowOpacity = 1
        self.shadowLayer?.layer.shadowRadius = 9
        self.shadowLayer?.layer.masksToBounds = true
        self.shadowLayer?.clipsToBounds = false
        
        self.superview?.addSubview(self.shadowLayer!)
                
        self.shadowLayer?.autoPinEdge(.top, to: .top, of: self)
        self.shadowLayer?.autoPinEdge(.bottom, to: .bottom, of: self)
        self.shadowLayer?.autoPinEdge(.left, to: .left, of: self)
        self.shadowLayer?.autoPinEdge(.right, to: .right, of: self)
        
        self.superview?.bringSubviewToFront(self)
    }
}
