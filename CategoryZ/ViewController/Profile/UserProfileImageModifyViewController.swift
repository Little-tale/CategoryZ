//
//  UserProfileImageModifyView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class UserProfileImageModifyViewController: RxBaseViewController {
    
    private
    lazy var imageService = RxCameraImageService(presntationViewController: self, zipRate: 5)
    
    private
    let titleText = UILabel().then {
        $0.text = "프로필 사진"
        $0.font = JHFont.UIKit.bo30
        $0.textAlignment = .left
    }

    let profileImageView = CircleImageView(frame: .zero).then {
        $0.tintColor = JHColor.black
        $0.contentMode = .scaleToFill
        $0.backgroundColor = JHColor.gray
    }
    
    let modifyButton = UIButton().then {
        $0.setTitle("수정하기", for: .normal)
        $0.backgroundColor = JHColor.black
        $0.tintColor = JHColor.white
        $0.setTitleColor(JHColor.white, for: .normal)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    let deleteButton = UIButton().then {
        $0.setTitle("삭제", for: .normal)
        $0.backgroundColor = JHColor.black
        $0.tintColor = JHColor.white
        $0.setTitleColor(JHColor.white, for: .normal)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.backgroundColor = JHColor.likeColor
        $0.tintColor = JHColor.white
        $0.setTitleColor(JHColor.onlyWhite, for: .normal)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    let viewModel = ProfileImageChangeViewModel()
    
    
    func setModel(_ model: ProfileModel) {
        
        let publishDataImage = PublishRelay<Data> ()
        let behaiverProfileModel = BehaviorRelay(value: model)
        
        if !model.profileImage.isEmpty {
            profileImageView.downloadImage(imageUrl:model.profileImage, resizing: .init(width: 200, height: 200))
        } else {
            profileImageView.image = JHImage.defaultImage
        }
        
        
        let input = ProfileImageChangeViewModel.Input(
            inputModel: behaiverProfileModel,
            inputData: publishDataImage,
            saveButtonTap: saveButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        output.outSuccessTrigger
            .drive(with: self) { owner, _ in
                owner.showAlert(title: "저장하였습니다.") { _ in
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disPoseBag)
        
        output.outNetworkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        
        imageService.maxCount = 1
        
        // 수정하기 버튼을 눌렀을때
        modifyButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.imageService.showImageModeSelectAlert()
            }
            .disposed(by: disPoseBag)
        // 삭제 버튼을 눌렀을때
        deleteButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.profileImageView.image = JHImage.defaultImage
                let data = JHImage.defaultImage.jpegData(compressionQuality: 1.0)
                if let data {
                    publishDataImage.accept(data)
                } else { // 후에 변경해야 해
                    owner.showAlert(title: "문제가 발생했어요") { _ in
                    }
                }
            }
            .disposed(by: disPoseBag)
        
        imageService.imageResult
            .bind(with: self) { owner, result in
                switch result {
                case .success(let datas):
                    if let image = datas.first {
                        owner.profileImageView.image = UIImage(data: image)
                        publishDataImage.accept(image)
                    }
                case .failure(let fail):
                    if case .noAuth = fail {
                        owner.SettingAlert()
                    } else {
                        owner.showAlert(title: "경고",message: fail.message) {
                            _ in
                        }
                    }

                }
            }
            .disposed(by: disPoseBag)
        
    }
    
    override func configureHierarchy() {
        view.addSubview(titleText)
        view.addSubview(profileImageView)
        view.addSubview(modifyButton)
        view.addSubview(deleteButton)
        view.addSubview(saveButton)
    }
    
    override func configureLayout() {
        titleText.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
        }
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(titleText.snp.bottom).offset(20)
            make.size.equalTo(200)
        }
        modifyButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(90)
            make.top.equalTo(profileImageView.snp.bottom).offset(24)
            make.height.equalTo(50)
        }
        deleteButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(modifyButton)
            make.top.equalTo(modifyButton.snp.bottom).offset(10)
            make.height.equalTo(modifyButton)
        }
        saveButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(modifyButton)
            make.top.equalTo(deleteButton.snp.bottom).offset(10)
            make.height.equalTo(modifyButton)
        }
    }
    
}



