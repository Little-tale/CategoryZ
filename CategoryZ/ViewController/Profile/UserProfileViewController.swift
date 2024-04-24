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

enum ProfileType: Equatable{
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
    
    }
    override func subscribe() {
        guard let userId = UserIDStorage.shared.userID else {
            errorCatch(.refreshTokkenError(statusCode: 419, description: "로그인 에러 재시도"))
            return
        }
        let reload = PublishSubject<Void> ()
        
        rx.viewDidAppear
            .bind { _ in
                reload.onNext(())
            }
            .disposed(by: disPoseBag)
        
        let beProfileType = BehaviorRelay(value: profileType)
        // 프로덕트 아이디
        let beProductId = BehaviorRelay(value: ProductID.dailyRoutine)
        
        let reloadTriggerForProfile = rx.viewDidAppear
            .map { $0 == false }
            .map { _ in return () }
        
        let input = UserProfileViewModel.Input(
            inputProfileType: beProfileType,
            inputProducID: beProductId,
            inputProfileReloadTrigger: reload,
            userId: userId,
            leftButtonTap: homeView.leftButton.rx.tap
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
                    owner.homeView.profileView.profileImageView.downloadImage(imageUrl: profileModel.profileImage, resizing: CGSize(width: 100, height: 100))
                }
            
            }
            .disposed(by: disPoseBag)
        
        output
            .leftButtonState
            .drive(with: self) { owner, bool in
                switch owner.profileType {
                case .me:
                    break
                case .other:
                    let title = bool ? "팔로잉" : "팔로우"
                    owner.homeView.leftButton.setTitle(title, for: .normal)
                }
            }
            .disposed(by: disPoseBag)
        
        // 버튼 분기점
        beProfileType
            .bind(with: self) { owner, type in
                var leftTitle = ""
                var rightTitle = ""
                switch type {
                case .me:
                    leftTitle = "프로필 수정"
                    rightTitle = "좋아요한 게시글"
                    owner.homeView.rightButton.isHidden = false
                case .other:
                    owner.homeView.rightButton.isHidden = true
                }
                owner.homeView.leftButton.setTitle(leftTitle, for: .normal)
                owner.homeView.rightButton.setTitle(rightTitle, for: .normal)
            }
            .disposed(by: disPoseBag)
        
        
        
        
        homeView.leftButton.rx
            .tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .withLatestFrom(beProfileType)
            .bind(with: self) { owner, profileType in
                switch profileType {
                case .me:
                    let vc = ProfileSettingViewController()
                    owner.navigationController?.pushViewController(vc, animated: true)
                case .other:
                    break
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
            .map { $0.y }
            .drive(with: self) { owner, point in
                let ofY = point
                let height = owner.homeView.scrollView.contentSize.height
                let frameHeight = owner.homeView.scrollView.frame.size.height
               
                if ofY >= (height - frameHeight) {
                    owner.homeView.scrollView.isScrollEnabled = false
                    owner.homeView.collectionView.isScrollEnabled = true
                }
            }
            .disposed(by: disPoseBag)
        
        homeView.collectionView.rx.contentOffset
            .map { $0.y }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance) // 회고
            .withUnretained(self)
            .bind { owner, offsetY in

                if offsetY <= 0 {
                    owner.homeView.scrollView.isScrollEnabled = true
                    owner.homeView.collectionView.isScrollEnabled = false
                }
            }
            .disposed(by: disPoseBag)
        
        // 팔로워 버튼을 눌렀을때
        homeView.profileView.followerButton.rx
            .tap
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .withLatestFrom(output.outputProfile)
            .map { $0.followers }
            .bind(with: self) { owner, follower in
                let vc = FollowerAndFolowingViewController()
                vc.setModel(
                    follower,
                    followType: .follower,
                    isME: owner.profileType
                )
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
        
        // 팔로잉 버튼을 눌렀을때
        homeView.profileView.followingButton.rx
            .tap
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .withLatestFrom(output.outputProfile)
            .map { $0.following }
            .bind(with: self) { owner, following in
                
                let vc = FollowerAndFolowingViewController()
                vc.setModel(
                    following,
                    followType: .following,
                    isME: owner.profileType
                )
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
    }
    
    
    override func navigationSetting() {
        navigationItem.title = "프로필"
    }
}

extension CustomSectionModel: SectionModelType {
    
    init(original: CustomSectionModel, items: [SNSDataModel]) {
        self = original
        self.items = items
    }
    
    typealias Item = SectionModel
}




