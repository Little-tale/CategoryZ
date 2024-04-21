//
//  UserProfileViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import Kingfisher
import RxDataSources


/*
 user 별 작성한 포스트 조회,
 user 프로필 조회 섞어야 해
 productId: 가 문제네...
 */

enum ProfileType{
    case me
    case other(otherUserId: String)
}

final class UserProfileViewController: RxHomeBaseViewController<UserProfileView> {
    
    enum SectionItem {
        case headerItem
        case posterItem(SNSDataModel)
    }
    
    typealias dataSourceRx = RxCollectionViewSectionedReloadDataSource<CustomSectionModel>
    
    var profileType = ProfileType.me
    
    let viewModel = UserProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let beProfileType = BehaviorRelay(value: profileType)
        // 프로덕트 아이디
        let beProductId = BehaviorRelay(value: ProductID.fashion)
        
        let input = UserProfileViewModel.Input(
            inputProfileType: beProfileType,
            inputProducID: beProductId
        )
    
        let output = viewModel.transform(input)
        
        output.outputProfile
            .drive(with: self) { owner, profileModel in
                // 팔로워수
                owner.homeView.profileView.followerCountLabel.text = profileModel.followers.count.asFormatAbbrevation()
                // 이름
                owner.homeView.profileView.userNameLabel.text = profileModel.nick
                
                // 팔로잉 숫자
                owner.homeView.profileView.followingCountLabel.text = profileModel.following.count.asFormatAbbrevation()
                
                // 포스트 숫자
                owner.homeView.profileView.postsCountLabel.text = profileModel.posts.count.asFormatAbbrevation()
                
                // 프로파일 이미지
                if !profileModel.profileImage.isEmpty {
                    owner.homeView.profileView.profileImageView.kf.setImage(with: profileModel.profileImage.asStringURL,placeholder: JHImage.defaultImage , options: [
                        .transition(.fade(1)),
                        .cacheOriginalImage,
                        .requestModifier(
                            KingFisherNet()
                        ),
                    ])
                }
            }
            .disposed(by: disPoseBag)
        
        // 네트워크 에러
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
    
        
        let dataSource = dataSourceRx { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePostCollectionViewCell.identi, for: indexPath) as? ProfilePostCollectionViewCell else {
                print("ProfilePostCollectionViewCell ")
                return .init()
            }
            cell.postContentLabel.text = item.content
            cell.postImageView.kf.setImage(
                with: item.files.first?.asStringURL,placeholder: JHImage.defaultImage,
                options: [
                .transition(.fade(1)),
                .cacheOriginalImage,
                .requestModifier(
                    KingFisherNet()
                ),
            ])
            cell.postDateLabel.text = DateManager.shared.differenceDateString(item.createdAt)
            
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
            print("ProfilePostCollectionViewCell ㅖㅏ")
            return cell
            
        } configureSupplementaryView: { dataSource, view, kind, indexPath in
            print("sadsa")
            guard kind == UICollectionView.elementKindSectionHeader else {
                print("configureSupplementaryView ")
                return .init()
            }
            
            guard let header = view.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderView.identi, for: indexPath) as? ProfileHeaderView else {
                print("configureSupplementaryView ")
                return .init()
            }
            print("configureSupplementaryView ㅖㅏ")
    
            return header
        }
        
        output.postReadMainModel
            .drive(homeView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disPoseBag)
        
        /// 노티피 케이션 연결
        NotificationCenter.default.rx.notification(.selectedProductId)
            .map { notification in
                return notification.userInfo?["productID"] as? ProductID
            }
            .compactMap { $0 }
            .subscribe(with: self) { owner, productId in
                beProductId.accept(productId)
            }
            .disposed(by: disPoseBag)
        
        /// 스크롤뷰 컨트롤
        output.postReadMainModel
            .flatMapLatest { _ in
                return self.homeView.scrollView.rx.contentOffset.asDriver()
            }
            .drive(with: self) { owner, point in
                let ofY = point.y
                let height = owner.homeView.scrollView.contentSize.height
                let frameHeight = owner.homeView.scrollView.frame.size.height
                print(height, frameHeight)
                if ofY >= (height - frameHeight) {
                    owner.homeView.scrollView.isScrollEnabled = false
                    owner.homeView.collectionView.isScrollEnabled = true
                } else {
                    owner.homeView.scrollView.isScrollEnabled = true
                    owner.homeView.collectionView.isScrollEnabled = false
                }
            }
            .disposed(by: disPoseBag)
        
        homeView.collectionView.rx.contentOffset
            .map { $0.y }
            .distinctUntilChanged()
            .withUnretained(self)
            .bind { owner, offsetY in
                if offsetY <= -10 {
                    owner.homeView.scrollView.isScrollEnabled = true
                    owner.homeView.collectionView.isScrollEnabled = true
                }
            }
            .disposed(by: disPoseBag)
        
    }
}

extension CustomSectionModel: SectionModelType {
    
    init(original: CustomSectionModel, items: [SNSDataModel]) {
        self = original
        self.items = items
    }
    
    typealias Item = SectionModel
}


