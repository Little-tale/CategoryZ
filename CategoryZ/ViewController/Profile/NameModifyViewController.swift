//
//  NameModifyViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

final class NameModifyViewController: RxBaseViewController {
    
    private
    let titleText = UILabel().then {
        $0.text = "프로필 이름"
        $0.font = JHFont.UIKit.bo30
        $0.textAlignment = .left
    }
    
    private
    let nameTextFiled = WhitePointTextField("이름 (필수)")
    
    private
    let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.backgroundColor = JHColor.gray
        $0.tintColor = JHColor.white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private
    let viewModel = ProfileNameModifyViewModel()
    
    func setModel(_ model: ProfileModel) {
        
        nameTextFiled.text = model.nick
        
        let input = ProfileNameModifyViewModel.Input(
            inputName: nameTextFiled.rx.text,
            inputSaveButtonTap: saveButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        output.outputTextValid
            .drive(with: self) { owner, textValid in
                owner.textFieldValidText(owner.nameTextFiled, textValid)
                owner.saveButton.isEnabled = textValid == .match
                owner.saveButton.backgroundColor = textValid == .match ? JHColor.likeColor : JHColor.gray
                
            }
            .disposed(by: disPoseBag)
        
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        output.successTrigger
            .drive(with: self) { owner, _ in
                owner.showAlert(title: "변경되었습니다.") { _ in
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disPoseBag)
        
        
        
    }
    
    override func configureHierarchy() {
        view.addSubview(titleText)
        view.addSubview(nameTextFiled)
        view.addSubview(saveButton)
    }
    
    override func configureLayout() {
        titleText.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
        }
        nameTextFiled.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(25)
            make.top.equalTo(titleText.snp.bottom).offset(20)
            make.height.equalTo(60)
        }
        saveButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(nameTextFiled)
            make.top.equalTo(nameTextFiled.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
    }
    
}


extension NameModifyViewController {
    
    private
    func textFieldValidText(_ textFiled: WhitePointTextField, _ valid: textValidation) {
       textFiled.borderActiveColor = .point
       switch valid {
       case .isEmpty:
           textFiled.placeholderColor = .systemGray
           textFiled.setDefaultPlaceHolder()
           break
       case .minCount:
           textFiled.placeholderColor = .point
           textFiled.placeholder = "글자수가 부족해요!"
       case .match:
           textFiled.placeholder = ""
           textFiled.borderActiveColor = JHColor.currect
       case .noMatch:
           textFiled.placeholderColor = .point
           textFiled.placeholder = "양식에 맞지 않아요!"
       }
   }
}
