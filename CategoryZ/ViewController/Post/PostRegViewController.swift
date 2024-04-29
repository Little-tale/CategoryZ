//
//  PostRegViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

enum cameraOrImage {
    case camera
    case image
}


final class PostRegViewController: RxHomeBaseViewController<PostRegView> {
    
    let category = PublishRelay<[ProductID]> ()
    let rightBarButton = UIBarButtonItem(systemItem: .save).then {
        $0.tintColor = .point
    }
    let deleteButton = UIBarButtonItem(title: "삭제").then {
        $0.tintColor = JHColor.warningColor
    }
    
    private
    lazy var imageService = RxCameraImageService(presntationViewController: self, zipRate: 5)
    
    let viewModel = PostRegViewModel()
    
    var selected: ProductID?
    
    var ifModifyModel: SNSDataModel?
    
    // let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSettings()
    }
    
    private
    func navigationSettings() {
        let flexiebelItem = UIBarButtonItem(systemItem: .flexibleSpace)
        flexiebelItem.width = 40
        navigationItem.rightBarButtonItems = [
            rightBarButton,
            flexiebelItem,
            deleteButton
        ]
        
        if ifModifyModel != nil {
            navigationItem.title =  "게시물 수정"
        } else {
            navigationItem.title =  "게시물 작성"
            deleteButton.isHidden = true
        }
        
        
        
    }
    
    override func subscribe() {
        
        // 프로덕트 아이디
        let product = ProductID.allCases
        
        // 프로덕트 아이디 선택 시
        let publishSelectProductId = BehaviorRelay<ProductID?> (value: nil)
        // 이미지 데이터들
        let behiberImageData = BehaviorRelay<[Data]> (value: [])
        let behaviorImageAcepts = BehaviorRelay<[CGFloat]> (value: [])
        let removeSelectModel = PublishRelay<IndexPath> ()
        let modifyInImageURLs = BehaviorRelay<[String]> (value: [])
        
        let ifModifyModel = BehaviorRelay<SNSDataModel?> (value: ifModifyModel)
        
        let postRemveTrigger = PublishRelay<Void> ()
        
        let input = PostRegViewModel.Input(
            selectedProduct: publishSelectProductId,
            insertImageData: behiberImageData,
            saveButtonTap: rightBarButton.rx.tap,
            contentText: homeView.contentTextView.rx.text,
            startTrigger: rx.viewDidAppear,
            removeSelectModel: removeSelectModel,
            imageAcepts: behaviorImageAcepts,
            ifModifyModel: ifModifyModel,
            modifyInImageURLs: modifyInImageURLs,
            removeTrigger: postRemveTrigger
        )
        
        let output = viewModel.transform(input)
        
        /// 허용된 텍스트
        output.contentText.drive(homeView.contentTextView.rx.text)
            .disposed(by: disPoseBag)

        
        // 적어도 하나를 띄우기 위해 nil을 이용
        let addORImageDataDriver = output.outputIamgeDataDriver
            .map { imageData -> [Data?] in
                return imageData.isEmpty ? [nil] : imageData
            }
        // 이미지 데이터가 없을경우 추가셀 아니면 이미지셀
        addORImageDataDriver
            .drive(homeView.imageCollectionView.rx.items) { collectionView, row, item in
                if let item {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnlyImageCollectionViewCell.identi, for: IndexPath(row: row, section: 0)) as? OnlyImageCollectionViewCell else {
                        print("OnlyImageCollectionViewCell Error")
                        return UICollectionViewCell.init()
                    }
                    cell.imageSetting(item)
                    return cell
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddCollectionViewCell.identi, for: IndexPath(row: row, section: 0)) as? AddCollectionViewCell else {
                        print("AddCollectionViewCell Error")
                        return UICollectionViewCell.init()
                    }
                    return cell
                }
            }
            .disposed(by: disPoseBag)
        
        /// 데이터가 있는가 없는것으로, 이미지추가 여부 정합니다.
        output.outputIamgeDataDriver
            .drive(with: self) { owner, data in
                owner.homeView.imageAddButton.isHidden = data.isEmpty
            }
            .disposed(by: disPoseBag)
        
        
        // 이미지가 없거나 있을때 선택시
        let imaegCollectionViewMerge = Observable.zip(homeView.imageCollectionView.rx.itemSelected, homeView.imageCollectionView.rx.modelSelected(Data?.self))
        
        imaegCollectionViewMerge
            .throttle(.milliseconds(300),
                      scheduler: MainScheduler.instance
            )
            .withUnretained(self)
            .map { owner, collection in
                return (owner: owner, index: collection.0, data: collection.1)
            }
            .bind { result in
                if result.data != nil {
                    // 이미지 삭제 할건지 알리기
                    result.owner.showAlert(title: "삭제", message: "정말 지우실건가요?", actionTitle: "삭제", .destructive) { _ in
                        removeSelectModel.accept(result.index) // index 전달
                    }
                } else {
                    result.owner.imageService.showImageModeSelectAlert()
                }
            }
            .disposed(by: disPoseBag)
        
        // 이미지 최대 숫자
        output.maxCout.drive(imageService.rx.maxCount)
            .disposed(by: disPoseBag)
        
        // 저장 버튼 활성화 여부
        output.saveButtonEnabled
            .drive(rightBarButton.rx.isEnabled)
            .disposed(by: disPoseBag)
        
        // 유저정보를 잘 받아왔을시
        output.userInfo
            .drive(with: self) { owner, creator in
                // owner.homeView.profileImage
                owner.homeView.setProfile(creator)
            }
            .disposed(by: disPoseBag)
        
        // 네트워크 에러 발생시
        output.networkError
            .drive(with: self) { owner, error in
                print("errorCode",error.errorCode)
                if error.errorCode != 419 {
                    print("맞아요!")
                    owner.showAlert(error: error)
                }
            }
            .disposed(by: disPoseBag)
        
        // 업로드 성공시
        output.successPost
            .drive(with: self) { owner, _ in
                
                owner.showAlert(title: "업로드", message: "업로드 성공") { _ in
                    if owner.ifModifyModel == nil {
                        NotificationCenter.default.post(name: .successPost, object: nil)
                        owner.dismiss(animated: true)
                    } else {
                         owner.navigationController?.popViewController(animated: true)
                        NotificationCenter.default.post(name: .successPost, object: nil)
                    }
                }
            }
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
        
        category.accept(product)
        
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
        
        // 만약 수정 모델이 들어와 존재한다면

    ifModifyModel
            .compactMap { $0 }
            .bind(with: self) { owner, model in
                owner.homeView.contentTextView.text = model.content
                owner.homeView.contentTextView.placeholderText = ""
                if let selectedProduct = ProductID(rawValue: model.productId) {
                    publishSelectProductId.accept(selectedProduct)
                    owner.selected = selectedProduct
                }
                // 이미지도 다시 넣어 주어야함
                modifyInImageURLs.accept(model.files)
            }
            .disposed(by: disPoseBag)
        
        modifyInImageURLs
            .bind(with: self) {owner, strings in
                owner.downloadImages(imageUrl: strings, resizing: CGSize(width: 400, height: 400)) { result in
                    switch result {
                    case .success(let success):
                        behiberImageData.accept(success)
                    case .failure(let failure):
                        owner.errorCatch(failure)
                    }
                }
            }
            .disposed(by: disPoseBag)
       
        // 수정 모드에서 삭제 버튼을 눌렀을때의 로직입니다
        deleteButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showAlert(
                    title: "삭제",
                    message: "게시글을 삭제하시면 복구하실수 없습니다!",
                    actionTitle: "삭제",
                    complite: { _ in
                        postRemveTrigger.accept(())
                    },
                    .destructive
                )
            }
            .disposed(by: disPoseBag)
        output.removePost
            .throttle(.milliseconds(120))
            .drive(with: self) { owner, _ in
                owner.view.makeToast("삭제가 완료되었습니다.", duration: 2, position: .center)
                NotificationCenter.default.post(name: .successPost, object: nil)
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disPoseBag)
         
        // MARK: === 이미지 서비스 구독 입니다. ===
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
                    } else {
                        showAlert(title: "경고",message: error.message) { _ in
                        }
                    }
                }
            }
            .disposed(by: disPoseBag)
        /// 이미지 사이즈( 비 ) 를 구독합니다.
        imageService.imageAcepts
            .bind { acepts in
                acepts.forEach { print($0) }
                behaviorImageAcepts.accept(acepts)
            }
            .disposed(by: disPoseBag)
        
        NotificationCenter.default.rx.notification(.cantRefresh, object: nil)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(with: self) { owner, noti in
                owner.showAlert(title: "로그인 만료") { _ in
                    owner.goLoginView()
                }
        }
            .disposed(by: disPoseBag)

    }

    
}

