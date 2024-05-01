//
//  RegisterDonateViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import BetterSegmentedControl

/*
 자신의 프로필에선 등록을 하거나 삭제를 할수 있게 해야함. 그기능은 프로필 설정에서 후원 기능을 활성화 할 것인지 말건지에 대한 기능을 추가
 조건으론 해당 뷰컨 진입시 본인의 게시글(후원 프로덕트 아이디) 조회를 통해 1개 이상 또는 nil 일때. 를 기준으로 포스트
 */

final class RegisterDonateViewController: RxBaseViewController {
    
    private
    let titleText = UILabel().then {
        $0.text = "후원 기능 활성화 여부"
        $0.font = JHFont.UIKit.bo30
        $0.textAlignment = .left
    }
    
    private
    let subTitleText = UILabel().then {
        $0.text = "후원 기능을 활성화 하시면\n다른 사용자에게 후원을 받으실수 있습니다."
        $0.font = JHFont.UIKit.re14
        $0.numberOfLines = 2
        $0.textAlignment = .left
    }
    
    private
    let control = BetterSegmentedControl(frame: .zero).then {
        $0.segments = LabelSegment.segments(
            withTitles: ["후원 ON", "후원 OFF"],
            normalTextColor: JHColor.darkGray,
            selectedTextColor: JHColor.likeColor
        )
        $0.backgroundColor = JHColor.gray
    }
    
    private
    let publisheCurrentIndexAt = PublishRelay<Int> ()
    
    private
    let viewModel = RegisterDonateViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        control.addTarget(self, action: #selector(segmentedControl1ValueChanged), for: .valueChanged)
    }
    
    @objc func segmentedControl1ValueChanged(_ sender: BetterSegmentedControl) {
        print("The selected index -> \(sender.index)")
        publisheCurrentIndexAt.accept(sender.index)
    }
    
    func setModel(_ profile: ProfileModel) {
        subscribe(profile)
    }
    
    private
    func subscribe(_ model: ProfileModel){
        
        let viewWillTrigger = rx.viewWillAppear
            .map { _ in ()}
        let behaiviorModel = BehaviorRelay(value: model)
        
        let input = RegisterDonateViewModel.Input(
            viewWillTrigger: viewWillTrigger,
            behaiviorModel: behaiviorModel
        )
        
        let output = viewModel.transform(input)
        
        output.currentIndex
            .drive(with: self) { owner, bool in
                let current = bool ? 0 : 1
                owner.control.setIndex(current)
            }
            .disposed(by: disPoseBag)
        
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
    }
    
    override func configureHierarchy() {
        view.addSubview(titleText)
        view.addSubview(subTitleText)
        view.addSubview(control)
        
        
    }
    override func configureLayout() {
        titleText.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
        }
        subTitleText.snp.makeConstraints { make in
            make.top.equalTo(titleText.snp.bottom).offset(6)
            make.horizontalEdges.equalTo(titleText)
        }
        control.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.top.equalTo(subTitleText.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
    }
    
}
