//
//  ReusableIdentifier.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import UIKit.UIView

protocol ReusableIdentifier {

}

extension ReusableIdentifier {
    static var reusableIdenti: String {
        return String(describing: self)
    }
}
