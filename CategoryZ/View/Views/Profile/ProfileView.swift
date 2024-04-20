//
//  ProfileView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/20/24.
//

import UIKit
import Then
import SnapKit

final class ProfileView: BaseView {
    
    let profileImageView = CircleImageView(frame: .zero)
    let userNameLabel = UILabel()
    
    
    let followingCountLabel = UILabel().then {
        $0.text = "0"
    }
    private let followingLabel = UILabel().then {
        $0.text = "Following"
    }
    
    
    let followerCountLabel = UILabel().then {
        $0.text = "0"
    }
    private let followerLabel = UILabel().then {
        $0.text = "Followers"
    }
    
    
    let postsCountLabel = UILabel().then {
        $0.text = "0"
    }
    private let postsLabel = UILabel().then {
        $0.text = "Posts"
    }
    
    
    lazy var followStackView = UIStackView(arrangedSubviews: [followingCountLabel, followingLabel]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    lazy var follwingStackView = UIStackView(arrangedSubviews: [followerCountLabel, followerLabel]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    lazy var postsCountStackView = UIStackView(arrangedSubviews: [postsCountLabel, postsLabel]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    lazy var horizonStackView = UIStackView(arrangedSubviews: [followStackView, follwingStackView, postsCountStackView]).then {
        $0.axis = .horizontal
        $0.spacing = 15
        $0.distribution = .fillEqually
    }
    
    override func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(userNameLabel)
        addSubview(horizonStackView)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(14)
            make.centerX.equalTo(profileImageView)
        }
        horizonStackView.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(14)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
    override func designView() {
        profileImageView.image = JHImage.defaultImage
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.tintColor = JHColor.black
        profileImageView.backgroundColor = .like
    }
}
