//
//  UserPhoneNumberModifyViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class UserPhoneNumberModifyViewController: RxBaseViewController {
    
    private
    let titleText = UILabel().then {
        $0.text = "전화번호 변경"
        $0.font = JHFont.UIKit.bo30
        $0.textAlignment = .left
    }
    
    private
    let userPhoneNumberTextField = WhitePointTextField("전화번호 (선택)")
    
    private
    let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.backgroundColor = JHColor.gray
        $0.tintColor = JHColor.white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private
    let viewModel = UserPhoneNumberModifyViewModel()
    
    func setModel(_ model: ProfileModel) {
        
        userPhoneNumberTextField.text = model.phoneNum
        
        let input = UserPhoneNumberModifyViewModel.Input(
            inputPhoneNumber: userPhoneNumberTextField.rx.text,
            inputSaveButtonTap: saveButton.rx.tap
        )
        
        let output = viewModel.transform(input)
        
        output.outputTextValid
            .drive(with: self) { owner, textValid in
                owner.textFieldValidText(owner.userPhoneNumberTextField, textValid)
                owner.saveButton.isEnabled = textValid == .match || textValid == .isEmpty
                owner.saveButton.backgroundColor = (textValid == .match || textValid == .isEmpty) ? JHColor.likeColor : JHColor.gray
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
        view.addSubview(userPhoneNumberTextField)
        view.addSubview(saveButton)
    }
    
    override func configureLayout() {
        titleText.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
        }
        userPhoneNumberTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(25)
            make.top.equalTo(titleText.snp.bottom).offset(20)
            make.height.equalTo(60)
        }
        saveButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(userPhoneNumberTextField)
            make.top.equalTo(userPhoneNumberTextField.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
    }
    
}

extension UserPhoneNumberModifyViewController {
    
    private
    func textFieldValidText(_ textFiled: WhitePointTextField, _ valid: textValidation) {
       textFiled.borderActiveColor = .point
       switch valid {
       case .isEmpty:
           textFiled.placeholderColor = JHColor.black
           textFiled.borderActiveColor = JHColor.currect
           textFiled.setDefaultPlaceHolder()
           break
       case .minCount:
           textFiled.placeholderColor = .point
           textFiled.placeholder = "글자수(숫자만)가 부족해요!"
       case .match:
           textFiled.placeholder = ""
           textFiled.borderActiveColor = JHColor.currect
       case .noMatch:
           textFiled.placeholderColor = .point
           textFiled.placeholder = "숫자만 넣어주세요"
       }
   }
}
