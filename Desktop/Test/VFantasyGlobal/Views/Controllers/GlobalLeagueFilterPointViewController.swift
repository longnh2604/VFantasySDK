//
//  GlobalLeagueFilterPointViewController.swift
//  PAN689
//
//  Created by Quang Tran on 1/11/20.
//  Copyright © 2020 PAN689. All rights reserved.
//

import UIKit

protocol GlobalLeagueFilterPointViewControllerDelegate: NSObjectProtocol {
    func onApplyFilter(key: String)
}

class GlobalLeagueFilterPointViewController: UIViewController {
    
    @IBOutlet weak var applyButton: CustomButton!
    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var cancelLabel: UILabel!
    
    fileprivate var presenter = GlobalLeagueFilterPointPresenter()
    var filterKey = ""
    
    weak var delegate: GlobalLeagueFilterPointViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configsUI()
        setupPresenter()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func configsUI() {
        filterTitleLabel.text = "filter_the_list".localiz().uppercased()
        applyButton.setTitle("apply_filter".localiz().uppercased(), for: .normal)
        cancelLabel.text = "Cancel".localiz()
        resetLabel.text = "reset".localiz()
    }
    
    override func loadMore() {
        super.loadMore()
        loadData()
    }
    
    func setLeagueId(_ leagueId: Int) {
        presenter.leagueId = leagueId
    }
    
    func setLeague(_ league: LeagueDatum?) {
        presenter.league = league
    }
    
    func setupPresenter() {
        presenter.attackView(view: self)
    }
    
    func loadData() {
        presenter.getGameweekList()
    }

    func resetSelectedFlag(_ currentData: LeaguePointFilterData) {
        for section in presenter.filtersSection {
            for data in section.data {
                if data != currentData {
                    data.isSelected = false
                }
            }
        }
    }
    
    private func setItemSelected() {
        for section in presenter.filtersSection {
            for data in section.data {
                if data.key == filterKey {
                    data.isSelected = true
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func resetTapped(_ sender: Any) {
        resetSelectedFlag(LeaguePointFilterData())
        filterKey = ""
        self.collectionView.reloadData()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyFilterTapped(_ sender: Any) {
        delegate?.onApplyFilter(key: filterKey)
        self.popToViewController()
    }
}

// MARK: - UICollectionViewDataSource

extension GlobalLeagueFilterPointViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.filtersSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CustomViewHeaderFilterList", for: indexPath) as! CustomViewHeaderFilterList
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let filterSection = presenter.filtersSection[indexPath.section]
            headerView.name.text = filterSection.name

            return headerView
        default:
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
        cell.imageCheckMark.image = filter.isSelected ? VFantasyCommon.image(named: "ic_checkmark") : UIImage()
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GlobalLeagueFilterPointViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterSection = presenter.filtersSection[indexPath.section]
        let filter = filterSection.data[indexPath.row]
        
        self.resetSelectedFlag(filter)
        filter.isSelected = !filter.isSelected
        
        filterKey = filter.isSelected ? filter.key : ""
        
        self.collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GlobalLeagueFilterPointViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,  layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.width - 54
        return CGSize(width: width, height: 34)
    }
}

// MARK: - LeagueFilterPointView

extension GlobalLeagueFilterPointViewController: LeagueFilterPointView {
    
    func reloadView() {
        setItemSelected()
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

extension GlobalLeagueFilterPointViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
