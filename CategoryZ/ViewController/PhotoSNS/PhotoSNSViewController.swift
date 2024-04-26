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
/*
 데이터를 불러와야 하는데
 커서기반 페이지 네이션을 알아보도록 하자
 */

final class SNSPhotoViewController: RxHomeBaseViewController<PhotoSNSView> {
    
    typealias RxHeaderDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String,ProductID>>
    
    private let headerItems = Observable.just([
        SectionModel(model: "Section", items: [
            ProductID.dailyRoutine,
            ProductID.fashion,
            ProductID.pet
        ])
    ])
    
    private let viewModel = SNSPhotoMainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeView.tableView.tableHeaderView = homeView.headerView
        
    }
    
    override func subscribe() {
        
        guard let myID = UserIDStorage.shared.userID else {
            errorCatch(.loginError(statusCode: 419, description: "아이디가 조회되지 않고있어요!"))
            return
        }
        
        // 카테고리(프로덕트 아이디) 선택시 방출
        let selectedProductID = BehaviorRelay<ProductID> (value: .dailyRoutine)
        // 추가 요청 발생시
        let needLoadPage = PublishRelay<Void> ()
        
        let input = SNSPhotoMainViewModel.Input(
            viewDidAppearTrigger: rx.viewDidAppear,
            needLoadPageTrigger: needLoadPage,
            selectedProductID: selectedProductID
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
    
        
        // 데이터 방출시 테이블 뷰
        output.tableViewItems
            .distinctUntilChanged()
            .bind(to:homeView.tableView.rx.items(cellIdentifier: SNSTableViewCell.identi, cellType: SNSTableViewCell.self)) {[weak self] row, model, cell in
                guard let self else { return }
                
                let reciveModel = model
                reciveModel.currentRow = row
                cell.setModel(reciveModel, output.userIDDriver.value, delegate: viewModel)
                cell.selectionStyle = .none
            }
            .disposed(by: disPoseBag)
        
        // View
        let hearderDataSource = RxHeaderDataSource { dataSource, collectionView, IndexPath, model in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryReusableCell.identi, for: IndexPath) as? CategoryReusableCell else {
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
        
        moreButtonTap
            .bind(with: self) { owner, model in
                if model.creator.userID != myID {
                    let modalViewCon = MorePageViewController()
                    modalViewCon.setModel(model.creator)
                    
                    modalViewCon.modalPresentationStyle = .pageSheet
                    owner.present(modalViewCon, animated: true)
                } else {
                 // 이때는 포스트 수정으로 진행해야 합니다!
                    let vc = PostRegViewController()
                    vc.ifModifyModel = model
                    // 다음에 와야함
                }
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
                vc.hidesBottomBarWhenPushed = true
                //vc.modalPresentationStyle = .popover
//                vc.modalPresentationStyle = .overFullScreen
                
                NotificationCenter.default.post(name: .hidesBottomBarWhenPushed, object: nil)
                vc.hidesBottomBarWhenPushed = true 
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
        
        NotificationCenter.default.rx.notification(.moveToSettingProfile)
            .bind(with: self) { owner, _ in
                let vc = ProfileSettingViewController()
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
        
        
    }
    
    override func navigationSetting() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 25))
        imageView.contentMode = .scaleAspectFit
        imageView.image = JHImage.appLogoImage
        navigationItem.titleView = imageView
    }
}

extension UIViewController {
    
    func printMemoryAddress<T: AnyObject>(of object: T, addMesage: String) {
        let address = Unmanaged.passUnretained(object).toOpaque()
        print("주소 \(addMesage): \(address)")
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
