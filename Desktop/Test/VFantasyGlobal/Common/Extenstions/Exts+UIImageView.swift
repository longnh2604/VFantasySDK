//
//  Exts+UIImageView.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

extension UIImageView {
    func changeTint(_ tintColor: UIColor) {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = tintColor
    }
    
    func setPlayerAvatar(with urlString: String?) {
        guard let urlString = urlString else { return }
        guard let validString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        self.sd_setImage(with: URL(string: validString), placeholderImage: VFantasyCommon.image(named: "ic_user_default"), options: .queryMemoryData) { (_, _ , _, _) in
        }
    }
    
    func setPlayerAvatarRefreshCache(with urlString: String?, placeHolder: UIImage? = VFantasyCommon.image(named: "ic_user_default")) {
        guard let urlString = urlString else { return }
        guard let validString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        self.sd_setImage(with: URL(string: validString), placeholderImage: placeHolder, options: .refreshCached) { (_, _ , _, _) in
        }
    }
}
