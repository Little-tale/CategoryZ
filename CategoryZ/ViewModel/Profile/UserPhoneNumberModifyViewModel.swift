//
//  UserPhoneNumberModifyViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class UserPhoneNumberModifyViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    let textValid = TextValid()
    
    struct Input {
        let inputPhoneNumber: ControlProperty<String?>
        let inputSaveButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let outputTextValid: Driver<textValidation>
        let networkError: Driver<NetworkError>
        let successTrigger: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        
        let publishNetError = PublishSubject<NetworkError> ()
        
        let publishSuccess = PublishSubject<Void> ()
        
        // 닉네임 검사 결과 Driver
        let nameValid = input.inputPhoneNumber.orEmpty
            .withUnretained(self)
            .map { owner, text in
                owner.textValid.phoneNumberValid(text)
            }
            .asDriver(onErrorJustReturn: .isEmpty)
        
        input.inputSaveButtonTap
            .withLatestFrom(input.inputPhoneNumber.orEmpty)
            .flatMapLatest { phonNum in
                let model = ProfileModifyIn(phoneNum: phonNum )
                return NetworkManager.profileModify(type: ProfileModel.self, router: .profileMeModify, model:model)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success:
                    publishSuccess.onNext(())
                case .failure(let fail):
                    publishNetError.onNext(fail)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            outputTextValid: nameValid,
            networkError: publishNetError.asDriver(onErrorDriveWith: .never()),
            successTrigger: publishSuccess.asDriver(onErrorDriveWith: .never())
        )
    }
    
}
