//
//  ChattingViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChattingViewController: RxHomeBaseViewController<RxOnlyRotateTableView> {
    
    private
    let viewModel = ChattingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setModel(_ userID: String) {
        subscribe(userID)
    }
    
}

// SUBSCRIBE
extension ChattingViewController {
    private
    func subscribe(_ userID: String) {
        let userIDRelay = BehaviorRelay<String> (value: userID)
        
        let input = ChattingViewModel.Input(userIDRelay: userIDRelay)
        
        let output = viewModel.transform(input)
        
        networkError(error: output.networkError)
        
    }
    
    private
    func networkError(error: Driver<NetworkError>) {
        error
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
    }
}
