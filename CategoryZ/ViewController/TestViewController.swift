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
            model: LoginModel.self,
            router: .login(
                query: .init(
                    email: "King@skip.com",
                    password: "1234"
                )
            )
        )
       
    
    }
    
    
}
