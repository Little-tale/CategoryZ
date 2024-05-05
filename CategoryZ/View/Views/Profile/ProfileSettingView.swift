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
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomCollectionViewLayout.settingCollectionViewLayout()).then {
        $0.layer.cornerRadius = 34
        $0.clipsToBounds = true
        $0.isScrollEnabled = false
    }
    
    override func configureHierarchy() {
        addSubview(profileView)
        addSubview(collectionView)
    }
    
    override func configureLayout() {
        print(profileView.intrinsicContentSize.height)
        profileView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(safeAreaLayoutGuide)
                .inset(20)
            make.height.equalTo(profileView.intrinsicContentSize.height)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize() // IntrinsicContentSize 가 변경될때만 레이아웃을 업데이트합니다.
        
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self else { return }
            print("변경사항 발동",profileView.intrinsicContentSize.height)
            profileView.snp.updateConstraints{ make in
                make.height.equalTo(self.profileView.intrinsicContentSize.height + 30)
            }
            layoutIfNeeded()
        }
    }
    
    override func register() {
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.reusableIdenti)
    }
}


