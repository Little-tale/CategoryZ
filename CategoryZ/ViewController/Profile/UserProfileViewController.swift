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
    let donateButton = UIButton()
    
    private 
    lazy var donateNavButton = UIBarButtonItem().then {
        
        donateButton.setImage(JHImage.donateImage, for: .normal)
        donateButton.imageView?.frame = .init(x: 0, y: 0, width: 30, height: 30)
        donateButton.imageView?.contentMode = .scaleAspectFit
        donateButton.sizeToFit()
        $0.customView = donateButton
    }
    
    
    private
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    private
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, AnyHashable>

    private
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    
    private 
    var dataSource: DataSource?
    
    private
    let selectedProductId = BehaviorRelay(value: ProductID.dailyRoutine)
    
    private
    let moveProfile = PublishRelay<Creator> ()
    
    private
    let goChatRoom = PublishRelay<String> ()
    
    private
    enum Section: Int {
        case profile // Profile 모델
        case poster // SNSDataModel
    }

    var profileType = ProfileType.me
    
    let viewModel = UserProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.reusableIdenti)
        
        collectionView.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderView.reusableIdenti)
        
        collectionView.register(ProfilePostCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePostCollectionViewCell.reusableIdenti)
        
        collectionView.collectionViewLayout = createLayout()
        
        switch profileType {
        case .me:
            break
        case .other:
            navigationItem.rightBarButtonItem = donateNavButton
        }
    }
    override func subscriver() {
        configureDataSource()
        applySnapshot()
        subscribe()
    }
    
    override func navigationSetting() {
        navigationItem.title = "프로필"
        navigationController?.hidesBarsOnSwipe = false
    }
    
    private
    func subscribe(){
       
        
        let behaiviorProfile = BehaviorRelay(value: profileType)

        let currentCellAt = BehaviorRelay(value: 0)
        var currentCount = 0
        
        let deleteTrigger = PublishRelay<Void> ()
        
        let input = UserProfileViewModel.Input(
            inputProfileType: behaiviorProfile,
            inputProducID: selectedProductId,
            userId: UserIDStorage.shared.userID,
            currentCellAt: currentCellAt,
            deleteTrigger: deleteTrigger
        )
        
        let output = viewModel.transform(input)
        
        // 후원기능을 켜져 있는 유저는 상단의 후원 버튼이 나오게 됩니다.
        output.donateEnabledModel
            .bind(with: self) { owner, models in
                let bool = models.isEmpty
                owner.donateButton.isHidden = bool
                owner.donateButton.isEnabled = !bool
            }
            .disposed(by: disPoseBag)
        
        output.postReadMainModel
            .distinctUntilChanged()
            .bind(with: self) {owner, models in
                currentCount = models.count
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
        
        rx.viewDidAppear
            .skip(2)
            .bind(with: self) { owner, _ in
                behaiviorProfile.accept(owner.profileType)
            }
            .disposed(by: disPoseBag)
        
    
        collectionView.rx.willDisplayCell
            .bind(with: self) { owner, cellInfo in
                currentCellAt.accept(cellInfo.at.item)
            }
            .disposed(by: disPoseBag)
        
        let selectedModel = PublishRelay<SNSDataModel> ()
        
        collectionView.rx.itemSelected
            .filter({ $0.section == 1 })
            .map({ indexPath in
                let value = output.postReadMainModel.value
                return (indexPath.item, value)
            })
            .map { item, models in
                return(item: item, models: models)
            }
            .filter { $0.models.isEmpty == false }
            .bind { result in
                let models = result.models
                let selected = models[result.item]
                selectedModel.accept(selected)
            }
            .disposed(by: disPoseBag)
            
        
        selectedModel
            .bind(with: self) { owner, model in
                let vc = SingleSNSViewController()
                vc.setModel(model, me: true)
                vc.deleteClosure = {
                    deleteTrigger.accept(())
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
        
        
        
        // 후훤 버튼을 클릭시
        donateButton.rx.tap
            .bind(with: self) { owner, _ in
                if case .other(let otherUserId) = owner.profileType {
                    let vc = DonateViewController()
                    vc.setModel(otherUserId)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disPoseBag)
        
        moveProfile
            .bind(with: self) { owner, creator in
                guard let userId = UserIDStorage.shared.userID else { return }
                let vc = UserProfileViewController()
                if creator.userID == userId {
                    vc.profileType = .me
                } else {
                    vc.profileType = .other(otherUserId: creator.userID)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
        }
            .disposed(by: disPoseBag)
        
        goChatRoom.bind(with: self) { owner, userID in
            let vc = ChattingViewController()
            vc.setModel(userID, roomId: nil)
            owner.navigationController?.pushViewController(vc, animated: true)
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
            if !models.isEmpty {
               
                snapShot.appendItems(models, toSection: .poster)
            }
        }
        
        dataSource?.apply(snapShot,animatingDifferences: true)
    }
}

extension UserProfileViewController {
    
    private
    func configureDataSource() {
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
                guard let stronhSelf = self else { return nil }
                let section = Section(rawValue: indexPath.section)
                switch section {
                case .profile:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.reusableIdenti, for: indexPath) as? ProfileCell else {
                        
                        return .init()
                    }
                    if let model = itemIdentifier as? ProfileType {
                        cell.setModel(profileType: model)
                        cell.moveProfileDelegate = self
                        cell.moveLikesDelegate = self
                        cell.MoveToFollowOrFollower = self
                        cell.goChatRoom = { userID in
                            stronhSelf.goChatRoom.accept(userID)
                        }
                    }
                    
                    return cell
                case .poster:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePostCollectionViewCell.reusableIdenti, for: indexPath) as? ProfilePostCollectionViewCell else {
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
                    withReuseIdentifier: ProfileHeaderView.reusableIdenti,
                    for: indexPath) as? ProfileHeaderView else {
                    return nil
                }
                header.selectedProductDelegate = self
                return header
            default:
                return nil
            }
        }
    }
}

extension UserProfileViewController: SelectedProductId {
    func selected(productID: ProductID) {
        selectedProductId.accept(productID)
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
            vc.hidesBottomBarWhenPushed = true
            NotificationCenter.default.post(name: .hidesBottomBarWhenPushed, object: nil)
            navigationController?.pushViewController(vc, animated: true)
        case .other:
            break
        }
    }
    
    func moveFollowORFollower(_ followType: MoveFllowOrFollower, creator: [Creator]) {
        let vc = FollowerAndFolowingViewController()
        vc.moveProfileDelegate = self
        
        switch followType {
        case .follow(let profileType):
            vc.setModel(creator, followType: .following, isME: profileType)
        case .follower(let profileType):
            vc.setModel(creator, followType: .follower, isME: profileType)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UserProfileViewController: moveProfileDelegate {
    func moveProfile(_ model: Creator) {
        moveProfile.accept(model)
    }
}
