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
import RxDataSources

final class CommentViewController: RxBaseViewController {
    
    
    typealias DataSource = RxTableViewSectionedReloadDataSource<CommentSection>
    
    
    let tableView = UITableView().then {
        $0.backgroundColor = .green
        $0.allowsSelection = true
        $0.separatorStyle = .none
        $0.bounces = true
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identi)
        $0.keyboardDismissMode = .onDragWithAccessory
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
    }
    
    
    let viewModel = CommentViewModel()
    
    let textBox = CommentTextView(frame: .infinite)
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
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
    
    
    func setModel(_ snsDataModel: SNSDataModel) {
        // 포스트 아이디가 필수적
        subscribe(snsDataModel)
        
    }
    
    private
    func subscribe(_ snsDataModel: SNSDataModel){
        // 텍스트 뷰 자동 사이즈 조절
        autoResizingTextView()
        
        // 포스트 아이디
        let testPostId = snsDataModel.postId
        
        // 텍스트 뷰의 텍스트
        let textViewText = textBox.textView.rx.text
        
        // 등록 버튼
        let regButtonTap = textBox.regButton.rx.tap
        // 포스트 아이디
        let behPostId = BehaviorRelay(value: testPostId)
        
        let behSnsDataModel = BehaviorRelay(value: snsDataModel)
        
        let input = CommentViewModel.Input(
            textViewText: textViewText,
            regButtonTap: regButtonTap,
            postIdInput: behPostId,
            inputModels: behSnsDataModel
        )
        let output = viewModel.transform(input)
        
        // 텍스트 뷰 관련 로직
        validTextView(
            output.validText,
            regButtonEnabled: output.regButtonEnabled
        )
        
        let dataSourceRx = DataSource { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identi) as? CommentTableViewCell else {
                print("셀 이닛 문제")
                return .init()
            }
            cell.backgroundColor = .red
            
            cell.setModel(item)
            return cell
        }
        
        output.outputModels
            .map({ models in
                return [CommentSection(items: models.comments)]
            })
            .drive(
                tableView.rx.items(
                    dataSource: dataSourceRx
                )
            )
            .disposed(by: disPoseBag)
        
        // 에러 발생시
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        // 이 방법 또는
        rx.viewDidDisapear
            .bind { _ in
                NotificationCenter.default.post(name: .commentDidDisAppear, object: nil)
            }
            .disposed(by: disPoseBag)
        
    }
}




// MARK: 텍스트뷰 로직
extension CommentViewController {
    private
    func validTextView(
        _ validText: Driver<String?>,
        regButtonEnabled: Driver<Bool>
    ){
        validText
            .drive(textBox.textView.rx.value)
            .disposed(by: disPoseBag)
        
        regButtonEnabled
            .drive(with: self) { owner, bool in
                owner.textBox.regButton.isEnabled = bool
                owner.textBox.regButton.tintColor = bool ? JHColor.gray : JHColor.likeColor
            }
            .disposed(by: disPoseBag)
    }
}
// MARK: 텍스트뷰 리사이징 뷰
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


struct CommentSection: SectionModelType {
   
    var items: [Item]
    
    typealias Item = CommentsModel
    
    init(items: [Item]) {
        self.items = items
    }
    
    init(original: CommentSection, items: [Item]) {
        self = original
        self.items = items
    }
    mutating
    func addModel(_ model: Item){
        items.append(model)
    }
}

