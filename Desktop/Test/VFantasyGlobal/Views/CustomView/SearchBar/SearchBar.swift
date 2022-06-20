//
//  SearchBar.swift
//  PAN689
//
//  Created by Quang Tran on 8/12/21.
//  Copyright © 2021 PAN689. All rights reserved.
//

import UIKit

protocol SearchBarDelegate {
    func onSearch(_ key: String)
}

class SearchBar: UIView {

    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var ivSearch: UIImageView!

    var delegate: SearchBarDelegate?
    
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
        self.tfSearch.placeholder(text: "Search name to transfer".localiz(), color: .white)
    }

    @IBAction func onTextChanged(_ sender: Any) {
        
    }
}

extension SearchBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let key = (textField.text ?? "").trimmingCharacters(in: .whitespaces)
        self.delegate?.onSearch(key)
    }
}
