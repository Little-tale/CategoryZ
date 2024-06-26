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
        $0.register(ChatOnlyImagesCell.self, forCellReuseIdentifier: ChatOnlyImagesCell.reusableIdenti)
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
    
    var cancelClosure: (() -> Void)?
    
    var deleteClosure: (() -> Void)?
    
    private
    lazy var cancelAction = UIAction( handler: {[weak self] _ in
        self?.cancelClosure?()
    }).then {
        $0.title = "취소하기"
        $0.image = JHImage.xMark
    }
    
    private
    lazy var deleteAction = UIAction( handler: {[weak self] _ in
        self?.deleteClosure?()
    }).then {
        $0.title = "지우기"
        $0.image = JHImage.trash
    }
    
    private
    lazy var cancelButton = UIButton().then {
        let resize = JHImage.xMark?.resizingImage(
            targetSize: CGSize(width: 26, height: 26)
        )
        let template = resize?.withRenderingMode(.alwaysTemplate)
        $0.setImage(template, for: .normal)
        $0.tintColor = JHColor.likeColor
        $0.isHidden = true
        $0.menu = UIMenu(title:"메뉴", children: [cancelAction,deleteAction])
        $0.showsMenuAsPrimaryAction = true
    }
    
    let imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.backgroundColor = JHColor.white
        $0.register(SelectedImageCollectionViewCell.self, forCellWithReuseIdentifier: SelectedImageCollectionViewCell.reusableIdenti)
        $0.isHidden = true
    }
    
    lazy var customLayout = CustomFlowLayout(collectionView: imageCollectionView)
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(imageAddButton)
        addSubview(cancelButton)
        addSubview(commentTextView)
        addSubview(imageCollectionView)
        subscribe()
    }
    
    override func configureLayout() {
        
        
        imageAddButton.snp.makeConstraints { make in
            make.centerY.equalTo(commentTextView.regButton)
            make.size.equalTo(30)
            make.leading.equalTo(safeAreaLayoutGuide).offset(6)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(commentTextView.regButton)
            make.size.equalTo(30)
            make.leading.equalTo(safeAreaLayoutGuide).offset(6)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(imageAddButton.snp.trailing)
            // 키보드가 있을 때 위치
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).priority(.high)
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
        commentTextView.textView.rx.text.orEmpty
            .bind(with: self) { owner, text in
                owner.commentTextView.placholderTextLabel.isHidden = text != ""
            }
            .disposed(by: disposedBag)
    }
}

/*
 // 키보드가 없을 때
 //make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).priority(.low)
 */
