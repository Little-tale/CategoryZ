//
//  PostRegView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit
import SnapKit
import Then
import Kingfisher

// 1. 현재 사용자 정보를 찾아옴
// 2. 포스트 API 를 통해 게시글 올려야함
final class PostRegView: RxBaseView {
    
    let profileImage = UIImageView().then {
        $0.image = UIImage.appLogo
        $0.clipsToBounds = true
    }
    
    let nameLabel = UILabel().then { $0.text = "이름들어감" }

    let contentTextView = PlaceholderTextView().then {
        $0.placeholderText = "무엇이든 남겨요"
        $0.textFont = JHFont.UIKit.re17
    }
    
    private let imageMent = UILabel().then {
        $0.text = "이미지 (필수)"
        $0.font = JHFont.UIKit.re17
        $0.textColor = JHColor.black
    }
    
    let imageAddButton = BlackPointButton(title: "이미지 추가").then {
        $0.titleLabel?.font = JHFont.UIKit.li14
    }
    
    let imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomFlowLayout.imagesLayout)
    
    private let categoryMent = UILabel().then {
        $0.text = "카테고리 (필수)"
        $0.font = JHFont.UIKit.re17
        $0.textColor = JHColor.black
    }
    
    let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomFlowLayout.postLayout)
    
    
    override func configureHierarchy() {
        addSubview(profileImage)
        addSubview(nameLabel)
        addSubview(contentTextView)
        addSubview(imageMent)
        addSubview(imageAddButton)
        addSubview(imageCollectionView)
        addSubview(categoryMent)
        addSubview(categoryCollectionView)
    }
    override func configureLayout() {
        profileImage.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).offset(12)
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
            make.size.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImage.snp.trailing).offset(6)
            make.centerY.equalTo(profileImage)
        }
       
        contentTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.top.equalTo(profileImage.snp.bottom).offset(8)
            make.height.equalTo(150)
        }
        imageMent.snp.makeConstraints { make in
            make.leading.equalTo(categoryMent)
            make.trailing.equalTo(imageAddButton.snp.leading).inset(4)
            make.top.equalTo(contentTextView.snp.bottom).offset(6)
        }
        imageAddButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.centerY.equalTo(imageMent)
            make.width.equalTo(80)
        }
        imageCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(imageMent.snp.bottom).offset(4)
            make.height.equalTo(150)
        }
        categoryMent.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(15)
            make.top.equalTo(imageCollectionView.snp.bottom).offset(6)
        }
        categoryCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(categoryMent.snp.bottom).offset(8)
            make.height.equalTo(80)
        }
    }
    
    override func register() {
        categoryCollectionView.register(CategoryReusableCell.self, forCellWithReuseIdentifier: CategoryReusableCell.identi)
        imageCollectionView.register(OnlyImageCollectionViewCell.self, forCellWithReuseIdentifier: OnlyImageCollectionViewCell.identi)
    }
    func settingProfileImage(_ urlString: String) {
        let url = URL(string: urlString)
        
    }
}
