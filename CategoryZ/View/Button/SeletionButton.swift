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
    
    override var isSelected: Bool {
        didSet {
            let image = isSelected ? selectedImage : noSelectedImage
            setImage(image, for: .normal)
            
        }
    }
    
    init(selected: UIImage?, noSelected: UIImage?) {
        selectedImage = selected
        noSelectedImage = noSelected
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setting() {
        clipsToBounds = true
        setImage(noSelectedImage, for: .normal)
        contentMode = .scaleAspectFit
        
        if let imageView {
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
