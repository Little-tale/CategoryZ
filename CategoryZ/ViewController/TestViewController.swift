//
//  TestViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/9/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then


final class TestViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    // let textBox = CommentTextView(frame: .infinite)
    
    //let scrollImageView = ScrollImageView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        testLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(test), name: .cantRefresh, object: nil)
        
//        let start = NetworkManager.fetchNetwork(
//            model: LoginModel.self, router: .authentication(.login(query: .init(email: "1234@test.com", password: "1234")))
//        )
//            .asObservable()
//            .share()
        
        ////        let start = NetworkManager.fetchNetwork(model: JoinModel.self, router: .join(query: .init(email: "1234DE@test.com", password: "1234", nick: "1234", phoneNum: "1234", birthDay: nil)))
        ////            .asObservable()
        ////            .share()
        //
        //////
        ////        let start = NetworkManager.fetchNetwork(model: UserWithDraw.self, router: .userWithDraw)
        ////            .asObservable()
        ////            .share()
        //
        //        // 로그인 때는 스토리지에 등록해주고 진행
        //        // -> 제거 테스트 진행
//        start
//            .throttle(.microseconds(100), scheduler: MainScheduler.instance)
//            .bind { result in
//                guard case .success( let data ) = result else { return }
//                print("!!!!",data)
//                print("삭제됨")
//                TokenStorage.shared.accessToken = data.accessToken
//                TokenStorage.shared.refreshToken = data.refreshToken
//            }
//            .disposed(by: disposeBag)
//        // print(TokenStorage.shared.accessToken)
//        start
//            .bind { result in
//                guard case .failure( let fail ) = result else { return }
//                print(fail.message )
//                print(fail.errorCode)
//                
//            }
//            .disposed(by: disposeBag)
        
        
        //    // 이미지 테스트
        //        let imageData = UIImage(resource: .testImageSet).jpegData(compressionQuality: 1.0)!
        //
        //        let start = NetworkManager.uploadImages(model: imageDataModel.self, router: .imageUpload, images: [imageData])
        //
        //        let driver =  start
        //            .asDriver(onErrorDriveWith: .never())
        //
        //        driver
        //            .drive(with: self) { owner, result in
        //                switch result {
        //                case .success(let success):
        //                    print(success)
        //                case .failure(let fail):
        //                    print(fail.errorCode)
        //                }
        //            }
        //            .disposed(by: disposeBag)
        
        //        let model = MainPostQuery(title: "테스트", content: "제발 됬으면...")
        //
        //        let testModel = NetworkManager.fetchNetwork(model: PostModel.self, router: .poster(.postWrite(query: model)))
        //
        //        testModel
        //            .subscribe(with: self) { owner, results in
        //                switch results {
        //                case .success(let s):
        //                    print("model : ",s)
        //                case .failure(let f):
        //                    print(f.message)
        //                    print(f.localizedDescription)
        //                    print(f.errorCode)
        //                }
        //            }
        //            .disposed(by: disposeBag)
        
        
        //        let test = NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.postRead(next: nil, limit: "10", productId: "CategoryZ_Test_Server")))
        //
        //        test
        //            .subscribe(with: self) { owner, result in
        //                switch result {
        //                case .success(let success):
        //                    dump(success)
        //                case .failure(let fail):
        //                    print(fail)
        //                    print(fail.message)
        //                    print(fail.localizedDescription)
        //                    print(fail.errorCode)
        //                }
        //            }
        //            .disposed(by: disposeBag)
        //         "661a45e8438b876b25f735a7"
        
        //        let testModel =  MainPostQuery(title: "과연...", content: "바뀔까요..?", content2: "과아아연?", content3: "에엥에에에렝", product_id: "CategoryZ_Test_Server")
        //
        //        let test = NetworkManager.fetchNetwork(model: SNSDataModel.self, router: .poster(.postModify(query: testModel, postID: "661a45e8438b876b25f735a7")))
        //
        //        test
        //            .subscribe(with: self) { owner, result in
        //                switch result {
        //                case .success(let ss):
        //                    print(ss)
        //                case .failure(let fail ):
        //                    print(fail)
        //                    print(fail.message)
        //                    print(fail.localizedDescription)
        //                    print(fail.errorCode)
        //                }
        //            }
        //            .disposed(by: disposeBag    )
        
        
        //        NetworkManager.fetchNetwork(model: SNSDataModel.self, router: .poster(.selectPostRead(postID: "661a45e8438b876b25f735a7")))
        //            .subscribe(with: self) { owner, result in
        //                switch result {
        //                case .success(let ss):
        //                    print(ss)
        //                case .failure(let fail ):
        //                    print(fail)
        //                    print(fail.message)
        //                    print(fail.localizedDescription)
        //                    print(fail.errorCode)
        //                }
        //            }
        //            .disposed(by: disposeBag )
        
        //
        //        NetworkManager.noneModelRequest(router: .poster(.postDelete(postID: "661a45e8438b876b25f735a7")))
        //            .subscribe(with: self) { owner, result in
        //                switch result {
        //                case .success():
        //                    print("삭제 완료")
        //                case .failure(let fail):
        //                    print(fail)
        //                    print(fail.message)
        //                    print(fail.localizedDescription)
        //                    print(fail.errorCode)
        //                }
        //            }
        //            .disposed(by: disposeBag)
        
        //        NetworkManager.fetchNetwork(model: SNSMainModel.self, router: .poster(.userCasePostRead(userId: "661a2c74e8473868acf65a05", next: nil, limit: "10", productId: "")))
        //            .subscribe(with: self) { owner, result in
        //                switch result {
        //                case .success(let model):
        //                    dump(model)
        //                case .failure(let fail):
        //                    print(fail)
        //                    print(fail.message)
        //                    print(fail.errorCode)
        //                }
        //            }
        //            .disposed(by: disposeBag)
        
