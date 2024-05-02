//
//  RxCollectionView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import UIKit
import RxSwift
import RxCocoa

final class RxCollectionView: RxBaseView {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    override func configureHierarchy() {
        addSubview(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func register() {
        collectionView.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderView.reusableIdenti)
        
        collectionView.register(OnlyRxImageCollectionViewCell.self, forCellWithReuseIdentifier: OnlyRxImageCollectionViewCell.reusableIdenti)
    }
}
