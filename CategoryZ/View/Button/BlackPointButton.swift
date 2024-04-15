//
//  BlackPointButton.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit

final class BlackPointButton: BaseButton {
    
    init(title : String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(JHColor.white, for: .normal)
        backgroundColor = JHColor.black
        layer.cornerRadius = 10
        isMultipleTouchEnabled = false
        isExclusiveTouch = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
