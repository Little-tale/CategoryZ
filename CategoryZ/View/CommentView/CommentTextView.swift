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
    let textBoxView = UIView().then {
        $0.backgroundColor = .blue
    }
    
    private
    var placeholedrText: String
    
    
    lazy var placholderTextLabel = UILabel().then {
        $0.text = placeholedrText
    }
    init(placeholedrText: String) {
        self.placeholedrText = placeholedrText
        super.init(frame: .zero)
    }
    
    var textViewHeightConstraint : Constraint?
    
    // 딜리게이트 충돌로 인한 뷰만 구성
    let textView = UITextView().then {
        $0.isScrollEnabled = false
        $0.font = JHFont.UIKit.re17
    }
    
    let regButton = UIButton().then {
        $0.tintColor = JHColor.likeColor
    }
    
    
    override func configureHierarchy() {
        addSubview(textBoxView)
        textBoxView.addSubview(textView)
        addSubview(placholderTextLabel)
        addSubview(regButton)
    }
    
    override func configureLayout() {
        textBoxView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        textView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalTo(textBoxView).inset(10)
            make.trailing.equalTo(textBoxView).inset(60)
            // * 회고
            textViewHeightConstraint = make.height
                .equalTo(40).priority(.high).constraint
        }
        placholderTextLabel.snp.makeConstraints { make in
            make.edges.equalTo(textView).inset(2)
            // make.
        }
        regButton.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.trailing.equalTo(textBoxView).inset(8)
            make.bottom.equalTo(textBoxView).inset(8)
        }
        regButton.imageView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func designView() {
        regButton.setImage(JHImage.sendImage, for: .normal)
        regButton.imageView?.contentMode = .scaleAspectFit
    }
}
