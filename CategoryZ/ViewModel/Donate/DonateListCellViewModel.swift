//
//  DonateListCellViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DonateLisCelViewModel: RxViewModelType {
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let behModel: BehaviorRelay<PaymentData>
    }
    
    struct Output {
        let productName : Driver<String>
        let donateDate: Driver<String>
        let contents: Driver<String>
        
    }

    func transform(_ input: Input) -> Output {
        
     
        let productName = BehaviorRelay(value: "")
        let donateDate = BehaviorRelay(value: "")
        let contents = BehaviorRelay(value: "")
   
        input.behModel.bind(with: self) { owner, data in
            productName.accept(data.productName)
            donateDate.accept( DateManager.shared.differenceDateString(data.paidAt))
            contents.accept("\(data.price) 원")
        }
        .disposed(by: disposeBag)
        
        return Output(
            productName: productName.asDriver(),
            donateDate: donateDate.asDriver(),
            contents: contents.asDriver()
        )
    }
    
}
