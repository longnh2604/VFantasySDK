//
//  CheckBoxViewController.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

class CheckBoxViewController: UIViewController {
    
    @IBOutlet weak var tbView: UITableView!
    
    weak var delegate: CheckBoxViewControllerDelegate?
    
    var items = [CheckBoxData]()
    var currentIndex: IndexPath?
    private var currentItem: CheckBoxData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        // Do any additional setup after loading the view.
        tbView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentItem = self.currentItem {
            if let index = items.firstIndex(of: currentItem) {
                let indexPath = IndexPath(row: index, section: 0)
                tbView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateItems(_ items: [CheckBoxData], _ selectedItem: CheckBoxData? = nil) {
        self.items = items
        self.currentItem = selectedItem
    }
    
    func scrollToSelectedItem() {
        guard let selectedItem = self.currentItem else { return }
        guard let firstIndex = self.items.firstIndex(where: { return $0.key == selectedItem.key }) else { return }
        let indexPath = IndexPath(row: firstIndex, section: 0)
        DispatchQueue.main.async {
            self.tbView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    func getHeight() -> CGFloat {
        let height = CGFloat(46 * items.count) + 116
        let screenHeight = UIScreen.main.bounds.height / 2
        
        return height > screenHeight ? screenHeight : height
    }
    
    @IBAction func applyAction(_ sender: Any) {
        if let item = self.currentItem {
            delegate?.didClickApply(item)
        }
        
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension CheckBoxViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellSeason", for: indexPath) as! CustomCellSeason
        let item = items[indexPath.row]
        
        cell.name.text = item.name ?? ""
        if item.key == self.currentItem?.key {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomCellSeason
        cell.accessoryType = .checkmark
        
        let item = items[indexPath.row]
        self.currentItem = item
        
        tableView.reloadData()
        
//        if hiddenWhenSelect {
            self.applyAction(self)
//        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomCellSeason
        cell.accessoryType = .none
        self.currentItem = nil
    }
}

extension CheckBoxViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
