//
//  FilterClubViewController.swift
//  PAN689
//
//  Created by Quach Ngoc Tam on 6/14/18.
//  Copyright © 2018 PAN689. All rights reserved.
//

import UIKit

class FilterClubViewController: UIViewController {
    
    @IBOutlet weak var applyButton: CustomButton!
    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var presenter = FilterClubPresenter(service: FilterClubService())
    
    weak var delegate: FilterClubViewControllerDelegate?
    var showPosition = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterTitleLabel.text = "filter_the_list".localiz().uppercased()
        applyButton.setTitle("apply_filter".localiz().uppercased(), for: .normal)
        
        // Do any additional setup after loading the view.
        setupPresenter()
        
        loadData()
    }
    
    func setCurrentCheck(position: [FilterData]?, club: [FilterData]?) {
        presenter.currentCheckClub = club ?? [FilterData]()
        presenter.currentCheckPosition = position ?? [FilterData]()
    }
    
    func setupPresenter() {
        presenter.attackView(view: self)
    }
    
    //MARK:- load data from server
    func loadData() {
        presenter.initData(showPosition: showPosition)
    }
    
    @IBAction func actionFilter(_ sender: Any) {
        guard let delegate = self.delegate else {
            return
        }
        
        let postionCheck = presenter.checkDataPositionCheckMark(isShowPosition: showPosition)
        let clubCheck = presenter.checkDataClubCheckMark()
        
        delegate.didClickBack(position: postionCheck, club: clubCheck)
        
        self.popToViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FilterClubViewController:FilterClubView {
    func reloadView() {
        self.collectionView.reloadData()
    }
    
    func startLoading() {
        self.startAnimation()
    }
    
    func finishLoading() {
        self.stopAnimation()
    }
    
    func alertMessage(_ message: String) {
        self.showAlert(message: message)
    }
}

extension FilterClubViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.filtersSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CustomViewHeaderFilterList", for: indexPath) as! CustomViewHeaderFilterList
            
            let filterSection = presenter.filtersSection[indexPath.section]
            headerView.name.text = filterSection.name
            
            return headerView
        default:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CustomViewHeaderFilterList", for: indexPath) as! CustomViewHeaderFilterList
            return headerView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let filter = presenter.filtersSection[section]
        return filter.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCellFilter", for: indexPath) as! CustomCollectionViewCellFilter
        
        let filterSection = presenter.filtersSection[indexPath.section]
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
        let filterSection = presenter.filtersSection[indexPath.section]
        let filter  = filterSection.data[indexPath.row]
        filter.isSelected = !filter.isSelected
        
        self.collectionView.reloadData()
    }
}

extension FilterClubViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
