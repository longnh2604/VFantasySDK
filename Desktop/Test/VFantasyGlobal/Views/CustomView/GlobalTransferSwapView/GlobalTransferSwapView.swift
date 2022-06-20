//
//  GlobalFollowPlayDayView.swift
//  PAN689
//
//  Created by Quang Tran on 7/22/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit
import SwiftDate

typealias OnChoosePlayerToSwap = (_ player: Player) -> Void
typealias OnDetailPlayerToSwap = (_ player: Player) -> Void

class GlobalTransferSwapView: UIView {

    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tbvList: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBankTitle: UILabel!
    @IBOutlet weak var lblBankValue: UILabel!
    @IBOutlet weak var mainViewToBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var tbvListToHeightLayout: NSLayoutConstraint!

    private var isDrag: Bool = false
    private var pointTouched: CGPoint = .zero
    private var direction: DragDirection = .none
    
    var onSwap: OnChoosePlayerToSwap?
    var onDetail: OnDetailPlayerToSwap?
    var currentBudget: String = "" {
        didSet {
            self.lblBankValue.text = currentBudget
        }
    }
    
    var players: [Player] = [] {
        didSet {
            self.tbvList.reloadData()
            self.tbvList.setNeedsLayout()
            self.tbvList.layoutIfNeeded()
            var height = CGFloat(players.count) * GlobalPlayerNewCell.heightCell + 66.0
            if height > UIScreen.SCREEN_HEIGHT*0.7 {
                height = UIScreen.SCREEN_HEIGHT*0.7
            }
            self.tbvListToHeightLayout.constant = height
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mainView.roundCorners([.topLeft, .topRight], 16.0)
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
        let views = self.createFromNib()
        let contentView = views?.first as? UIView
        contentView?.backgroundColor = .clear
        contentView?.frame = self.bounds
        self.addSubview(contentView ?? UIView(frame: self.bounds))
        setup()
    }
    
    func setup() {
        self.lblTitle.text = "Pick a player to swap".localiz()
        self.lblBankTitle.text = "Bank".localiz()
        self.blurView.alpha = 0.0
        self.mainViewToBottomLayout.constant = -UIScreen.SCREEN_HEIGHT
        self.tbvList.register(UINib(nibName: GlobalPlayerNewCell.identifierCell, bundle: Bundle.sdkBundler()), forCellReuseIdentifier: GlobalPlayerNewCell.identifierCell)
        
        self.addPanGesture()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClose(_:)))
        self.blurView.addGestureRecognizer(tap)
    }
    
    @objc func onClose(_ sender: Any) {
        self.hide()
    }
    
    func show(root: UIView,  animated: Bool = true) {
        //update data
        root.addSubview(self)
        self.mainViewToBottomLayout.constant = 0.0
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.blurView.alpha = 0.8
            self.layoutIfNeeded()
        }
    }
    
    func hide(_ animated: Bool = true, _ pushCompletion: Bool = true) {
        self.mainViewToBottomLayout.constant = -UIScreen.SCREEN_HEIGHT
        UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
            self.blurView.alpha = 0.0
            self.layoutIfNeeded()
        }) { (success) in
            self.removeFromSuperview()
        }
    }
}

extension GlobalTransferSwapView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GlobalPlayerNewCell.identifierCell) as? GlobalPlayerNewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.contentToBottomLayout.constant = indexPath.row == 9 - 1 ? 0.0 : 1.0
        if indexPath.row == 0 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.topLeft, .topRight], 16.0)
        } else if indexPath.row == self.players.count - 1 {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, [.bottomLeft, .bottomRight], 16.0)
        } else {
            cell.mainView.roundCornersFix(width: UIScreen.SCREEN_WIDTH - 32, .allCorners, 0.0)
        }
        cell.updateData(players[indexPath.row])
        
        //Update UI
        cell.swapToHighlightMode()
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GlobalPlayerNewCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.onDetail?(players[indexPath.row])
    }
}

extension GlobalTransferSwapView: GlobalPlayerNewCellDelegate {
    func onAction(sender: GlobalPlayerNewCell, _ player: Player) {
        self.onSwap?(player)
    }
}

extension GlobalTransferSwapView {
    
    func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onDragPreview(_:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(pan)
    }
    
    //MARK: Handle present media controller
    @objc func onDragPreview(_ sender: UIPanGestureRecognizer) {
        if !isDrag && sender.state == .began {
            isDrag = true
            direction = .none
            pointTouched = sender.location(in: self)
        }
        if isDrag && sender.state == .changed {
            let newPoint = sender.location(in: self)
            var constraint = self.mainViewToBottomLayout.constant
            let delta = CGPoint(x: newPoint.x - pointTouched.x, y: newPoint.y - pointTouched.y)
            if direction == .none {
                direction = .down
            }
            if newPoint.y != pointTouched.y && direction == .down {
                constraint -= delta.y
                if constraint <= 0 {
                    self.mainViewToBottomLayout.constant = constraint
                }
                pointTouched = newPoint
            }
        }
        if isDrag && (sender.state == .cancelled || sender.state == .ended) {
            isDrag = false
            if self.mainViewToBottomLayout.constant * (-1.0) >= self.tbvListToHeightLayout.constant/3 && direction == .down {
                self.hide()
            } else {
                self.mainViewToBottomLayout.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
}
