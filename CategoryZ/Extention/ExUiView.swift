//
//  ExUiView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import UIKit

extension UIView: ReusableIdentifier {
        
}

extension UIButton {
    func configuForFollowing() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = JHColor.darkGray
        config.baseForegroundColor = JHColor.white
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        self.configuration = config
    }
}
