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
        let textViewText: ControlProperty<String?>
        let regButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let validText: Driver<String?>
        let regButtonEnabled: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        // 테스트 검사 결과값
            // 텍스트
        let commentValidText = BehaviorRelay<String?>(value: nil)
            // 버튼상태
        let regButtonEnabled = BehaviorRelay(value: false)
        
        // 테스트 검사 결과값
        input.textViewText
            .distinctUntilChanged()
            .compactMap{ $0 }
            .withUnretained(self)
            .bind { owner, text in
                let bool = owner.textValid.commentValid(text, maxCount: 30)
                regButtonEnabled.accept(bool)
                if bool {
                    commentValidText.accept(text)
                } else if text == "" {
                    commentValidText.accept(text)
                } else {
                    commentValidText.accept(commentValidText.value)
                }
                print(bool)
            }
            .disposed(by: disposeBag)
    
        return Output(
            validText: commentValidText.asDriver(),
            regButtonEnabled: regButtonEnabled.asDriver()
        )
    }
    
    
}

/*
 unowned는 self가 nil이 될 가능성이 존재
 
 weak
 weak는 옵셔널 타입입니다. 그래서 nil이 될 수 있으며 만약 참조하고 있는 인스턴스가 메모리에서 해제될 시, ARC가 nil로 참조값을 대체합니다. 따라서 참조하고 있는 객체가 생명주기가 짧은 경우(weak를 선언한 scope의 객체보다) 사용합니다. (수명이 더 긴 쪽에서 선언)
 unowned
 unowned는 weak와 달리 참조하고 있는 인스턴스가 메모리에서 해제될 시, nil이 되지 않습니다. 만약 참조하고 있는 객체가 매모리에서 해제된 후 접근할 시, crash가 날 수 있습니다. 따라서 참조하고 있는 객체의 생명주기가 현재 scope의 객체보다 생명주기가 더 길거나 같을 경우 사용합니다. (수명이 더 짧은쪽에서 선언)
 */
