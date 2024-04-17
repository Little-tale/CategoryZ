//
//  seletionButton.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import UIKit
import Then
import SnapKit

final class SeletionButton: BaseButton {
    
    private let selectedImage: UIImage?
    private let noSelectedImage: UIImage?
    private let selectedColor: UIColor?
    
    private lazy var configu = UIButton.Configuration.tinted()
    
    override var isSelected: Bool {
        didSet {
            let image = isSelected ? selectedImage : noSelectedImage
            configu.image = image
            if let selectedColor {
                configu.baseForegroundColor = isSelected ? selectedColor : .white
            }
            configuration = configu
        }
    }
    
    init(selected: UIImage?, noSelected: UIImage?, seletedColor: UIColor? = nil) {
        selectedImage = selected
        noSelectedImage = noSelected
        selectedColor = seletedColor
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setting() {
        configu.image = selectedImage
        configuration = configu
    }
}
