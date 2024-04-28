//
//  RxBaseCollectionViewCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import UIKit
import RxSwift
import RxCocoa
 
class RxBaseCollectionViewCell: BaseCollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        subscribe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func subscribe(){
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = .init()
        
    }
}

