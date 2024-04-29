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
//import RxDataSources


/*
 user 별 작성한 포스트 조회,
 user 프로필 조회 섞어야 해
 productId: 가 문제네...
 */

enum ProfileType: Equatable, Hashable{
    case me
    case other(otherUserId: String)
}

final class UserProfileViewController: RxBaseViewController {
    private
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    private
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, AnyHashable>

    private
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    
    private var dataSource:DataSource?
    
    private
    enum Section: Int {
        case profile // Profile 모델
        case poster // SNSDataModel
    }

    var profileType = ProfileType.me
    
    let viewModel = UserProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        applySnapshot()
        
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identi)
        
        collectionView.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderView.identi)
        
        collectionView.register(ProfilePostCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePostCollectionViewCell.identi)
        
        collectionView.collectionViewLayout = createLayout()
        
    }
    override func subscriver() {
        subscribe()
    }
    
    override func navigationSetting() {
        navigationItem.title = "프로필"
    }
    
    private
    func subscribe(){
        let selectedProductId = BehaviorRelay(value: ProductID.dailyRoutine)
        
        let behaiviorProfile = BehaviorRelay(value: profileType)

        let input = UserProfileViewModel.Input(
            inputProfileType: behaiviorProfile,
            inputProducID: selectedProductId,
            userId: UserIDStorage.shared.userID
        )
        
        let output = viewModel.transform(input)
        
        output.postReadMainModel
            .drive(with: self) {owner, models in
//                applySnapshot(profileType)
                if models.isEmpty {
                    owner.applySnapshot(owner.profileType)
                } else {
                    owner.applySnapshot(owner.profileType,models: models)
                }
            }
            .disposed(by: disPoseBag)
        
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        NotificationCenter.default.rx.notification(.selectedProductId)
            .map { notification in
                return notification.userInfo?["productID"] as? ProductID
            }
            .compactMap { $0 }
            .subscribe(with: self) { owner, productId in
                selectedProductId.accept(productId)
            }
            .disposed(by: disPoseBag)
       
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension UserProfileViewController {
    
    private func applySnapshot(_ profile: ProfileType? = nil, models: [SNSDataModel]? = nil) {
        var snapShot = SnapShot()
        
        snapShot.appendSections([.profile, .poster])
        
        if let profile {
            snapShot.appendItems([profile], toSection: .profile)
        }
        
        if let models {
            snapShot.appendItems(models, toSection: .poster)
        }
        
        dataSource?.apply(snapShot,animatingDifferences: true)
    }
}

extension UserProfileViewController {
    
    private
    func configureDataSource() {
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: {collectionView, indexPath, itemIdentifier in
                // guard let self else { return nil }
                let section = Section(rawValue: indexPath.section)
                switch section {
                case .profile:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identi, for: indexPath) as? ProfileCell else {
                        
                        return .init()
                    }
                    if let model = itemIdentifier as? ProfileType {
                        cell.setModel(profileType: model)
                        cell.moveDelegate = self
                    }
                    
                    return cell
                case .poster:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePostCollectionViewCell.identi, for: indexPath) as? ProfilePostCollectionViewCell else {
                        
                        return .init()
                    }
                    if let model = itemIdentifier as? SNSDataModel {
                        cell.setModel(model)
                    }
                    
                    return cell
                default :
                    return nil
                }
            }
        )
        dataSource?.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            let section = Section(rawValue: indexPath.section)
            switch section {
            case .poster:
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: ProfileHeaderView.identi,
                    for: indexPath) as? ProfileHeaderView else {
                    
                    return nil
                }
                return header
            default:
                return nil
            }
        }
        
    }
}

extension UserProfileViewController {
    private
    func createLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { section, _  in
            let sectionKind = Section(rawValue: section) ?? .profile
            switch sectionKind {
            case .profile:
                return CustomProfileCollectionViewLayout.createProfileLayout()
            case .poster:
                return CustomProfileCollectionViewLayout.createProfilePosterLayout()
            }
        }
    }
}

extension UserProfileViewController: MoveToProfileModify {
    
    func moveToProfile(_ profileType: ProfileType) {
        switch profileType {
        case .me:
            let vc = ProfileSettingViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .other:
            break
        }
    }
    
}

//extension CustomSectionModel: SectionModelType {
//    
//    init(original: CustomSectionModel, items: [SNSDataModel]) {
//        self = original
//        self.items = items
//    }
//    
//    typealias Item = SectionModel
//}


//extension UserProfileViewController: CustomPinterestLayoutDelegate {
//    
//    func collectionView(
//        for collectionView: UICollectionView,
//        heightForAtIndexPath indexPath: IndexPath) -> CGFloat {
//            let cellWidth: CGFloat = (view.bounds.width) / 2
//            
//            let ratioString = viewModel.realModel[indexPath.item].content3
//            
//            let ratioFloat = CGFloat(Double(ratioString) ?? 1 )
//            
//            return cellWidth / ratioFloat
//    }
//    
//}
/*
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
 
 
 
 
 
 // 좌측 버튼 탭 하였을때
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

 homeView.rightButton.rx
     .tap
     .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
     .bind(with: self) { owner, _ in
         // LikeViewController
         let vc = LikeViewController()
         owner.navigationController?.pushViewController(vc, animated: true)
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
 
 // 스크롤뷰 컨트롤
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
 
//        homeView.collectionView.rx.contentOffset
//            .map { $0.y }
//            .distinctUntilChanged()
//            .observe(on: MainScheduler.asyncInstance) // 회고
//            .withUnretained(self)
//            .bind { owner, offsetY in
//
//                if offsetY <= 0 {
//                    owner.homeView.scrollView.isScrollEnabled = true
//                    owner.homeView.collectionView.isScrollEnabled = false
//                }
//            }
//            .disposed(by: disPoseBag)
 
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
 */
