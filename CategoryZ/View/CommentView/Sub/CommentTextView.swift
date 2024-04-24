//
//  CommentTextView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/24/24.
//

import UIKit
import SnapKit
import Then

final class CommentTextView: BaseView {
    
    private
    let textBoxView = UIView()
    
    // 딜리게이트 충돌로 인한 뷰만 구성
    let textView = UITextView()
    
    let regButton = UIButton().then {
        $0.setImage(JHImage.sendImage, for: .normal)
        $0.tintColor = JHColor.likeColor
    }
    
    
    override func configureHierarchy() {
        addSubview(textBoxView)
        textBoxView.addSubview(textView)
        addSubview(regButton)
    }
    
    override func configureLayout() {
        textBoxView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        textView.snp.makeConstraints { make in
            make.edges.equalTo(textBoxView).inset(10)
        }
        regButton.snp.makeConstraints { make in
            make.trailing.equalTo(textBoxView)
            make.verticalEdges.equalTo(textView)
            make.width.equalTo(textView.snp.height)
        }
    }
}
