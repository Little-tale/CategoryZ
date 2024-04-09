//
//  ViewModelType.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import RxSwift

protocol ViewModelType {
    
    associatedtype Input
    
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}


protocol RxViewModelType: ViewModelType {
    
    var disposeBag: DisposeBag { get set }
}
