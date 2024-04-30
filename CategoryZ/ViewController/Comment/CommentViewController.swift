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
import Toast

final class CommentViewController: RxBaseViewController {
    
    typealias DataSource = RxTableViewSectionedReloadDataSource<CommentSection>
    
    private
    let tableView = UITableView().then {
        $0.allowsSelection = true
        $0.separatorStyle = .singleLine
        $0.bounces = true
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identi)
        $0.keyboardDismissMode = .onDragWithAccessory
    }
    
    private
    let viewModel = CommentViewModel()
    
    private
    let textBox = CommentTextView(placeholedrText: "댓글을 입력해 보세요")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    override func configureHierarchy() {
        view.addSubview(tableView)
        view.addSubview(textBox)
    }
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(textBox.snp.top)
        }
        
        textBox.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.greaterThanOrEqualTo(view.keyboardLayoutGuide.snp.top)
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
        
        // SNS모델
        let behSnsDataModel = BehaviorRelay(value: snsDataModel)
        
        // 본인 아이디
        let meId = UserIDStorage.shared.userID
        
        guard let myId = meId else {
            errorCatch(.loginError(statusCode: 419, description: "유저 아이디가 조회되질 않아요!"))
            return
        }
        
        // 지워질 모델 indexPath + 삭제 트리거
        let publishIndexPathForDelete = PublishRelay<IndexPath> ()
        let publishCurrectDeleteTrigger = PublishRelay<Void> ()
        
        let input = CommentViewModel.Input(
            textViewText: textViewText,
            regButtonTap: regButtonTap,
            postIdInput: behPostId,
            inputModels: behSnsDataModel,
            deleteIndex: publishIndexPathForDelete,
            deleteTrigger: publishCurrectDeleteTrigger
        )
        
        let output = viewModel.transform(input)
        
        // 텍스트 뷰 관련 로직
        validTextView(
            output.validText,
            regButtonEnabled: output.regButtonEnabled
        )
        // 테이블뷰 관련 로직
        tableViewBind(
            output.outputModels,
            publishIndexPathForDelete,
            publishCurrectDeleteTrigger,
            myId
        )
        
        // 에러 발생시
        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        // 레그버튼 클릭시 키보드와 글자 제거
        regButtonTap
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
                owner.textBox.textView.text = ""
            }
            .disposed(by: disPoseBag)
        
        
        rx.viewWillDisapear
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
            }
            .disposed(by: disPoseBag)
    }
    

    override func navigationSetting(){
        navigationItem.title = "댓글"
    }
}

// MARK: 테이블뷰 바인드
extension CommentViewController {
    
    private
    func tableViewBind(
        _ outputModels: BehaviorRelay<SNSDataModel>,
        _ publishIndexPathForDelete: PublishRelay<IndexPath>,
        _ publishCurrectDeleteTrigger: PublishRelay<Void>,
        _ meID : String
    ) {
        
        let dataSourceRx = DataSource { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identi) as? CommentTableViewCell else {
                print("셀 이닛 문제")
                return .init()
            }
            cell.selectionStyle = .none 
            cell.setModel(item)
            return cell
        }
        
        dataSourceRx.canEditRowAtIndexPath = {_, _ in true}
        
        
        outputModels
            .map({ models in
                return [CommentSection(items: models.comments)]
            })
            .bind(to:
                tableView.rx.items(
                    dataSource: dataSourceRx
                )
            )
            .disposed(by: disPoseBag)
        
        tableView.rx.itemDeleted
            .bind(with: self){ owner, indexPath in
                
                if meID == outputModels.value.comments[indexPath.row].creator.userID  {
                    owner.showAlert(
                        title: "정말 삭제하시겠어요?",
                        actionTitle: "삭제") { _ in
                            publishIndexPathForDelete.accept(indexPath)
                            publishCurrectDeleteTrigger.accept(())
                        }
                } else {
                    owner.view.makeToast("본인글만 지우실수 있어요!", duration: 3.0, position: .top)
                }
            }
            .disposed(by: disPoseBag)
        //MARK: 해당 부분에서 프로필 이미지 클릭시 다음 화면으로 이동해야하지만
        // 그것이 무한히 되면서 문제가 발생하고 있어 일단은 정지
//        NotificationCenter.default
//            .rx
//            .notification(.moveToProfileForComment, object: nil)
//            .bind(with: self) { owner, noti in
//                guard let profileType =  noti.userInfo? ["ProfileType"] as? ProfileType else {
//                    print("ProfileType Fail b")
//                    return
//                }
//                print("Fail? ")
//                let vc = UserProfileViewController()
//                vc.profileType = profileType
//                owner.navigationController?.pushViewController(vc, animated: true)
//            }
//            .disposed(by: disPoseBag)
        
        NotificationCenter.default
            .rx
            .notification(.moveToProfileForComment, object: nil)
            .bind(with: self) { owner, noti in
                owner.dismiss(animated: true)
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
                owner.textBox.regButton.tintColor = bool ? JHColor.likeColor : JHColor.darkGray
            }
            .disposed(by: disPoseBag)
        
        textBox.textView.rx.didBeginEditing
            .bind(with:self) {owner, _ in
                
                owner.textBox.placholderTextLabel.isHidden = true
            }
            .disposed(by: disPoseBag)
        
        textBox.textView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                owner.textBox.placholderTextLabel.isHidden = !owner.textBox.textView.text.isEmpty
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

