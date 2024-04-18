//
//  SNSTableViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/18/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SNSTableViewModel: RxViewModelType {
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let snsModel: PublishRelay<SNSDataModel>
    }
    
    struct Output {
        let imageURLString: Driver<[String]>
    }
    
    func transform(_ input: Input) -> Output {
        
        let imageUrl = BehaviorRelay<[String]> (value: [])
        
        input.snsModel
            .bind { model in
                model.content // 컨텐트
                model.files // 이미지 링크
                model.creator // 만든이 정보
                model.likes // 좋아요 한 사람들 나옴
                model.meID // 내 아이디 이거랑 비교해서 해결
                model.comments.first // 댓글도 해야하네...!
                // 첫번째 댓글만 보여주고 댓글 버튼누르면 댓글들 보이게
                model.createdAt // 날짜 나오는데 현재 날짜와 비교해 몇일전인지 몇시간 전인지 해보자
                
            }
            .disposed(by: disposeBag)
        return Output(
            imageURLString: <#T##Driver<String>#>
        )
    }
}
