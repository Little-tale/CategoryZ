//
//  RxOnlyRotateTableView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class RxOnlyRotateTableView: RxBaseView {
    let tableView = UITableView().then {
        $0.transform = CGAffineTransform(scaleX: 1, y: -1)
        $0.register(ChatLeftRightCell.self, forCellReuseIdentifier: ChatLeftRightCell.reusableIdenti)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 100
    }
    
    let commentTextView = CommentTextView(placeholedrText: "메시지를 남기세요")
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(commentTextView)
        subscribe()
    }
    
    override func configureLayout() {
        
        commentTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            // 키보드가 있을 때 위치
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).priority(.high)
        }
        
        /*
         // 키보드가 없을 때
         //make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).priority(.low)
         */
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.equalToSuperview()
            // 테이블뷰 아래 댓글뷰 상단에 맞춤
            make.bottom.equalTo(commentTextView.snp.top)
        }
    }
    
    private
    func subscribe() {
        autoResizingTextView()
        
        commentTextView.textView.rx.text.orEmpty
            .bind(with: self) { owner, text in
                owner.commentTextView.placholderTextLabel.isHidden = text != ""
            }
            .disposed(by: disposedBag)
    }
}


extension RxOnlyRotateTableView {
    private
    func autoResizingTextView() {
        commentTextView.textView.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, text in
                let size = CGSize(width: owner.commentTextView.textView.frame.width, height: CGFloat.infinity)
                let estimate = owner.commentTextView.textView.sizeThatFits(size)

                owner.commentTextView.textViewHeightConstraint?.update(offset: max(40,min(estimate.height, 200)))
            }
            .disposed(by: disposedBag)
    }
}
