//
//  ProfileModifyView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/22/24.
//

import UIKit
import Then
import SnapKit

final class ProfileSettingView: RxBaseView {
    /// 이름, 전화번호, 이미지
    let profileView = ProfileView()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomCollectionViewLayout.settingCollectionViewLayout())
    
    override func configureHierarchy() {
        addSubview(profileView)
        addSubview(collectionView)
    }
    
    override func configureLayout() {
        print(profileView.intrinsicContentSize.height)
        profileView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.height.equalTo(profileView.intrinsicContentSize.height)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize() // 이건 왜...
        print(profileView.intrinsicContentSize.height)
        profileView.snp.updateConstraints{ make in
            make.height.equalTo(profileView.intrinsicContentSize.height + 120)
        }
    }
    
    override func register() {
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.identi)
    }
}


