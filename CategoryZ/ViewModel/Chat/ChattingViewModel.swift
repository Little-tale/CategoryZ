//
//  ChattingViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import Foundation
import RxSwift
import RxCocoa
/*
 룸 아이디를 받았으면
 렘에 대해서 조회를 먼저 진행 없다면
 채팅이 정상적으로 이루어졌을때 렘테이블에 생성
 렘 테이블에 반영
 */

final class ChattingViewModel: RxViewModelType {
    
    var disposeBag = DisposeBag()
    
    private
    let repository = RealmRepository()
    
    private
    let textValid = TextValid()
    
    private
    let myID = UserIDStorage.shared.userID
    
    // ERROR
    private
    let realmError = PublishRelay<RealmError> ()
    
    private
    let publishNetError = PublishRelay<NetworkError> ()
    
    private
    let dateError = PublishRelay<DateManagerError> ()
    
    private
    let realmServiceError = PublishRelay<RealmServiceManagerError> ()
    
    private // SocketStartTrigger
    let socketStartTrigger = PublishRelay<Void> ()
    
    struct Input {
        let userIDRelay: BehaviorRelay<String>
        let inputText: ControlProperty<String?>
        let sendButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        
      
        return .init()
    }
}
