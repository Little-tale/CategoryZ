//
//  ProfileNameModifyViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileNameModifyViewModel: RxViewModelType {
    
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    let textValid = TextValid()
    
    struct Input {
        let inputName: ControlProperty<String?>
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
        let nameValid = input.inputName.orEmpty
            .withUnretained(self)
            .map { owner, text in
                owner.textValid.nickNameVaild(text)
            }
            .asDriver(onErrorJustReturn: .isEmpty)
        
        input.inputSaveButtonTap
            .withLatestFrom(input.inputName.orEmpty)
            .flatMapLatest { name in
                let model = ProfileModifyIn(nick: name)
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
