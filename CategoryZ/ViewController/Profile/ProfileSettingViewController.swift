//
//  ProfileModifyViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

final class ProfileSettingViewController: RxHomeBaseViewController<ProfileSettingView> {

    enum SettingSection {
        case profileImage
        case name
        case phoneNumber
    }
    
    let viewModel = ProfileSettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JHColor.settingColor
    }
    
    override func subscribe() {
        
        let section = Observable.just([
            SettingSection.profileImage,
            SettingSection.name,
            SettingSection.phoneNumber
        ])
        
        
        // 프로필은 뷰가 보일때마다 로드해야 하지 않을까?
        let viewWillTrigger = rx.viewWillAppear
            .filter { $0 == true }
            .map { _ in return () }
        
        let input = ProfileSettingViewModel.Input(
            viewWiddTrigger: viewWillTrigger
        )
        
        let output = viewModel.transform(input)
        
        
        output.successModel
            .drive(with: self) { owner, model in
                owner.homeView.profileView.userNameLabel.text = model.nick
                owner.homeView.profileView.phoneNumLabel.text = model.phoneNum
                if let url = model.profileImage.asStringURL {
                    owner.homeView.profileView.profileImageView.kf.setImage(with: url, options: [
                        .requestModifier(KingFisherNet()),
                    ]
                    )
                } else {
                    owner.homeView.profileView.profileImageView.image = JHImage.defaultImage
                }
            }
            .disposed(by: disPoseBag)
        
        output.outputNetwork
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        section.bind(to: homeView.collectionView.rx.items(cellIdentifier: UICollectionViewListCell.identi)) {row, item, cell in
            var content = UIListContentConfiguration.valueCell()
            
            switch item {
            case .profileImage:
                content.text = "이미지 수정"
            case .name:
                content.text = "이름 수정"
            case .phoneNumber:
                content.text = "전화번호 수정"
            }
            cell.contentConfiguration = content
        }
        .disposed(by: disPoseBag)
        
        
    }
    
}
