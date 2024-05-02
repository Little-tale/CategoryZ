//
//  SearchHashTagVIewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchHashTagViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let behaiviorText: BehaviorRelay<String>
    }
    
    struct Output {
        
    }

    func transform(_ input: Input) -> Output {
        
    
        
        return .init()
    }
    
}
