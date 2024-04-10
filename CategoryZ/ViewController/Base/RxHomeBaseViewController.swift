//
//  RxHomeBaseViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import UIKit
import RxSwift


class RxHomeBaseViewController<T: RxBaseView>: RxBaseViewController {
    
    let homeView = T()
    

    
    override func loadView() {
        view = homeView
       
    }
    
    
}
