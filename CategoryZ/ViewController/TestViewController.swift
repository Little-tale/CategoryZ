//
//  TestViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/9/24.
//

import UIKit
import RxSwift
import RxCocoa


final class TestViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(test), name: .cantRefresh, object: nil)
        
//        let start = NetworkManager.fetchNetwork(
//            model: LoginModel.self, router: .authentication(.login(query: .init(email: "1234@test.com", password: "1234")))
//        )
//            .asObservable()
//            .share()
//        
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
//       start
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
        
        
        let test = NetworkManager.fetchNetwork(model: PostReadMainModel.self, router: .poster(.postRead(next: nil, limit: "10", productId: "CategoryZ_Test_Server")))
        
        test
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let success):
                    dump(success)
                case .failure(let fail):
                    print(fail)
                    print(fail.message)
                    print(fail.localizedDescription)
                    print(fail.errorCode)
                }
            }
            .disposed(by: disposeBag)
    }
    
    @objc
    func test(_ noti : Notification){
        print("리프레시 토큰 다이쓰키")
        if let errorCode = noti.object as? Int {
            print(errorCode)
        }
    }
    
}
