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
    var collectionViewLayoutTrigger = true
    
    private
    lazy var imageService = RxCameraImageService(presntationViewController: self, zipRate: 5)
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if collectionViewLayoutTrigger {
            homeView.imageCollectionView.setCollectionViewLayout(
                homeView.customLayout.comentImageLayout(),
                animated: true
            )
            collectionViewLayoutTrigger = false
        }
    }
}

// SUBSCRIBE
extension ChattingViewController {
    private
    func subscribe(_ userID: String) {
        
        let userIDRelay = BehaviorRelay<String> (value: userID)
        let insertImageData = BehaviorRelay<[Data]> (value: [])
        
        let imageModeCancelTap = PublishRelay<Void> ()
        
        let selectedImage = PublishRelay<Int> ()
        
        let input = ChattingViewModel
            .Input(
                userIDRelay: userIDRelay,
                inputText: homeView.commentTextView.textView.rx.text,
                sendButtonTap: homeView.commentTextView.regButton.rx.tap,
                insertImageData: insertImageData,
                imageModeCancelTap: imageModeCancelTap, selectedImage: selectedImage
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
                    cell.selectionStyle = .none
                    
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
        
        // 이미지 선택 로직 구성
        homeView.imageAddButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.imageService.showImageModeSelectAlert()
            }
            .disposed(by: disPoseBag)
        
        // 이미지 서비스의 결과 받기
        imageService.imageResult
            .bind(with: self) { owner, result in
                switch result {
                case .success(let datas):
                    print(datas)
                    insertImageData.accept(datas)
                case .failure(let error):
                    if case .noAuth = error {
                        owner.SettingAlert()
                    } else {
                        owner.showAlert(
                            title: "경고",
                            message: error.message
                        )
                    }
                }
            }
            .disposed(by: disPoseBag)
        
        output.outputIamgeDataDriver
            .skip(1)
            .drive(with: self) { owner, _ in
                owner.view.endEditing(true)
                owner.homeView.setImageMode()
            }
            .disposed(by: disPoseBag)
        
        output.outputIamgeDataDriver
            .skip(1)
            .drive(homeView.imageCollectionView.rx.items(
                cellIdentifier: SelectedImageCollectionViewCell.reusableIdenti,
                cellType: SelectedImageCollectionViewCell.self
            )) { row, item, cell in
                cell.settingImageMode(.scaleToFill)
                cell.setModel(model: item)
                cell.selectedButton.tag = row
                cell.selectButtonTap = { at in
                    selectedImage.accept(at)
                }
            }
            .disposed(by: disPoseBag)
            
        // 취소 버튼 눌렀을때
        homeView.cancelButton.rx.tap
            .bind(with: self) { owner, _ in
                imageModeCancelTap.accept(())
                owner.homeView.disSetImageMode()
            }
            .disposed(by: disPoseBag)
        
        // 이미지 최대 갯수
        output.maxCout
            .drive(imageService.rx.maxCount)
            .disposed(by: disPoseBag)
        
        homeView.imageCollectionView.rx.itemSelected
            .bind { item in
                selectedImage.accept(item.row)
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
