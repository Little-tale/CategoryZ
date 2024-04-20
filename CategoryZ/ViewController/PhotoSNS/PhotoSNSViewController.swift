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
            .map({ $0.realPostData })
            .drive(homeView.tableView.rx.items(cellIdentifier: SNSTableViewCell.identi, cellType: SNSTableViewCell.self)) {[weak self] row, model, cell in
                guard let self else { return }
                
                printMemoryAddress(of: model, addMesage: "modelㄱ :")
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
            .bind(with: self) { owner, productModel in
                // print(productModel)
                selectedProductID.accept(productModel)
                owner.homeView.headerView.collectionView.reloadData()
            }
            .disposed(by: disPoseBag)
        
        
        
        homeView.tableView.rx.contentOffset
            .withUnretained(self)
            .bind {owner, point in
                // print("테이블뷰 총 높이: ",owner.homeView.tableView.contentSize.height) // 이걸 기반으로 높이 에서 일정부분에 다다르면 요청하면 될것 같음
                //print("테이블뷰 포인터 Y: ", point.y) // 이것으로 어느 시점에 다다르면 요청 트리거를 동작시키면 문제가 없을것 같다.
                let fullHeight = owner.homeView.tableView.contentSize.height
                if fullHeight - point.y <= 130 {
                    needLoadPage.accept(())
                }
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

extension SNSPhotoViewController: NetworkErrorCatchProtocol {
    
    func errorCatch(_ error: NetworkError) {
        showAlert(error: error) { [unowned self] _ in
            if error.errorCode == 419 {
                goLoginView()
            }
        }
    }
    
    func printMemoryAddress<T: AnyObject>(of object: T, addMesage: String) {
        let address = Unmanaged.passUnretained(object).toOpaque()
        print("주소 \(addMesage): \(address)")
    }

}

