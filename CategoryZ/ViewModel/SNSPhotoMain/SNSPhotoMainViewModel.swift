//
//  SNSPhotoMainViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa


protocol LikeStateProtocol: AnyObject {
    func changeLikeState(_ model: LikeQueryModel,_ postId: String)
}

final class SNSPhotoMainViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
   
    private
    var realPostData: [SNSDataModel] = []
    
    // 포스트 데이타들
    private // Value 접근시 무조건 ..... ㅠㅠㅠ
    let postsDatas = PublishRelay<[SNSDataModel]> ()
        
    
    // 네트워크 에러 발생시
    private
    let networkError = PublishRelay<NetworkError> ()
    
    private
    let userId = UserIDStorage.shared.userID
    
    private
    let allReloadTrigger = PublishRelay<Void> ()
    
    private
    let ifModifyModel = PublishRelay<SNSDataModel> ()

    struct Input {
        // 첫 시작 트리거
        let viewDidAppearTrigger : ControlEvent<Bool>
        // 추가 요청 패이지 트리거
        let needLoadPageTrigger : PublishRelay<Void>
        // 카테고리 선택시
        let selectedProductID: BehaviorRelay<ProductID>
        // 체크확인된 지울모델
        let checkedDeleteModel: PublishRelay<SNSDataModel>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let tableViewItems: PublishRelay<[SNSDataModel]>
        let userIDDriver: BehaviorRelay<String>
        let pullDataCount: BehaviorRelay<Int>
        let ifCanReqeust: BehaviorRelay<Bool>
        let successDelteTrigger: PublishRelay<SNSDataModel>
    }
    
    func transform(_ input: Input) -> Output {
        let limit = "10"
        
        let userId = BehaviorRelay<String> (value: UserIDStorage.shared.userID ?? "" )
    
        let pullDataCountBR = BehaviorRelay(value: 0)
        let ifCanReqeust = BehaviorRelay(value: false
        )
        let selectedProductId = BehaviorRelay(value: "")
        
        // 다음 커서
        let nextCursor = BehaviorRelay<String?> (value: nil)
        
        // 지우기 완료됨의 트리거
        let successDelteTrigger = PublishRelay<SNSDataModel> ()
        
        let request = input.needLoadPageTrigger.asObservable()
            .withUnretained(self)
        .flatMapLatest { owner, _ in
            NetworkManager
                .fetchNetwork(
                model: SNSMainModel.self,
                router: .poster(
                    .postRead(next: nextCursor.value,
                              limit: limit, productId: input.selectedProductID.value.identi
                             )
                )
            )
        }
        
        request.bind(with: self) { owner, result in
            switch result{
            case .success(let model):
                nextCursor.accept(model.nextCursor)
                print("model.nextCursor : \(model.nextCursor)")
                owner.realPostData.append(contentsOf: model.data)
                
                owner.postsDatas.accept(owner.realPostData)

                ifCanReqeust.accept(model.nextCursor != "0")
                
                pullDataCountBR.accept(owner.realPostData.count)
            case .failure(let fail):
                owner.networkError.accept(fail)
            }
        }
        .disposed(by: disposeBag)
        
        // 강제 리로드 (사용되진 않지만 특수 케이스가 발생하면 사용할것)
        allReloadTrigger
            .bind(with: self) { owner, _ in
                nextCursor.accept(nil)
                owner.realPostData = []
                owner.postsDatas.accept(owner.realPostData)
                input.needLoadPageTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        
        // 카테고리를 클릭하였을때
        // 넥스트를 nil 로 만들고 요청해야 함.

        input.selectedProductID
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .flatMapLatest { owner, productId in
                
                selectedProductId.accept(productId.identi)
                
                nextCursor.accept(nil)
                
                return NetworkManager.fetchNetwork(model: SNSMainModel.self, router: .poster(.postRead(next: nil, limit: limit, productId: productId.identi)))
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let model):
                    nextCursor.accept(model.nextCursor)
                    print("model.nextCursor : \(model.nextCursor)")
                  owner.realPostData = model.data
                    
                    owner.postsDatas.accept(owner.realPostData)

                    ifCanReqeust.accept(model.nextCursor != "0")
                    
                    pullDataCountBR.accept(owner.realPostData.count)
                case .failure(let fail):
                    owner.networkError.accept(fail)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.successPost)
            .bind { _ in
                
                let value = input.selectedProductID.value
                input.selectedProductID.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.checkedDeleteModel
            .flatMapLatest { model in
            NetworkManager.noneModelRequest(router: .poster(.postDelete(postID: model.postId)))
                    .map { result in
                        return (results: result, model: model)
                    }
            }
            .bind(with: self) { owner, results in
                switch results.results {
                case .success:
                    owner.realPostData.remove(at: results.model.currentRow)
                    owner.postsDatas.accept(owner.realPostData)
                    successDelteTrigger.accept(results.model)
                case .failure(let fail):
                    owner.networkError.accept(fail)
                }
            }
            .disposed(by: disposeBag)
        
        ifModifyModel
            .bind(with: self) { owner, model in
                if owner.realPostData[model.currentRow].productId == model.productId {
                    owner.realPostData[model.currentRow] = model
                    owner.postsDatas.accept(owner.realPostData)
                } else {
                    owner.realPostData.remove(at: model.currentRow)
                    owner.postsDatas.accept(owner.realPostData)
                }
            }
            .disposed(by: disposeBag)
        
        return .init(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            tableViewItems: postsDatas,
            userIDDriver: userId,
            pullDataCount: pullDataCountBR,
            ifCanReqeust: ifCanReqeust,
            successDelteTrigger: successDelteTrigger
        )
    }

}

extension SNSPhotoMainViewModel: LikeStateProtocol {
    
    func changeLikeState(_ model: LikeQueryModel, _ postId: String) {
        print(model)
        guard let userId else { return }
        
        NetworkManager.fetchNetwork(model: LikeQueryModel.self, router: .like(.like(query: model, postId: postId)))
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let likeModel):
                    let updatedPosts = owner.realPostData
                
                    let postToUpdate =  updatedPosts[model.currentRow]
                   
                    // [SNSDataModel]
                    
                    if likeModel.like_status {
                        if !postToUpdate.likes.contains(userId) {
                            postToUpdate.changeLikeModel(userId, likeBool: true)
                        }
                    } else {
                        postToUpdate.changeLikeModel(userId, likeBool: false)
                    }

                    owner.realPostData[model.currentRow] = postToUpdate
                    
                    owner.postsDatas.accept(owner.realPostData)

                    // print(updatedPosts)
                    
                    owner.printMemoryAddress(of: postToUpdate, addMesage: "updatedPosts  :")
                   
                case .failure(let error):
                    owner.networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
    }
    func printMemoryAddress<T: AnyObject>(of object: T, addMesage: String) {
        let address = Unmanaged.passUnretained(object).toOpaque()
        print("주소 \(addMesage): \(address)")
    }
}

extension SNSPhotoMainViewModel: ModifyDelegate {
    
    func mofifyedModel(_ model: SNSDataModel) {
         // model.productId 해당 것과 비교후 변경
        // 현재 로우 왜 현재 반영 안되고 있는지 확인할것.
        ifModifyModel.accept(model)
    }
}

extension SNSPhotoMainViewModel: CurrentPageProtocol {
    func currentPage(model: SNSDataModel) {
        print("Current 변환되어 온 모델",model,model.currentIamgeAt)
        ifModifyModel.accept(model)
    }
}
