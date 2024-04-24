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
    
    
    func setModel(_ postId: String, commentsModels: [CommentsModel]) {
        // 포스트 아이디가 필수적
        
    }
    
    private
    func subscribe(){
        // 텍스트 뷰 자동 사이즈 조절
        // 테스트용 포스트아이디 : 661eb55ce8473868acf68096
        let testPostId = "661eb55ce8473868acf68096"
        autoResizingTextView()
        
        // 텍스트 뷰의 텍스트
        let textViewText = textBox.textView.rx.text
        
        // 등록 버튼
        let regButtonTap = textBox.regButton.rx.tap
        
        let behPostId = BehaviorRelay(value: testPostId)
        
        let input = CommentViewModel.Input(
            textViewText: textViewText,
            regButtonTap: regButtonTap,
            postIdInput: behPostId
        )
        let output = viewModel.transform(input)
        
        // 허용된 텍스트 회고 ( return 이슈.... )
        output.validText
            .drive(textBox.textView.rx.value)
            .disposed(by: disPoseBag)

        // 허용된 버튼
        output.regButtonEnabled
            .drive(with: self) { owner, bool in
                owner.textBox.regButton.isEnabled = bool
                owner.textBox.regButton.tintColor = bool ? JHColor.gray : JHColor.likeColor
            }
            .disposed(by: disPoseBag)
        
        // 에러 발생시
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
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
