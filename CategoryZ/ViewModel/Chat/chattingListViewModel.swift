//
//  chattingListViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/20/24.
//

import Foundation
import RxSwift
import RxCocoa

/*
 1. 렘 먼저 뷰에 반영 시켜 놓을것
 2. 렘 채팅 방과 통신과의 결과를 비교 할것.
 
 2.2 lastAt or New 발견시 해당하는 모델 각자 다 조회
 
 3. 만약 통신을 했을때 렘에 없는 모델일 경우 룸 ID,
    생성 날짜, 업데이트 날짜 렘 반영
 
 4. 뷰에 다시한번 반영
 */

final class ChattingListViewModel: RxViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let viewDidAppear: Observable<Void>
    }
    
    struct Output {
        let chatRoomModels: Driver<[ChatRoomRealmModel]>
    }
    
    func transform(_ input: Input) -> Output {
        
        let chatRoomModels = BehaviorRelay<[ChatRoomRealmModel]> (value: [])
        let realmSearviceError = PublishRelay<RealmServiceManagerError> ()
        
        RealmServiceManager.shared.observeForRoom { result in
            switch result {
            case .success(let success):
                chatRoomModels.accept(success)
            case .failure(let error):
                realmSearviceError.accept(error)
            }
        }
        
        
        return Output(
            chatRoomModels: chatRoomModels.asDriver()
        )
    }
}
