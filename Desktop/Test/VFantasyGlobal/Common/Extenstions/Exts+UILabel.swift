//
//  Exts+UILabel.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit
import SwiftDate
import SDWebImage
import MBProgressHUD

extension UILabel {
    func getLinesArrayOfString() -> [String] {
        
        /// An empty string's array
        var linesArray = [String]()
        
        guard let text = self.text, let font = self.font else {return linesArray }
        
        let rect = self.frame
        
        let myFont: CTFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: myFont, range: NSRange(location: 0, length: attStr.length))
        
        let frameSetter: CTFramesetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path: CGMutablePath = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000), transform: .identity)
        
        let frame: CTFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        guard let lines = CTFrameGetLines(frame) as? [Any] else {return linesArray}
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange: CFRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            let lineString: String = (text as NSString).substring(with: range)
            linesArray.append(lineString)
        }
        return linesArray
    }
    
    func setPosition(_ pos: Int, full: Bool = false) {
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.textColor = .white
        self.textAlignment = .center
        
        if let customFont = UIFont(name: FontName.black, size: 13) {
            self.font = customFont
        }
        
        switch pos {
        case PlayerPositionType.goalkeeper.rawValue:
            self.text = full ? "Goalkeeper".localiz() : "G"
            self.backgroundColor = #colorLiteral(red: 0.2669999897, green: 0.6079999804, blue: 0.9060000181, alpha: 1)
        case PlayerPositionType.attacker.rawValue:
            self.text = full ? "Attacker".localiz() : "A"
            self.backgroundColor = #colorLiteral(red: 1, green: 0.08200000226, blue: 0.08200000226, alpha: 1)
        case PlayerPositionType.defender.rawValue:
            self.text = full ? "Defender".localiz() : "D"
            self.backgroundColor = #colorLiteral(red: 0.3409999907, green: 0.6549999714, blue: 0, alpha: 1)
        case PlayerPositionType.midfielder.rawValue:
            self.text = full ? "Midfielder".localiz() : "M"
            self.backgroundColor = #colorLiteral(red: 1, green: 0.7369999886, blue: 0.3059999943, alpha: 1)
        default:
            isHidden = true
        }
    }
    
    func inactive() {
        self.backgroundColor = .gray
    }
    
    func active(_ pos: Int) {
        switch pos {
        case PlayerPositionType.goalkeeper.rawValue:
            self.backgroundColor = #colorLiteral(red: 0.2669999897, green: 0.6079999804, blue: 0.9060000181, alpha: 1)
        case PlayerPositionType.attacker.rawValue:
            self.backgroundColor = #colorLiteral(red: 1, green: 0.08200000226, blue: 0.08200000226, alpha: 1)
        case PlayerPositionType.defender.rawValue:
            self.backgroundColor = #colorLiteral(red: 0.3409999907, green: 0.6549999714, blue: 0, alpha: 1)
        case PlayerPositionType.midfielder.rawValue:
            self.backgroundColor = #colorLiteral(red: 1, green: 0.7369999886, blue: 0.3059999943, alpha: 1)
        default:
            self.backgroundColor = .clear
        }
    }
    
    func injured() {
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.textColor = .white
        self.textAlignment = .center
        self.text = "injured".localiz()
        self.backgroundColor = #colorLiteral(red: 0.8159999847, green: 0.00800000038, blue: 0.1059999987, alpha: 1)
        
        if let customFont = UIFont(name: FontName.bold, size: 13) {
            self.font = customFont
        }
    }
    
    func setTransferIn() {
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.textColor = .white
        self.textAlignment = .center
        self.text = "in".localiz()
        self.backgroundColor = #colorLiteral(red: 0.3409999907, green: 0.6549999714, blue: 0, alpha: 1)
        
        if let customFont = UIFont(name: FontName.black, size: 12) {
            self.font = customFont
        }
    }
    
    func setTransferOut() {
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.textColor = .white
        self.textAlignment = .center
        self.text = "out".localiz()
        self.backgroundColor = #colorLiteral(red: 0.8159999847, green: 0.00800000038, blue: 0.1059999987, alpha: 1)
        
        if let customFont = UIFont(name: FontName.black, size: 12) {
            self.font = customFont
        }
    }
}

protocol Localizable {
    var localized: String { get }
}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localiz()
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localiz(), for: .normal)
        }
    }
}
