//
//  BasePopupView.swift
//  its_ready
//
//  Created by Quang Tran on 10/27/20.
//  Copyright © 2020 Quang Tran. All rights reserved.
//

import UIKit

@objc protocol BasePopupDataSource {
    @objc func totalHeight() -> CGFloat
    @objc optional func dismissWhenTouchUpOutside() -> Bool //Default = false
    @objc optional func disableDismissWhenDragging() -> Bool //Default = false
}

@objc protocol BasePopupKeyboardDataSource {
    @objc optional func isOverWhenKeyboardShowing() -> Bool //Default false. If true -> will ignore expandHeightWhenKeyboardShow()
    @objc optional func expandHeightWhenKeyboardShow() -> CGFloat //Default = 0.0
}

typealias BasePopupDidHide = () -> Void
typealias BasePopupAction = (_ ok: Bool) -> Void

class BasePopupView: UIView {

    private var isSearching: Bool = false
    private var isGesture: Bool = false
    private var pointTouched: CGPoint = .zero
    private var lastPoint: CGPoint = .zero
    private var currentHeight: CGFloat = 0.0
    private var totalHeightLayout: CGFloat = 0.0
    private var alphaView: CGFloat = 0.8
    private var panGesture: UIPanGestureRecognizer?
    private var dataSource: BasePopupDataSource?
    private var keyboardDataSource: BasePopupKeyboardDataSource?
    var completion: BasePopupDidHide?

    lazy var opacityView: UIView = {
        var view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }()
    
    lazy var indicatorView: UIView = {
        var view = UIView(frame: CGRect(x: (UIScreen.SCREEN_WIDTH - 36)/2.0, y: 0, width: 36, height: 4))
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(hex: 0xDBDFF1)
        return view
    }()
    
    lazy var mainView: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    init(frame: CGRect, subView: UIView, dataSource: BasePopupDataSource?, keyboardDataSource: BasePopupKeyboardDataSource?) {
        super.init(frame: frame)
        self.setup()
        guard let dataSource = dataSource else { return }
        self.dataSource = dataSource
        self.keyboardDataSource = keyboardDataSource
        self.totalHeightLayout = dataSource.totalHeight() + 12.0
        self.currentHeight = UIScreen.SCREEN_HEIGHT - self.totalHeightLayout
        self.mainView.frame = CGRect(x: 0, y: UIScreen.SCREEN_HEIGHT, width: bounds.width, height: self.totalHeightLayout)
        subView.autoresizingMask = .flexibleHeight
        subView.frame = CGRect(x: 0, y: 12, width: self.mainView.bounds.width, height: self.mainView.bounds.height - 12)
        subView.roundCorners([UIRectCorner.topLeft, UIRectCorner.topRight], 14.0)
        self.mainView.addSubview(subView)
        self.mainView.addSubview(indicatorView)
        if let _ = dataSource.dismissWhenTouchUpOutside, dataSource.dismissWhenTouchUpOutside!() {
            addTapGestures()
        }
        if let _ = dataSource.disableDismissWhenDragging, dataSource.disableDismissWhenDragging!() {
            removePanGesture(to: mainView)
        }
        guard let _ = self.keyboardDataSource else { return }
        addKeyboardNotification()
    }
    
    func setup() {
        self.opacityView.frame = self.bounds
        self.addSubview(self.opacityView)
        self.addSubview(self.mainView)
        self.addPanGesture(to: self.mainView)
    }

