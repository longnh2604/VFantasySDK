//
//  GradientButton.swift
//  PAN689
//
//  Created by Quang Tran on 12/14/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

@objc protocol GradientButtonDelegate {
    func onClick(_ sender: GradientButton)
}

class GradientButton: UIView {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var gradientView: GradientView!

    weak var delegate: GradientButtonDelegate?
    var action: String = "" {
        didSet {
            signInButton.setTitle(action, for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.setup(.bottomLeftToTopRight, [UIColor(hex: 0xF76B1C).cgColor, UIColor(hex: 0xFAD961).cgColor])
        gradientView.layer.cornerRadius = 8.0
        gradientView.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
        
    fileprivate func initialize() {
        let views = Bundle.sdkBundler()?.loadNibNamed("GradientButton", owner: self, options: nil)
        let contentView = views?.first as? UIView
        contentView?.backgroundColor = .clear
        contentView?.frame = self.bounds
        contentView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        setup()
    }
    
    private func setup() {
        signInButton.setTitleColor(.white, for: .normal)
    }

    @IBAction func onAction(_ sender: Any) {
        self.delegate?.onClick(self)
    }
}
