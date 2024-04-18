//
//  CircleImageView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit

class CircleImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        self.layer.cornerRadius = self.frame.width / 2
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
    }
}


