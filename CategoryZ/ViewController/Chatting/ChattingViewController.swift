//
//  ChattingViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import UIKit
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
    
    deinit {
        print("deinit: ChattingViewController")
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
        
        rx.viewDidDisapear
            .bind { _ in
                ChatSocketManager.shared.stopSocket()
            }
            .disposed(by: disPoseBag)
        
        
        networkError(error: output.publishNetError)
        dateError(error: output.dateError)
        realmError(error: output.realmError)
        socketError(error: output.socketError)
        
        
        output.tableViewDraw
            .distinctUntilChanged()
            .drive(homeView.tableView.rx.items) { tableView, index, item -> UITableViewCell in
                let images = Array(item.imageFiles)
                dump(images)
                if images.isEmpty {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatLeftRightCell.reusableIdenti, for: IndexPath(row: index, section: 0)) as? ChatLeftRightCell else {
                        print("ChatLeftRightCell Error")
                        return .init()
                    }
                    cell.setModel(model: item)
                    cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
                    return cell
                } else {
                    
                }
                print("이리로 오지말아요...")
                return .init()
            }
            .disposed(by: disPoseBag)
        
        output.currentTextState
            .drive(with: self) { owner, text in
                owner.homeView.commentTextView.textView.text = text
            }
            .disposed(by: disPoseBag)
        
        output.buttonState
            .drive(with: self) { owner, bool in
                owner.homeView.commentTextView.regButton.isEnabled = bool
                owner.homeView.commentTextView.regButton.tintColor = bool ? JHColor.likeColor : JHColor.darkGray
            }
            .disposed(by: disPoseBag)
        
        homeView.commentTextView.regButton.rx
            .tap
            .bind(with: self) { owner, _ in
                owner.homeView.commentTextView.textView.text = ""
            }
            .disposed(by: disPoseBag)
        
        output.realmServiceError
            .drive(with: self) { owner, error in
                owner.showAlert(error: error)
            }
            .disposed(by: disPoseBag)
        output.userProfile
            .drive(with: self) { owner, model in
                owner.navigationItem.title = model.nick + "와 채팅"
            }
            .disposed(by: disPoseBag)
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
    func tableViewDraw(models: Driver<[ChatBoxRealmModel]>) {
        models
            .drive(with: self) { owner, models in
                print(models)
            }
            .disposed(by: disPoseBag)
    }
}
