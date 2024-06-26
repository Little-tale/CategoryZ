//
//  PhotoSNSViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import RxDataSources
import RxReusableKit


final class SNSPhotoViewController: RxHomeBaseViewController<PhotoSNSView> {
    
    typealias RxHeaderDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String,ProductID>>
    
    typealias SNSSectionModel = AnimatableSectionModel<String, SNSDataModel>
    
    private
    let represhControl = UIRefreshControl()
    
    private
    let headerItems = Observable.just([
        SectionModel(
            model: "Section",
            items: ProductID.allCases)
    ])
    
    private 
    let viewModel = SNSPhotoMainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.tableView.tableHeaderView = homeView.headerView
    }
    
    override func designView() {
        super.designView()
        homeView.tableView.refreshControl = represhControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
        NotificationCenter.default
            .rx
            .notification(.moveToProfileForComment, object: nil)
            .take(until: rx.viewDidDisapear)
            .bind(with: self) { owner, noti in
                guard let profileType =  noti.userInfo? ["ProfileType"] as? ProfileType else {
                    print("ProfileType Fail b")
                    return
                }
                let vc = UserProfileViewController()
                vc.profileType = profileType
                owner.navigationController?.setNavigationBarHidden(false, animated: true)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
        // MARK: 네비게이션 세팅
        viewWillNavigationSettring()
    }
    override func navigationSetting() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 25))
        imageView.contentMode = .scaleAspectFit
        imageView.image = JHImage.appLogoImage
        navigationItem.titleView = imageView
    }
    
    private
    func viewWillNavigationSettring(){
        // MARK: 네비게이션 세팅
        let searchViewController = SearchHashTagViewController(
            backNavigation: navigationController
        )
        
        let searchController = UISearchController(searchResultsController: searchViewController)
        
        searchController.searchBar.placeholder = "Search For HashTag"
         searchController.hidesNavigationBarDuringPresentation = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchBar.rx.text.orEmpty
            .skip(1)
            .distinctUntilChanged()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, text in
                searchViewController.getText(text)
            }
            .disposed(by: disPoseBag)
        
        rx.viewDidDisapear
            .bind(with: self) { owner, _ in
                DispatchQueue.main.async {
                    owner.navigationItem.searchController?.isActive = false
                    owner.navigationItem.searchController = nil
                }
            }
            .disposed(by: disPoseBag)
    
        
    }
    
    override func subscribe() {
        
        guard let myID = UserIDStorage.shared.userID else {
            errorCatch(.loginError(statusCode: 419, description: "아이디가 조회되지 않고있어요!"))
            return
        }
        let refreshAction = represhControl.rx.controlEvent(.valueChanged)
        
        // 카테고리(프로덕트 아이디) 선택시 방출
        let selectedProductID = BehaviorRelay<ProductID> (value: .dailyRoutine)
        // 추가 요청 발생시
        let needLoadPage = PublishRelay<Void> ()
        // 지우기 API 구성 해야함 일단 수정에서 해결해 볼것
        let deleteModel = PublishRelay<SNSDataModel> ()
        let checkedDeleteModel = PublishRelay<SNSDataModel> ()
        
        let alreadyDelete = PublishRelay<Int> ()
        
        let reloadTrigger = PublishRelay<Void> ()
        
        let input = SNSPhotoMainViewModel.Input(
            viewDidAppearTrigger: rx.viewDidAppear,
            needLoadPageTrigger: needLoadPage,
            selectedProductID: selectedProductID,
            checkedDeleteModel: checkedDeleteModel,
            reloadTrigger: reloadTrigger,
            alreadyDelete: alreadyDelete
        )
        
        let output = viewModel.transform(input)
        
        
        // MARK: 에러 발생시
        output.networkError
            .drive(with: self) { owner, error in
                owner.showAlert(error: error) { _ in
                    if error.errorCode == 419 {
                        owner.goLoginView()
                    }
                }
            }
            .disposed(by: disPoseBag)
    
        let dataSource = RxTableViewSectionedAnimatedDataSource<SNSSectionModel>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .automatic,
                reloadAnimation: .automatic,
                deleteAnimation: .fade)) {[weak self] dataSource, tableView, indexPath, item in
                    guard let self else {
                        print("RxTableViewSectionedAnimatedDataSource Error")
                        return .init()
                    }
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: SNSTableViewCell.reusableIdenti, for: indexPath) as? SNSTableViewCell else {
                        return .init()
                    }
                    print("Current: 변환되는거 맞니..?\(indexPath.item)",item.currentIamgeAt)
                    item.currentRow = indexPath.item
                    cell.setModel(item, output.userIDDriver.value, delegate: viewModel)
                    cell.currentPageDelegate = viewModel
                    cell.selectionStyle = .none
                    return cell
                }
        
        output.tableViewItems
            .map { [SNSSectionModel(model: "", items: $0)]}
            .bind(to: homeView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disPoseBag)
        
        // View
        let hearderDataSource = RxHeaderDataSource { dataSource, collectionView, IndexPath, model in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryReusableCell.reusableIdenti, for: IndexPath) as? CategoryReusableCell else {
                return .init()
            }
            let isSelected = selectedProductID.value.identi == model.identi
            cell.setSection(model)
            cell.isSelected(isSelected)
            return cell
        }
        
        headerItems
            .bind(to: homeView.headerView.collectionView.rx.items(
                dataSource: hearderDataSource))
            .disposed(by: disPoseBag)
        
        homeView.headerView.collectionView.rx.modelSelected(ProductID.self)
            .distinctUntilChanged()
            .debounce(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, productModel in
                // print(productModel)
                selectedProductID.accept(productModel)
                owner.homeView.headerView.collectionView.reloadData()
                owner.checkAndMoveToTop()
            }
            .disposed(by: disPoseBag)
    
        
        // 조건 묶기
        let combineRequstForMore = Observable.combineLatest(
            output.pullDataCount,
            homeView.tableView.rx.willDisplayCell,
            output.ifCanReqeust
        )
            .map { fullDataCount, cellEvent, ifCan in
                return (fullDataCount: fullDataCount,cellEvent: cellEvent, ifCan: ifCan)
            }
        
        // 또 요청하기
        combineRequstForMore
            .filter { $0.cellEvent.indexPath.row >= $0.fullDataCount - 3 && $0.ifCan }
            .bind(with: self) { owner, _ in
                print("요청합니다.")
                needLoadPage.accept(())
            }
            .disposed(by: disPoseBag)
        
        let moreButtonTap = PublishRelay<SNSDataModel> ()
        let modifyModel = PublishRelay<SNSDataModel> ()
        
        
        // moreButton 클릭시 모델 받기
        NotificationCenter.default.rx.notification(.selectedMoreButton, object: nil)
            .bind(with: self) { owner, notification in
                guard let dataModel = notification.userInfo? ["SNSDataModel"] as? SNSDataModel else {
                    print("모델 변환 실패")
                    return
                }
                moreButtonTap.accept(dataModel)
            }
            .disposed(by: disPoseBag)
        // ... 버튼 클릭시
        moreButtonTap
            .bind(with: self) { owner, model in
                if model.creator.userID != myID {
                    let modalViewCon = MorePageViewController()
                    modalViewCon.setModel(model.creator)
                    
                    modalViewCon.modalPresentationStyle = .pageSheet
                    owner.present(modalViewCon, animated: true)
                } else {
                 // 이때는 포스트 수정으로 진행해야 합니다!
                    owner.showActionSheet(title: nil, message: nil, actions: [
                        (title: "프로필보기", handler: { _ in
                            let modalViewCon = MorePageViewController()
                            modalViewCon.setModel(model.creator)
                            
                            modalViewCon.modalPresentationStyle = .pageSheet
                            owner.present(modalViewCon, animated: true)
                        }),
                        (title: "게시글 수정", handler: {_ in
                            modifyModel.accept(model)
                        }),
                        (title: "게시글 삭제", handler: {_ in
                            deleteModel.accept(model)
                        })
                    ]
                    )
                }
            }
            .disposed(by: disPoseBag)
        modifyModel
            .bind(with: self) { owner, model in
                let vc = PostRegViewController()
                vc.ifModifyModel = model
                vc.hidesBottomBarWhenPushed = true
                
                NotificationCenter.default.post(name: .hidesBottomBarWhenPushed, object: nil)
                
                vc.modifyDelegate = owner.viewModel
                vc.ifDeleteChanege = { at in
                    alreadyDelete.accept(at)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
    
        deleteModel
            .bind(with: self) { owner, model in
                owner.showAlert(
                    title: "삭제",
                    message: "삭제하시면 복구하실수 없습니다!",
                    actionTitle: "삭제",
                    { _ in
                        checkedDeleteModel.accept(model)
                    },
                    .default
                )
            }
            .disposed(by: disPoseBag)

        // 프레젠트 뷰컨에서 프로필 이동 신호를 받았다면
        NotificationCenter.default.rx.notification(.moveToProfile, object: nil)
            .bind(with: self) { owner, notification in
                guard let profileType = notification.userInfo? ["profileUserId"] as? ProfileType else {
                    print("profileType 변환 실패")
                    return
                }
                let vc = UserProfileViewController()
                
                vc.profileType = profileType
                owner.navigationController?.setNavigationBarHidden(false, animated: true)
                vc.hidesBottomBarWhenPushed = true
                
                NotificationCenter.default.post(name: .hidesBottomBarWhenPushed, object: nil)
                 
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
        
        NotificationCenter.default.rx.notification(.moveToSettingProfile)
            .bind(with: self) { owner, _ in
                let vc = ProfileSettingViewController()
                vc.hidesBottomBarWhenPushed = true
                NotificationCenter.default.post(name: .hidesBottomBarWhenPushed, object: nil)
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
        
        NotificationCenter.default.rx.notification(.commentButtonTap)
            .bind(with: self) { owner, notification in
                guard let profileType = notification.userInfo? ["SNSDataModel"] as? SNSDataModel else {
                    print("SNSDataModel2 변환 실패")
                    return
                }
                let vc = CommentViewController()
                let nvc = UINavigationController(rootViewController: vc)
                vc.setModel(profileType)
                owner.navigationController?.present(nvc, animated: true)
            }
            .disposed(by: disPoseBag)
        
        refreshAction
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                reloadTrigger.accept(())
                owner.represhControl.endRefreshing()
            }
            .disposed(by: disPoseBag)
        
    }
    
    
}


extension SNSPhotoViewController {
    func checkAndMoveToTop() {
        let numberOfRow = homeView.tableView.numberOfRows(inSection: 0)
        if numberOfRow > 0 {
            let index = IndexPath(row: 0, section: 0)
            homeView.tableView.scrollToRow(at: index, at: .top, animated: true)
        }
    }
}


extension SNSDataModel: IdentifiableType {
    
    var identity: String {
        return postId
    }
    
    typealias Identity = String
}
