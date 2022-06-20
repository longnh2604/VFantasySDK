//
//  PopupInfoMeStatusView.swift
//  zmooz
//
//  Created by Quang Tran on 8/29/19.
//  Copyright © 2019 quangtran. All rights reserved.
//

import UIKit

typealias ClosedCompletion = () -> Void
typealias RedeemCodeCompletion = (_ code: String) -> Void

class PopupRedeemCodeLeague: UIView {
    
    @IBOutlet weak var blurView: GradientView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tfCode: IBDCTextField!
    @IBOutlet weak var contentToCenterLayout: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    
    var closedCompletion: ClosedCompletion?
    var redeemCompletion: RedeemCodeCompletion?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.setup(.topLeftToRightBottom, [UIColor(hexString: "2324BF").cgColor, UIColor(hexString: "935BBD").cgColor])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadViewFromXIB()
    }
    
    func loadViewFromXIB() {
        let views = Bundle.sdkBundler()?.loadNibNamed("PopupRedeemCodeLeague", owner: self, options: nil)
        let contentView = views?.first as? UIView
        contentView?.backgroundColor = .clear
        contentView?.frame =  self.bounds
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        self.mainView.alpha = 0.0
        self.blurView.alpha = 0.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        self.addGestureRecognizer(tapGesture)
        self.tfCode.textAlignment = .center
        self.tfCode.placeholder = "fill_league_code".localiz()
        
        self.btnOk.setTitle("ok".localiz(), for: .normal)
        self.lblTitle.text = "Join league".localiz()
        self.lblNote.text = "Please enter the league code here to join it".localiz()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationKeyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationKeyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func notificationKeyboardWillShow(_ sender: Notification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let heightKeyboard = keyboardRectangle.height
            self.contentToCenterLayout.constant = -heightKeyboard/2
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    @objc func notificationKeyboardWillHide(_ sender: Notification) {
        self.contentToCenterLayout.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func onTap(_ sender: Any) {
        self.hide(true)
    }
    
    @IBAction func onOK(_ sender: Any) {
        let value = tfCode.text ?? ""
        if value.isEmpty {
            guard let topVC = UIApplication.getTopController() else { return }
            topVC.showAlert(message: "The code cannot be empty. Please try again!".localiz())
            return
        }
        if let redeem = self.redeemCompletion {
            redeem(value)
        }
        hide(true)
    }
    
    @IBAction func onTextChanged(_ sender: Any) {
        let text = tfCode.text ?? ""
        tfCode.text = text.uppercased()
    }
    
    func show(in superView: UIView, _ animated: Bool) {
        superView.addSubview(self)
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.layoutIfNeeded()
            self.blurView.alpha = 0.9
            self.mainView.alpha = 1.0
        }
    }
    
    func hide(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        if let close = self.closedCompletion {
            close()
        }
        UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
            self.blurView.alpha = 0.0
            self.mainView.alpha = 0.0
        }) { (success) in
            self.removeFromSuperview()
        }
    }
    
}

