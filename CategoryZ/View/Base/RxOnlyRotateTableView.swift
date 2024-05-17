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
    }
    let commentTextView = CommentTextView(placeholedrText: "메시지를 남기세요")
    
    
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(commentTextView)
        subscribe()
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalTo(commentTextView.snp.top)
        }
        commentTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.greaterThanOrEqualTo(keyboardLayoutGuide.snp.bottom)
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
