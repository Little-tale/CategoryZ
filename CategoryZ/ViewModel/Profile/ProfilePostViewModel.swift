//
//  ProfilePostViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfilePostViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let inputProfileType: BehaviorRelay<ProfileType>
        
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        
        return .init()
    }
}
