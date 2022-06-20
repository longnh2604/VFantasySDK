//
//  GradientView.swift
//  EStoryC
//
//  Created by Quang Tran on 5/22/19.
//  Copyright © 2019 quangtran. All rights reserved.
//

import UIKit

enum GradientDirection {
    case horizontal //Default: left to right.
    case vertical //Default: top to bottom
    case topLeftToRightBottom
    case bottomLeftToTopRight
    
    var startPoint: CGPoint {
        switch self {
        case .horizontal:
            return CGPoint(x: 0, y: 0)
        case .vertical:
            return CGPoint(x: 0, y: 0)
        case .topLeftToRightBottom:
            return CGPoint(x: 0, y: 0)
        case .bottomLeftToTopRight:
            return CGPoint(x: 0, y: 1)
        }
    }
    
    var endPoint: CGPoint {
        switch self {
        case .horizontal:
            return CGPoint(x: 1, y: 0)
        case .vertical:
            return CGPoint(x: 0, y: 1)
        case .topLeftToRightBottom:
            return CGPoint(x: 1, y: 1)
        case .bottomLeftToTopRight:
            return CGPoint(x: 1, y: 0)
        }
    }
    
}

class GradientView: UIView {
    
    var direction: GradientDirection = .vertical
    var colors: [CGColor] = [] {
        didSet {
            self.addGradient(colors, direction.startPoint, direction.endPoint)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addGradient(colors, direction.startPoint, direction.endPoint)
    }
    
    func setup(_ direction: GradientDirection, _ colors: [CGColor]) {
        self.direction = direction
        self.colors = colors
    }
    
}

extension UIView {
    func addGradient(_ colors: [CGColor], _ startPoint: CGPoint, _ endPoint: CGPoint) {
        
        if let layers = self.layer.sublayers {
            for layer in layers {
                layer.removeFromSuperlayer()
            }
        }
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = colors
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
        
    }
    
    func addRoundShadow(_ radius: CGFloat) {
        
        self.clipsToBounds = true
        
        layer.cornerRadius = radius
        layer.masksToBounds = false
        
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowColor = UIColor(hexString: "E07000").cgColor
        layer.shadowRadius = 9
        layer.shadowOpacity = 0.3
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
        
    }
}
