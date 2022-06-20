//
//  MNLocalizable.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

public enum Languages: String {
    case en, vi
    
    static func from(rawValue value: String) -> Languages {
        switch value {
        case Languages.en.rawValue:
            return .en
        default:
            return .vi
        }
    }
}

class MNLocalizable: NSObject {
    static let shared: MNLocalizable = MNLocalizable()
    
    /// Returns the currnet language
    var currentLanguage: Languages {
        get {
            guard let currentLang = UserDefaults.standard.string(forKey: "selectedLanguage") else {
                return .vi
            }
            return Languages(rawValue: currentLang) ?? .vi
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedLanguage")
        }
    }
    
    /// Returns the default language that the app will run first time
    var defaultLanguage: Languages {
        get {
            guard let defaultLanguage = UserDefaults.standard.string(forKey: "defaultLanguage") else {
                return .vi
            }
            return Languages(rawValue: defaultLanguage)!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "defaultLanguage")
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedLanguage")
            setLanguage(language: newValue)
            
            UIView.localize()
        }
    }
    
    /// Returns the diriction of the language
    var isRightToLeft: Bool {
        get {
            let lang = currentLanguage.rawValue
            return lang.contains("ar") || lang.contains("he") || lang.contains("ur") || lang.contains("fa")
        }
    }
    
    func setLanguage(language: Languages) {
        // change the dircation of the views
        let semanticContentAttribute:UISemanticContentAttribute = .forceLeftToRight
        UIView.appearance().semanticContentAttribute = semanticContentAttribute
        UINavigationBar.appearance().semanticContentAttribute = semanticContentAttribute
        UITextField.appearance().semanticContentAttribute = semanticContentAttribute
        UITextView.appearance().semanticContentAttribute = semanticContentAttribute
        
        // change app language
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // set current language
        currentLanguage = language
    }
}

extension UIView {
    static func localize() {
        
        let orginalSelector = #selector(awakeFromNib)
        let swizzledSelector = #selector(swizzledAwakeFromNib)
        
        let orginalMethod = class_getInstanceMethod(self, orginalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self, orginalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(orginalMethod!), method_getTypeEncoding(orginalMethod!))
        } else {
            method_exchangeImplementations(orginalMethod!, swizzledMethod!)
        }
        
    }
    
    @objc func swizzledAwakeFromNib() {
        swizzledAwakeFromNib()
        
        switch self {
        case let txtf as UITextField:
            txtf.text = txtf.text?.localiz()
        case let lbl as UILabel:
            lbl.text = lbl.text?.localiz()
        case let btn as UIButton:
            btn.setTitle(btn.titleLabel?.text?.localiz(), for: .normal)
        case is UISearchBar:
            if let textfield = self.value(forKey: "searchField") as? UITextField {
                textfield.placeholder = textfield.placeholder?.localiz()
            }
        default:
            break
        }
    }
}

extension String {
    func localiz() -> String {
        guard let bundle = Bundle.sdkBundler()?.path(forResource: MNLocalizable.shared.currentLanguage.rawValue, ofType: "lproj") else {
            return NSLocalizedString(self, comment: "")
        }
        
        guard let langBundle = Bundle(path: bundle) else { return self }
        return NSLocalizedString(self, tableName: nil, bundle: langBundle, comment: "")
    }
}
