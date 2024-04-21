//
//  OtherUserProfileViewControlelr.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/20/24.
//

import UIKit
import Then
import SnapKit


final class UserProfileView: RxBaseView {
    let scrollView = UIScrollView(frame: .zero)
    
    let profileView = ProfileView()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.isScrollEnabled = true
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionHeadersPinToVisibleBounds = true
        layout.itemSize = CGSize(width: 165, height: 210)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18
        )
        layout.scrollDirection = .vertical
        
        $0.collectionViewLayout = layout
    }
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(profileView)
        scrollView.addSubview(collectionView)
        profileView.backgroundColor = .pointGreen
    }
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(250)
        }
       
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)  
        }
    }
    override func designView() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: 80)
        }
    }
    
    override func register() {

        collectionView.register(ProfilePostCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePostCollectionViewCell.identi)
        
        collectionView.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderView.identi)
        
    }
}
