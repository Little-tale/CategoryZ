//
//  PostRegViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import Foundation
import RxSwift
import RxCocoa

import Foundation
import RxSwift
import RxCocoa

final class PostRegViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    var imageDatas: [Data] = []
    
    let textValid = TextValid()
    var currentText = ""
    
    struct Input {
        // 선택된 모델 ID
        let selectedProduct: BehaviorRelay<ProductID?> // 카테고리
        let insertImageData: BehaviorRelay<[Data]> // 이미지 데이터
        let saveButtonTap: ControlEvent<Void> // 저장 버튼탭
        let contentText: ControlProperty<String?>
        
        let startTrigger: ControlEvent<Bool>
    }
    
    struct Output{
        let outputIamgeDataDriver: Driver<[Data]>
        let maxCout: Driver<Int>
        let saveButtonEnabled: Driver<Bool>
        let contentText: Driver<String>
        let userInfo: Driver<Creator>
        let networkError: Driver<NetworkError>
        let successPost: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        // 1. 현재 사용자 정보를 가져오기
        let outputUserInfo = PublishRelay<Creator> ()
        // 이미지 데이터들 출구
        let outputImageDatas = BehaviorRelay<[Data]> (value: imageDatas)
        // 이미지 최대 갯수 계산
        let outputImageMaxCount = BehaviorRelay(value: 5)
        // 허용된 텍스트만
        let outputText = BehaviorRelay(value: currentText)
        // 프로덕트 아이디 있는지 검사
        let productId = BehaviorRelay<ProductID?> (value: nil)
        // 네트워크 에러 방출
        let networkError = PublishRelay<NetworkError> ()
        
        // 이미지 업로드 성공 트리거
        let imageUploadScueess = PublishRelay<(imageModel:ImageDataModel, content:String, productId: String)> ()
        
        // 포스트 성공 트리거
        let successPost = PublishRelay<Void> ()
        
        input.startTrigger.bind { _ in
            NetworkManager.fetchNetwork(model: Creator.self, router: .profile(.profileMeRead))
                .subscribe(with: self) { owner, result in
                    switch result {
                    case .success(let data):
                        outputUserInfo.accept(data)
                    case .failure(let error):
                        networkError.accept(error)
                    }
                }
                .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
        // 1. 유저 정보 가져오기
        
        
        // 이미지 데이타 + 이미지 갯수 제한
        input.insertImageData
            .bind(with: self) { owner, datas in
                var before = owner.imageDatas
                before.append(contentsOf: datas)
                owner.imageDatas = before
                outputImageDatas.accept(owner.imageDatas)
                outputImageMaxCount.accept( 5 - owner.imageDatas.count)
            }
            .disposed(by: disposeBag)
        
        // 텍스트 검사와, 이미지데이터 있는지, 선택된 프로덕트 있는지
        input.contentText
            .orEmpty
            .bind(with: self) { owner, text in
                
                if text.count == 0 {
                    outputText.accept(text)
                    owner.currentText = text
                    return
                }
                if owner.textValid.contentTextValid(text) {
                    outputText.accept(text)
                    owner.currentText = text
                } else {
                    outputText.accept(owner.currentText)
                }
            }
            .disposed(by: disposeBag)
        
        
        let tapValidConbine = Observable.combineLatest(
            input.contentText.orEmpty,
            outputImageDatas,
            productId
        )
            .share()
        
           
        let tapValid = tapValidConbine
            .withUnretained(self)
            .map { owner, property in
                return owner.textValid.contentTextValid(property.0) && !property.1.isEmpty && ((property.2?.identi) != nil)
            }
            .asDriver(onErrorJustReturn: false)
        
        // 텍스트 ID 값전달 받았을때
        input.selectedProduct
            .bind(with: self) { owner, productID in
                if let productID {
                    productId.accept(productID)
                }
            }
            .disposed(by: disposeBag)
        
        
      // 버튼을 누르면 이미지 먼저 업로드후
       input.saveButtonTap
            .withLatestFrom(tapValidConbine)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .filter({ $0.2 != nil })
            .map({ content in
                return (contents: content.0, datas: content.1, productId: content.2!)
            })
            .flatMap { content in
                NetworkManager.uploadImages(model: ImageDataModel.self, router: .imageUpload, images: content.datas).map { result in
                    return (result, content.contents, content.productId)
                }
            }
            .bind { result in
                switch result.0 {
                case .success(let imageModel):
                    imageUploadScueess.accept((imageModel: imageModel, content: result.1, productId: result.2.identi))
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
            
        
        // 이미지 업로드를 마치면 다시 포스트 업로드 실행
      imageUploadScueess
            .flatMap { model in
                let query = MainPostQuery(title: "", content: model.content, content2: "", content3: "", product_id: model.productId, files: model.imageModel.files)
                
                return NetworkManager.fetchNetwork(model: PostModel.self, router: .poster(.postWrite(query: query)))
            }
            .bind { result in
                switch result {
                case .success(_):
                    successPost.accept(())
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            outputIamgeDataDriver: outputImageDatas.asDriver(),
            maxCout: outputImageMaxCount.asDriver(),
            saveButtonEnabled: tapValid,
            contentText: outputText.asDriver(),
            userInfo: outputUserInfo.asDriver(onErrorDriveWith: .never()),
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            successPost: successPost.asDriver(onErrorDriveWith: .never())
        )
    }
    
}

