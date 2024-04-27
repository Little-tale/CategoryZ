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
    
    let profileView = ProfileAndFollowView()
    
    let leftButton = UIButton().then {
        $0.backgroundColor = JHColor.black
        $0.tintColor = JHColor.white
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    let rightButton = UIButton().then {
        $0.backgroundColor = JHColor.black
        $0.tintColor = JHColor.white
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    private
    lazy var buttonStackView = UIStackView(arrangedSubviews: [leftButton, rightButton]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.isScrollEnabled = true
//        let layout = UICollectionViewFlowLayout()
//        
//        layout.sectionHeadersPinToVisibleBounds = true
//        layout.itemSize = CGSize(width: 165, height: 210)
//        layout.minimumLineSpacing = 10
//        layout.minimumInteritemSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18
//        )
//        layout.scrollDirection = .vertical
//        
//        $0.collectionViewLayout = layout
    }
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(buttonStackView)
        scrollView.addSubview(profileView)
        scrollView.addSubview(collectionView)
    }
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(230)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide).inset(10)
            make.height.equalTo(34)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
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
