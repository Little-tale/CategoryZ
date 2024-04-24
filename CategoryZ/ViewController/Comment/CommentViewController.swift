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
    
    let tableView = UITableView()
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
        textBox.textView.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, text in
                let size = CGSize(width: owner.textBox.textView.frame.width, height: CGFloat.infinity)
                let estimate = owner.textBox.textView.sizeThatFits(size)
                
                owner.textBox.textViewHeightConstraint?.update(offset: max(40,min(estimate.height, 120)))
            }
            .disposed(by: disPoseBag)
    }
}
