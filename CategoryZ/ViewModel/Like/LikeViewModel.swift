//
//  LikeViewModel.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LikeViewModel: RxViewModelType {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    private
    var next: String? = nil
    
    private
    let limit = "12"
    
    
    let realModel = BehaviorRelay<[SNSDataModel]> (value: [])
    
    private
    let ifModifyModel = PublishRelay<SNSDataModel> ()
    
    struct Input {
        let startTriggerSub: BehaviorRelay<Void>
        let currentCellItemAt: PublishRelay<Int>
    }
    
    struct Output {
        let networkError: Driver<NetworkError>
        let successData: BehaviorRelay<[SNSDataModel]>
        let successTrigger: PublishRelay<Void>
    }
    
    func transform(_ input: Input) -> Output {
        
        let networkError = PublishRelay<NetworkError> ()
        let publishVoid = PublishRelay<Void> ()
        let needMoreTrigger = PublishRelay<Void> ()
        
        var totalCount = 0
        
        input.startTriggerSub
            .withUnretained(self)
            .flatMapLatest {owner , _ in
                NetworkManager.fetchNetwork(
                    model: SNSMainModel.self,
                    router: .like(.findLikedPost(
                        next: owner.next,
                        limit: owner.limit
                    ))
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let model):
                    
                    print("** 서버에서 주는 ",model.nextCursor)
                    print("** 요청시점 토탈개수", owner.realModel.value.count)
                    owner.next = model.nextCursor
                    if owner.realModel.value.isEmpty {
                        owner.realModel.accept(model.data)
                    } else {
                        var value = owner.realModel.value
                        value.append(contentsOf: model.data)
                        owner.realModel.accept(value)
                    }
                    totalCount =  owner.realModel.value.count
                    publishVoid.accept(())
                case .failure(let error):
                    networkError.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        
        input.currentCellItemAt
            .withUnretained(self)
            .filter({owner, cellInfo in
                print("** 필터 되기전 현재셀정보 : \(cellInfo)")
                print("** 필터 되기전 넥스트\(owner.next ?? "nopppe")")
                print("** 필터 시점 토탈개수", owner.realModel.value.count)
                return owner.next != nil && owner.next != "0"
            })
            .filter({ _ in
                return totalCount != 0
            })
            .bind { currentAt in
                if (totalCount - 1) <= currentAt.1 {
                    input.startTriggerSub.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        ifModifyModel
            .filter({ _ in
                UserIDStorage.shared.userID != nil
            })
            .bind(with: self) { owner, model in
                let current = owner.realModel.value[model.currentRow]
                if current.likes != model.likes {
                    
                    var value = owner.realModel.value
                    value.remove(at: model.currentRow)
                    owner.realModel.accept(value)
                    
                }
                else if !current.likes.contains(UserIDStorage.shared.userID!) {
                    var value = owner.realModel.value
                    value.remove(at: model.currentRow)
                    owner.realModel.accept(value)
                }
                else if current.content != model.content || current.files != model.files {
                    var value = owner.realModel.value
                    value[model.currentRow] = model
                    owner.realModel.accept(value)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            networkError: networkError.asDriver(onErrorDriveWith: .never()),
            successData: realModel,
            successTrigger: publishVoid
        )
    }
    
}

extension LikeViewModel: changedModel {
    func ifChange(_ model: SNSDataModel) {
        ifModifyModel.accept(model)
    }
}
