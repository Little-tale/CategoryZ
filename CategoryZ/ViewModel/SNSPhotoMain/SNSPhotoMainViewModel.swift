//
//  SNSPhotoMainViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SNSPhotoMainViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
   
    
    struct Input {
        // 첫 시작 트리거
        let viewDidAppearTrigger : ControlEvent<Bool>
        // 추가 요청 패이지 트리거
        let needLoadPageTrigger : PublishRelay<Void>
        // 카테고리 선택시
        let selectedProductID: BehaviorRelay<ProductID>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let tableViewItems: Driver<[SNSDataModel]>
    }
    
    func transform(_ input: Input) -> Output {
        let limit = "10"
        
        // 포스트 데이타들
        let postsDatas = BehaviorRelay<[SNSDataModel]> (value: [])
        // 다음 커서
        let nextCursor = BehaviorRelay<String?> (value: nil)
        // 네트워크 에러 발생시
        let networkError = PublishRelay<NetworkError> ()
        
        // 네트워크 요청시 반환 받는 모델 PostReadMainModel 통신은 됨
        input.viewDidAppearTrigger
            .take(1)
            .filter { $0 == true }
            .flatMap { _ in
                NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.postRead(next: nextCursor.value, limit: limit, productId: input.selectedProductID.value.identi)))
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let success):
                    print(success)
                    nextCursor.accept(success.nextCursor)
                    postsDatas.accept(success.data)
                case .failure(let failer):
                    networkError.accept(failer)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return .init(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            tableViewItems: postsDatas.asDriver()
        )
    }

}