//        let comment = CommentWriteQuery(content: "댓글 수정합니다")
        
        //        NetworkManager.fetchNetwork(model: ComentsModel.self, router: .comments(.commentsWrite(query: comment, postId: "661a9b61e8473868acf65bff")))
        //            .subscribe(with: self) { owner, result in
        //                switch result {
        //                case .success(let success):
        //                    print(success)
        //                case .failure(let fail):
        //                    print(fail)
        //                }
        //            }
        //            .disposed(by: disposeBag)
        
        //        NetworkManager.fetchNetwork(model: ComentsModel.self, router: .comments(.commentModify(query: comment, postId: "661a9b61e8473868acf65bff", commentsId: "661b3b2d438b876b25f7382e")))
        //            .subscribe(with: self) { owner, result  in
        //                switch result {
        //                case .success(let success):
        //                    print(success)
        //                case .failure(let fail):
        //                    print(fail)
        //                }
        //            }
        //            .disposed(by: disposeBag)
        
        
        //        NetworkManager.noneModelRequest(router: .comments(.commentDelete(postId: "661a9b61e8473868acf65bff", commentsId: "661b3b2d438b876b25f7382e")))
        //            .subscribe(with: self) { owner, results in
        //                switch results {
        //                case .success():
        //                    print("댓글이 제거 되었습니다. ")
        //                case .failure(let fail):
        //                    print(fail)
        //                    print(fail.message)
        //                    print(fail.errorCode)
        //                }
        //            }
//        // MARK: 이거 아직 안됨 이유를 모르겠음
//        NetworkManager.fetchNetwork(model: LikeQueryModel.self, router: .like(.like(query: LikeQueryModel.init(like_status: true), postId: "661bdb46438b876b25f73db0")))
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let s):
//                    print(s)
//                case .failure(let e):
//                    
//                    print(e)
//                    print(e.message)
//                    print(NetworkError.commonError(status: e.errorCode))
//                }
//            }
//            .disposed(by: disposeBag)
//        
//        NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .like(.findLikedPost(next: nil, limit: "20")))
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let s):
//                    print(s)
//                case .failure(let e):
//                    
//                    print(e)
//                    print(e.message)
//                    print(NetworkError.commonError(status: e.errorCode))
//                }
//            }
//            .disposed(by: disposeBag)
        
//        NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.follow(userId: "661a2c74e8473868acf65a05")))
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let followModel):
//                    print(followModel)
//                case .failure(let fail):
//                    print(fail)
//                }
//            }
//            .disposed(by: disposeBag)
        
//        NetworkManager.fetchNetwork(model: FollowModel.self, router: .follow(.unFollow(userId: "661a2c74e8473868acf65a05")))
//            .subscribe(with: self) { owner , result in
//                switch result {
//                case .success(let model):
//                    print(model)
//                case .failure(let fail):
//                    print(fail)
//                    print(fail.message)
//                    print(fail.errorCode)
//                }
//            }
//            .disposed(by: disposeBag)
        
        // 프로필
//        NetworkManager.fetchNetwork(model: ProfileModel.self, router: .profile(.ProfileMeRead))
//            .subscribe(with: self) { owner, result  in
//                switch result {
//                case .success(let success):
//                    print(success)
//                case .failure(let fail):
//                    print(fail)
//                    print(fail.message)
//                    print(fail.errorCode)
//                }
//            }
//            .disposed(by: disposeBag)
        
//        var test = ProfileModifyIn()
//        
//        // test.profile = nil
////
////        
//        NetworkManager.profileModify(type: ProfileModel.self, router: .profileMeModify, model: test)
//            .subscribe(with: self) { onwer  , result in
//                switch result {
//                case .success(let model):
//                    print(model)
//                case .failure(let fail):
//                    print(fail.message)
//                    
//                }
//            }
//            .disposed(by: disposeBag)
        
//        testButton.rx.tap
//            .withUnretained(self)
//            .bind {owner ,_ in
//                owner.testButton.isSelected = !owner.testButton.isSelected
//            }
        
        
        // 공식문서 방
        guard let screen =  view.window?.windowScene?.screen else { return }
        let screenSize = screen.bounds
        
//        textBox.textView.rx.text.orEmpty
//            .withUnretained(self)
//            .map{ owner, string in
//                let size = CGSize(width: owner.textBox.textView.frame.width, height: CGFloat.infinity)
//                let estSize = owner.textBox.textView.sizeThatFits(size)
//                return estSize.height
//            }
//            .bind(with: self) { owner, height in
//                owner.textBox.textView.snp.updateConstraints { make in
//                    make
//                }
//            }
        
        
        let trigger = rx.viewWillAppear
            .skip(1)
            .map { $0 == true }
            
    }
    
    @objc
    func test(_ noti : Notification){
        print("리프레시 토큰 다이쓰키")
        if let errorCode = noti.object as? Int {
            print(errorCode)
        }
    }
    
    func testLayout(){
//        view.addSubview(testButton)
//        testButton.snp.makeConstraints { make in
//            make.size.equalTo(50)
//            make.center.equalToSuperview()
//        }
        
//        view.addSubview(scrollImageView)
//        scrollImageView.snp.makeConstraints { make in
//            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
//            make.height.equalTo(300)
//            make.center.equalTo(view.safeAreaLayoutGuide)
//        }
//        
//        let imageData:[UIImage] = [
//            UIImage(resource: .appLogo),
//            UIImage(resource: .appLogo),
//            UIImage(resource: .appLogo),
//            UIImage(resource: .fashion),
//            UIImage(resource: .appLogo)
//        ]
//        
//        scrollImageView.setModel(imageData)
    }
}
