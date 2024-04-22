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
    
    let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.backgroundColor = JHColor.likeColor
        $0.tintColor = JHColor.white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    
    
    func setModel(_ model: ProfileModel) {
        
    
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

