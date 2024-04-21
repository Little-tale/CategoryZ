//
//  ProfileHeaderView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class ProfileHeaderView: UICollectionReusableView {
    
    let collectionView: UICollectionView
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        let itemSize = frame.height - 10
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        register()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private
    func bind(){
        
    }
    
    
    private
     func configureHierarchy() {
        addSubview(collectionView)
    }
    
    private
     func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    private
     func register() {
        collectionView.register(CategoryReusableCell.self, forCellWithReuseIdentifier: CategoryReusableCell.identi)
    }
}
