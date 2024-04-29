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


enum ProfileType: Equatable, Hashable{
    case me
    case other(otherUserId: String)
}
enum MoveFllowOrFollower {
    case follow(ProfileType)
    case follower(ProfileType)
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

        let currentCellAt = BehaviorRelay(value: 0)

        
        let input = UserProfileViewModel.Input(
            inputProfileType: behaiviorProfile,
            inputProducID: selectedProductId,
            userId: UserIDStorage.shared.userID,
            currentCellAt: currentCellAt
        )
        
        let output = viewModel.transform(input)
        
        output.postReadMainModel
            .distinctUntilChanged()
            .drive(with: self) {owner, models in
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
        
        rx.viewDidAppear
            .skip(1)
            .bind(with: self) { owner, _ in
                owner.collectionView.scrollToItem(at: .init(item: 0, section: 0), at: .top, animated: true)
                behaiviorProfile.accept(owner.profileType)
            }
            .disposed(by: disPoseBag)
        
        
        
        collectionView.rx.willDisplayCell
            .bind(with: self) { owner, cellInfo in
                currentCellAt.accept(cellInfo.at.item)
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
                        cell.moveProfileDelegate = self
                        cell.moveLikesDelegate = self
                        cell.MoveToFollowOrFollower = self
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

extension UserProfileViewController: MoveToProfileModify, MoveToLikePosters, MoveToFollowOrFollower {

    func moveToLikes(_ profileType: ProfileType) {
        switch profileType {
        case .me:
            let vc = LikeViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .other:
            break
        }
    }
    
    func moveToProfile(_ profileType: ProfileType) {
        switch profileType {
        case .me:
            let vc = ProfileSettingViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .other:
            break
        }
    }
    
    func moveFollowORFollower(_ followType: MoveFllowOrFollower, creator: [Creator]) {
        let vc = FollowerAndFolowingViewController()
        switch followType {
        case .follow(let profileType):
            vc.setModel(creator, followType: .following, isME: profileType)
        case .follower(let profileType):
            vc.setModel(creator, followType: .follower, isME: profileType)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
