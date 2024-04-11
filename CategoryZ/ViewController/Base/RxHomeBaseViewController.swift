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

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        defaultNavigationSetting()
        navigationSetting()
    }
    
    override func loadView() {
        view = homeView
       
    }
    
    func subscribe() {
        
    }
    
    func loginNavigationSetting(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction(handler: {[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
    }
    
    private func defaultNavigationSetting(){
        navigationController?.navigationBar.tintColor = .black
    }
    func navigationSetting() {
        
    }

}
