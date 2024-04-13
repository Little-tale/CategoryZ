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
//                // TokenStorage.shared.accessToken = data.accessToken
//                // TokenStorage.shared.refreshToken = data.refreshToken
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
    
        let imageData = UIImage(resource: .testImageSet).jpegData(compressionQuality: 1.0)!
        
        let start = NetworkManager.uploadImages(model: imageDataModel.self, router: .imageUpload, images: [imageData])
        
        let driver =  start
            .asDriver(onErrorDriveWith: .never())
        
        driver
            .drive(with: self) { owner, result in
                switch result {
                case .success(let success):
                    print(success)
                case .failure(let fail):
                    print(fail.errorCode)
                }
            }
            .disposed(by: disposeBag)

    }
    
    struct imageDataModel: Decodable {
        let files: [String]
    }
    
    @objc
    func test(_ noti : Notification){
        print("리프레시 토큰 다이쓰키")
        if let errorCode = noti.object as? Int {
            print(errorCode)
        }
    }
    
}
