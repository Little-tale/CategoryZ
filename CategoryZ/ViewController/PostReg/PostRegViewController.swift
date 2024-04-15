//
//  PostRegViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit
import RxSwift
import RxCocoa

enum cameraOrImage {
    case camera
    case image
}

final class PostRegViewController: RxHomeBaseViewController<PostRegView> {
    
    let category = PublishRelay<[ProductID]> ()
    
    private
    lazy var imageService = RxCameraImageService(presntationViewController: self)
    
    let viewModel = PostRegViewModel()
    
    var selected: ProductID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
    }
    
    override func navigationSetting() {
        navigationItem.title = "게시물 작성"
    }
    
    override func subscribe() {
        let product = ProductID.allCases
        let publishSelectProductId = BehaviorRelay<ProductID?> (value: nil)
        let behiberImageData = BehaviorRelay<[Data]> (value: [])
        
        let input = PostRegViewModel.Input(
            selectedProduct: publishSelectProductId,
            insertImageData: behiberImageData
        )
        
        let output = viewModel.transform(input)
        
        output.outputIamgeDataDriver
            .drive(
                homeView.imageCollectionView.rx.items(
                    cellIdentifier: OnlyImageCollectionViewCell.identi,
                    cellType: OnlyImageCollectionViewCell.self
                )
            ) { row, item, cell in
                print(item)
                cell.imageSetting(item)
            }
            .disposed(by: disPoseBag)
               
        // 이미지 최대 숫자
        output.maxCout.drive(imageService.rx.maxCount)
            .disposed(by: disPoseBag)
        
        // 카테고리 뿌리기
        category.bind(to: homeView.categoryCollectionView.rx.items(cellIdentifier: CategoryReusableCell.identi, cellType: CategoryReusableCell.self)) {[weak self] row , item, cell in
            guard let self else { return }
            
            cell.setSection(item)
            if let selected,
               selected == item {
                cell.isSelected(true)
            }else {
                cell.isSelected(false)
            }
        }
        .disposed(by: disPoseBag)
        
        // 선택된 모델 가져오기
        homeView.categoryCollectionView.rx.modelSelected(ProductID.self)
            .distinctUntilChanged()
            .bind(with: self, onNext: { owner, product in
                owner.selected = product
                publishSelectProductId.accept(product)
                print(product)
                owner.homeView.categoryCollectionView.reloadData()
            })
            .disposed(by: disPoseBag)
        
        category.accept(product)
        
        // MARK: 이미지 서비스 구독 입니다.
        
        // imageAddButtonTab
        homeView.imageAddButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.imageService.showImageModeSelectAlert()
            }
            .disposed(by: disPoseBag)
        
        imageService.imageResult
            .bind {[weak self] result in
                guard let self else { return }
                switch result {
                case .success(let images):
                    print(images)
                    behiberImageData.accept(images)
                case .failure(let error):
                    if case .noAuth = error {
                        SettingAlert()
                    }else {
                        showAlert(title: "경고",message: error.message) { _ in
                        }
                    }
                }
            }
            .disposed(by: disPoseBag)
    }
}


extension PostRegViewController {
    
    func showAlertActions() {
        
    }
}


// MARK: 권한 설정 페이지 이동
extension UIViewController {
    
    func SettingAlert(){
        showAlert(title: "권한 없음", message: "카메라 권한이 있어야만 합니다.", actionTitle: "이동하기") {
            [weak self] action in
            guard let self else {return}
            goSetting()
        }
    }
    
    func goSetting(){
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingUrl)
        } else {
            showAlert(title: "실패", message: "이동하기 실패") { _ in
            }
        }
        
    }
   
}
