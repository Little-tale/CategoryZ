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
import Toast


enum SettingSection: Int, CaseIterable {
    case profileImage
    case name
    case phoneNumber
    case registerDonate
    case myPayments
    case logOut
    case deleteAccount
}

final class ProfileSettingViewController: RxHomeBaseViewController<ProfileSettingView> {

    
    let viewModel = ProfileSettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = JHColor.settingColor
    }
    
    override func subscribe() {
        
        var emptyModel = ProfileModel()
        
        let section = Observable.just(SettingSection.allCases)
        
        let tryAccountDelete = PublishRelay<Void> ()
        let tryLogout = PublishRelay<Void> ()
        
        // 프로필은 뷰가 보일때마다 로드해야 하지 않을까?
        let viewWillTrigger = rx.viewDidAppear
            .filter { $0 == true }
            .map { _ in return () }
        
        let input = ProfileSettingViewModel.Input(
            viewWiddTrigger: viewWillTrigger,
            logoutTrigger: tryLogout
        )
        
        let output = viewModel.transform(input)
        
        
        output.successModel
            .drive(with: self) { owner, model in
                emptyModel = model
                owner.homeView.profileView.userNameLabel.text = model.nick
                owner.homeView.profileView.phoneNumLabel.text = model.phoneNum
                if !model.profileImage.isEmpty {
                    owner.homeView.profileView
                        .profileImageView
                        .downloadImage(
                            imageUrl: model.profileImage,
                            resizeCase: .low,
                            JHImage.defaultImage
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
        
        section.bind(to: homeView.collectionView.rx.items(cellIdentifier: UICollectionViewListCell.reusableIdenti)) {row, item, cell in
            var content = UIListContentConfiguration.valueCell()
            
            switch item {
            case .profileImage:
                content.text = "이미지 수정"
            case .name:
                content.text = "이름 수정"
            case .phoneNumber:
                content.text = "전화번호 수정"
            case .deleteAccount:
                content.text = "계정 삭제"
            case .registerDonate:
                content.text = "후원 등록 / 취소"
            case .myPayments:
                content.text = "결제 내역"
            case .logOut:
                content.text = "로그 아웃"
            }
            cell.contentConfiguration = content
            
        }
        .disposed(by: disPoseBag)
        
        homeView.collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.homeView.collectionView.deselectItem(at: indexPath, animated: true)
            }
            .disposed(by: disPoseBag)
            
        homeView.collectionView.rx.modelSelected(SettingSection.self)
            .bind(with: self) { owner, section in
                let model = emptyModel
                switch section {
                case .profileImage:
                    let vc = UserProfileImageModifyViewController()
                    vc.setModel(model)
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .name:
                    let vc = NameModifyViewController()
                    vc.setModel(model)
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .phoneNumber:
                    let vc = UserPhoneNumberModifyViewController()
                    vc.setModel(model)
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .deleteAccount:
                    owner.showAlert(
                        title: "계정 삭제 시도",
                        message: "계정 정말 삭제 하시겠어요?",
                        actionTitle: "삭제",
                        { _ in
                            tryAccountDelete.accept(())
                        },
                        .destructive)
                  
                case .registerDonate:
                    let vc = RegisterDonateViewController()
                    vc.setModel(model)
                    owner.navigationController?.pushViewController(vc, animated: true)
                    
                case .myPayments:
                    let vc = DonateListViewController()
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .logOut:
                    owner.showAlert(
                        title: "로그 아웃",
                        message: "로그 아웃 하시겠습니까?",
                        actionTitle: "확인",
                        { _ in
                            owner.view.makeToastActivity(.center)
                            tryLogout.accept(())
                        },
                        .default)
                }
            }
            .disposed(by: disPoseBag)
        
        
        output.logoutSuccessTrigger
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.view.hideToastActivity()
                owner.showAlert(
                    title: "로그아웃 완료",
                    message: "로그아웃이 성공적으로 되었습니다.",
                    actionTitle: "확인") { _ in
                        owner.changeRootView(to: LunchScreenViewController(), isNavi: true)
                    }
            }
            .disposed(by: disPoseBag)
        
        
        tryAccountDelete.bind(with: self) { owner, _ in
            let vc = CheckUserDeleteViewController()
            owner.navigationController?.pushViewController(vc, animated: true)

        }
        .disposed(by: disPoseBag)
        
        rx.viewDidDisapear.bind(with: self) { owner, _ in
            NotificationCenter.default.post(name: .chagedProfileInfo, object: nil)
        }
        .disposed(by: disPoseBag)
    }
    
    override func navigationSetting() {
        navigationItem.title = "설정"
        
    }
}
