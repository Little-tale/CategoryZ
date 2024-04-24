//
//  CommentViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/25/24.
//

import Foundation
import RxSwift
import RxCocoa

/*
 댓글 다는거 부터 테스트를 진행합시다.
 글자수 제한에 다음줄 금지 줘야 하구요
 아무것도 입력하지 않았을때 false
 */

final class CommentViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    let textValid = TextValid()
    
    struct Input {
        let textViewText: ControlProperty<String>
        let regButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let validText: Driver<String>
        let regButtonEnabled: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        // 테스트 검사 결과값
            // 텍스트
        let validText = BehaviorRelay(value: "")
        
        
        
        // 테스트 검사 결과값
        input.textViewText
            .scan(into: "") {[weak self] before, new in
                before = ((self?.textValid.commentValid(new, maxCount: 30)) != nil) ? new : before
            }
            .distinctUntilChanged()
            .bind(to: validText)
            .disposed(by: disposeBag)
        
        
        
        return Output(
            validText: validText.asDriver(),
            regButtonEnabled: <#T##Driver<Bool>#>
        )
    }
    
    
}

/*
 unowned는 self가 nil이 될 가능성이 존재
 */
