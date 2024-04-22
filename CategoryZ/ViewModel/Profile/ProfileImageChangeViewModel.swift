//
//  ProfileImageChangeViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/22/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileImageChangeViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    
    struct Input {
        let inputModel: BehaviorRelay<ProfileModel>
        let inputData: PublishRelay<Data>
        let saveButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let outSuccessTrigger: Driver<Void>
        let outNetworkError: Driver<NetworkError>
    }
    
    func transform(_ input: Input) -> Output {
        
        let success = PublishRelay<Void> ()
        let networkError = PublishRelay<NetworkError> ()
        
        let combinedDatas = Observable.combineLatest(input.inputModel, input.inputData)
        
        input.saveButtonTap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .withLatestFrom(combinedDatas)
            .flatMapLatest { combined in
                print("Model: \(combined.1)")
                let model = ProfileModifyIn(profile: combined.1)
                return NetworkManager.profileModify(type: ProfileModifyIn.self, router: .profileMeModify, model:model)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let sucs):
                    print("\(sucs)")
                    success.accept(())
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
    
        return Output(
            outSuccessTrigger: success.asDriver(onErrorDriveWith: .never()),
            outNetworkError: networkError.asDriver(onErrorDriveWith: .never())
        )
    }
    
}