    func addPanGesture(to superView: UIView) {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:)))
        superView.addGestureRecognizer(panGesture!)
    }
    
    func removePanGesture(to superView: UIView) {
        if let pan = self.panGesture {
            superView.removeGestureRecognizer(pan)
        }
        self.panGesture = nil
    }
    
    func addTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAnywhere(_:)))
        opacityView.addGestureRecognizer(tapGesture)
    }
    
    func animate(_ frame: CGRect, _ duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration) {
            self.mainView.frame = frame
        }
    }
    
    func show(root: UIView,  animated: Bool = true) {
        //update data
        root.addSubview(self)
        self.notificationKeyboardWillHide(self)
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.opacityView.alpha = self.alphaView
        }
    }
    
    func hide(_ animated: Bool = true, _ pushCompletion: Bool = true) {
        var frame = self.mainView.frame
        frame.origin.y = UIScreen.SCREEN_HEIGHT
        self.animate(frame)
        UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
            self.opacityView.alpha = 0.0
        }) { (success) in
            self.removeView(pushCompletion)
        }
    }
    
    @objc func onDrag(_ sender: UIPanGestureRecognizer) {
        if isSearching {
            return
        }
        if !isGesture && sender.state == .began {
            pointTouched = sender.location(in: self)
            self.isGesture = true
        }
        if isGesture && sender.state == .changed {
            let newPoint = sender.location(in: self)
            let deltaY = newPoint.y - pointTouched.y
            let newY = currentHeight + deltaY
            var frame = self.mainView.frame

            if newY > (UIScreen.SCREEN_HEIGHT - self.totalHeightLayout) && newY <= UIScreen.SCREEN_HEIGHT && newY != currentHeight {
                currentHeight = newY
                frame.origin.y = currentHeight
                animate(frame, 0.01)
                pointTouched = newPoint
                
                let newAlpha = self.alphaView - CGFloat(fabsf(Float((currentHeight - (UIScreen.SCREEN_HEIGHT - self.totalHeightLayout))/self.totalHeightLayout))) * self.alphaView
                self.opacityView.alpha = CGFloat(newAlpha)
            }
        }
        if isGesture && (sender.state == .cancelled || sender.state == .ended) {
            isGesture = false
            if (currentHeight - (UIScreen.SCREEN_HEIGHT - self.totalHeightLayout))/self.totalHeightLayout >= 0.3 {
                self.hide()
            } else {
                self.currentHeight = UIScreen.SCREEN_HEIGHT - self.totalHeightLayout
                var frame = self.mainView.frame
                frame.origin.y = self.currentHeight
                self.animate(frame)
                UIView.animate(withDuration: 0.3) {
                    self.opacityView.alpha = self.alphaView
                }
            }
        }
    }
    
    @objc func tapAnywhere(_ sender: Any) {
        self.hide()
    }
    
    @objc func removeView(_ pushCompletion: Bool = true) {
        if let completion = self.completion, pushCompletion {
            completion()
        }
        self.removeKeyboardNotification()
        self.removeFromSuperview()
    }
}

//MARK: - Keyboard notification
extension BasePopupView {
    /** Add Keyboard notification*/
    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationKeyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationKeyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    @objc func notificationKeyboardWillShow(_ sender: Notification) {
        isSearching = true
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            var frame = self.mainView.frame
            if let isOver = self.keyboardDataSource?.isOverWhenKeyboardShowing, isOver() {
                frame.origin.y = UIScreen.SCREEN_HEIGHT - keyboardHeight - self.totalHeightLayout
                if frame.origin.y < 0 {
                    frame.origin.y = KEY_WINDOW_SAFE_AREA_INSETS.top
                    frame.size.height = UIScreen.SCREEN_HEIGHT - keyboardHeight - frame.origin.y
                }
            } else if let _ = self.keyboardDataSource?.expandHeightWhenKeyboardShow {
                frame.origin.y = UIScreen.SCREEN_HEIGHT - (keyboardHeight + self.keyboardDataSource!.expandHeightWhenKeyboardShow!())
            }
            self.animate(frame)
        }
    }
    
    @objc func notificationKeyboardWillHide(_ sender: Any) {
        isSearching = false
        var frame = self.mainView.frame
        frame.origin.y = UIScreen.SCREEN_HEIGHT - self.totalHeightLayout
        frame.size.height = self.totalHeightLayout
        self.animate(frame)
    }
}
