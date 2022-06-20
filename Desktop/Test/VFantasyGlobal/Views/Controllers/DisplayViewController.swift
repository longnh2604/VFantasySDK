//
//  DisplayViewController.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/15/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit
protocol DisplayViewControllerDelegate: NSObjectProtocol {
    func didClickDisplay(_ display:[FilterData])
}

class DisplayViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var presenter = DisplayPresenter()
    weak var delegate: DisplayViewControllerDelegate?
    
    @IBOutlet weak var titleDisplay: UILabel!
    @IBOutlet weak var applyButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initBackView(title: "player_list".localiz())
        applyButton.setTitle("apply_to_table".localiz().uppercased(), for: .normal)
        // Do any additional setup after loading the view.
        initData()
    }
    
    func initData() {
        presenter.initData()
    }
    
    func setCurrentDisplay(_ display:[FilterData]?) {
        self.presenter.currentCheck = display ?? [FilterData]()
    }
        
    @IBAction func actionDisplay(_ sender: Any) {
        guard let delegate = self.delegate else {
            return
        }
        
        let displayCheck = presenter.checkDataDisplayCheckMark()
        
        delegate.didClickDisplay(displayCheck)
        
        self.popToViewController()
    }
    
    func hideValueFilter() {
        presenter.hideValueFilter = true
    }
}

extension DisplayViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.displaySection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let filter = presenter.displaySection[section]
        return filter.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCellFilter", for: indexPath) as! CustomCollectionViewCellFilter
        
        let filterSection = presenter.displaySection[indexPath.section]
        let filter  = filterSection.data[indexPath.row]
        
        cell.name.text = filter.name
        
        if filter.isSelected {
            cell.imageCheckMark.image = VFantasyCommon.image(named: "ic_checkmark")
        }else {
            cell.imageCheckMark.image = UIImage()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterSection = presenter.displaySection[indexPath.section]
        let filter  = filterSection.data[indexPath.row]
        if filter.isSelected == false {
            let displayChecks = presenter.checkDataDisplayCheckMark()
            if displayChecks.count >= 3 {
                self.showAlert(message: "alert_display_max_columns".localiz())
                return
            }
        }
        filter.isSelected = !filter.isSelected
        
        self.collectionView.reloadData()
    }
}
