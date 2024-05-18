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
        
        let input = ChattingViewModel
            .Input(
                userIDRelay: userIDRelay,
                inputText: homeView.commentTextView.textView.rx.text,
                sendButtonTap: homeView.commentTextView.regButton.rx.tap
            )
        
        let output = viewModel.transform(input)
        
        // ERROR
        networkError(error: output.networkError)
        realmError(error: output.realmError)
        dateError(error: output.dateError)
        socketError(error: output.socketError)
        
        // UI 
        buttonState(state: output.saveButtonState)
        tableViewDraw(models: output.outputTableData)
    }
}

extension ChattingViewController {
    private
    func networkError(error: Driver<NetworkError>) {
        error
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
    }
    
    private
    func dateError(error: Driver<DateManagerError>) {
        error
            .drive(with: self) { owner, error in
                owner.showAlert(error: error)
            }
            .disposed(by: disPoseBag)
    }
    
    private
    func realmError(error: Driver<RealmError>) {
        error
            .drive(with: self) { owner, error in
                owner.showAlert(error: error)
            }
            .disposed(by: disPoseBag)
    }
    
    private
    func socketError(error: Driver<ChatSocketManagerError>) {
        error
            .drive(with: self) { owner, error in
                owner.showAlert(error: error)
            }
            .disposed(by: disPoseBag)
    }
}

// MARK: UI
extension ChattingViewController {
    
    private
    func buttonState(state: BehaviorRelay<Bool>) {
        state
            .bind(with: self) { owner, bool in
                owner.homeView.commentTextView.regButton.isEnabled = bool
                owner.homeView.commentTextView.regButton.tintColor = bool ? JHColor.likeColor : JHColor.darkGray
            }
            .disposed(by: disPoseBag)
    }
    
    private
    func tableViewDraw(models: Driver<[ChatBoxModel]>) {
        models
            .drive(with: self) { owner, models in
                print(models)
            }
            .disposed(by: disPoseBag)
    }
}
