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
        
        let start = NetworkManager.fetchNetwork(
            model: JoinModel.self,
            router: .join(query: .init(email: "King2@skip.com", password: "12345", nick: "테스트입니다.", phoneNum: "010100000000", birthDay: "20010101"))
        )
        
        start
            .asObservable()
            .bind { result in
                guard case .success( let data ) = result else { return }
                print(data)
            }
            .disposed(by: disposeBag)
       start
            .asObservable()
            .bind { result in
                guard case .failure( let fail ) = result else { return }
                print( fail.message )
            }
            .disposed(by: disposeBag
            )
    
    }
    
    
}
