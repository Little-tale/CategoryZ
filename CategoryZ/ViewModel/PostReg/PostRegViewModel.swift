//
//  PostRegViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import Foundation
import RxSwift
import RxCocoa

class PostRegViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    var imageDatas: [Data] = []
    
    struct Input {
        // 선택된 모델 ID
        let selectedProduct: BehaviorRelay<ProductID?>
        let insertImageData: BehaviorRelay<[Data]>
    }
    
    struct Output{
        let outputIamgeDataDriver: Driver<[Data]>
        let maxCout: Driver<Int>
    }
    
    func transform(_ input: Input) -> Output {
        
        let outputImageDatas = BehaviorRelay<[Data]> (value: imageDatas)
        let outputImageMaxCount = BehaviorRelay(value: 5)
        
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
        
        
        
        return Output(
            outputIamgeDataDriver: outputImageDatas.asDriver(),
            maxCout: outputImageMaxCount.asDriver()
        )
    }
    
}


