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
        $0.separatorStyle = .none
    }
    
    let commentTextView = CommentTextView(placeholedrText: "메시지를 남기세요")
    
    let imageAddButton = UIButton().then {
        let resize = JHImage.plus?.resizingImage(
            targetSize: CGSize(width: 26, height: 26)
        )
        let template = resize?.withRenderingMode(.alwaysTemplate)
        $0.setImage(template, for: .normal)
        $0.tintColor = JHColor.likeColor
    }
    
    let cancelButton = UIButton().then {
        let resize = JHImage.xMark?.resizingImage(
            targetSize: CGSize(width: 26, height: 26)
        )
        let template = resize?.withRenderingMode(.alwaysTemplate)
        $0.setImage(template, for: .normal)
        $0.tintColor = JHColor.likeColor
        $0.isHidden = true
    }
    
    let imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.backgroundColor = JHColor.white
        $0.register(SelectedImageCollectionViewCell.self, forCellWithReuseIdentifier: SelectedImageCollectionViewCell.reusableIdenti)
        $0.isHidden = true
    }
    
    lazy var customLayout = CustomFlowLayout(collectionView: imageCollectionView)
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(commentTextView)
        addSubview(imageAddButton)
        addSubview(cancelButton)
        addSubview(imageCollectionView)
        subscribe()
    }
    
    override func configureLayout() {
        
        commentTextView.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.leading.equalTo(imageAddButton.snp.trailing)
            // 키보드가 있을 때 위치
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).priority(.high)
        }
        imageAddButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(commentTextView).inset(12)
            make.width.equalTo(imageAddButton.snp.height)
            make.leading.equalTo(safeAreaLayoutGuide).offset(6)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.edges.equalTo(imageAddButton)
        }
        
        imageCollectionView.snp.makeConstraints { make in
            make.height.equalTo(216)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.equalToSuperview()
            // 테이블뷰 아래 댓글뷰 상단에 맞춤
            make.bottom.equalTo(commentTextView.snp.top)
        }
    }
    
    func setImageMode() {
        commentTextView.textView.text = ""
        commentTextView.placholderTextLabel.isHidden = true
        commentTextView.textView.isEditable = false
        commentTextView.textView.isSelectable = false
        
        cancelButton.isHidden = false
        imageAddButton.isHidden = true
        imageCollectionView.isHidden = false
        
        commentTextView.snp.remakeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.leading.equalTo(imageAddButton.snp.trailing)
            
            make.bottom.equalTo(imageCollectionView.snp.top).priority(.high)
        }
        
    }
    func disSetImageMode() {
        imageCollectionView.isHidden = true
        commentTextView.placholderTextLabel.isHidden = false
        commentTextView.textView.isEditable = true
        commentTextView.textView.isSelectable = true
        cancelButton.isHidden = true
        imageAddButton.isHidden = false
        
        commentTextView.snp.remakeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.leading.equalTo(imageAddButton.snp.trailing)
            // 키보드가 있을 때 위치
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).priority(.high)
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

/*
 // 키보드가 없을 때
 //make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).priority(.low)
 */
