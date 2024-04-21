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
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomFlowLayout.profilePostLayout).then {
        $0.isScrollEnabled = true
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
    override func register() {

        collectionView.register(ProfilePostCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePostCollectionViewCell.identi)
    }
}
