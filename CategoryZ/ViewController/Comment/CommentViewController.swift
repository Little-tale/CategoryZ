//
//  ChattingView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/24/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class CommentViewController: RxBaseViewController {
    
    let tableView = UITableView().then {
        $0.backgroundColor = .green
        $0.allowsSelection = true
        $0.separatorStyle = .none
        $0.bounces = true
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identi)
    }
    
    
    let viewModel = CommentViewModel()
    
    let textBox = CommentTextView(frame: .infinite)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
    }
    
    override func configureHierarchy() {
        view.addSubview(tableView)
        view.addSubview(textBox)
    }
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        textBox.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
    }
    
    private
    func subscribe(){
        // 텍스트 뷰 자동 사이즈 조절
        autoResizingTextView()
        
        // 텍스트 뷰의 텍스트
        let textViewText = textBox.textView.rx.text
        
        // 등록 버튼
        let regButtonTap = textBox.regButton.rx.tap
        
        let input = CommentViewModel.Input(
            textViewText: textViewText,
            regButtonTap: regButtonTap
        )
        let output = viewModel.transform(input)
        
        // 허용된 텍스트 회고 ( return 이 인식안됨,.... )
        // 그게 아니라 인식은 되는데 왜 안되는 거지?
        output.validText
            .drive(textBox.textView.rx.value)
            .disposed(by: disPoseBag)
        
        output.validText
            .drive(with: self) { owner, string in
                owner.textBox.textView.text = string
            }
            .disposed(by: disPoseBag)
        output.validText
            .drive(textBox.textView.rx.value)
            .disposed(by: disPoseBag)
    
            
        
        // 허용된 버튼
        output.regButtonEnabled
            .drive(textBox.regButton.rx.isEnabled)
            .disposed(by: disPoseBag)
        
        output.regButtonEnabled
            .drive(with: self) { owner, bool in
                owner.textBox.regButton.isEnabled = bool
                owner.textBox.regButton.tintColor = bool ? JHColor.gray : JHColor.likeColor
            }
            .disposed(by: disPoseBag)
    }
    
    
    
   
}

extension CommentViewController {
    
    private
    func autoResizingTextView() {
        textBox.textView.rx.text.orEmpty
            .observe(on: MainScheduler.instance) // *회고
            .bind(with: self) { owner, text in
                let size = CGSize(width: owner.textBox.textView.frame.width, height: CGFloat.infinity)
                let estimate = owner.textBox.textView.sizeThatFits(size)
                
                owner.textBox.textViewHeightConstraint?.update(offset: max(40,min(estimate.height, 120)))
            }
            .disposed(by: disPoseBag)
    }
    
}
