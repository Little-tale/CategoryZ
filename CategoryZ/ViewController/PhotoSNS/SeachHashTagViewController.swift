//
//  SerchHashTagViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SeachHashTagViewController: RxHomeBaseViewController<RxCollectionView> {
    
    let viewModel = SearchHashTagViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func designView() {
        homeView.collectionView.setCollectionViewLayout(CustomProfileCollectionViewLayout.createSearchCollectionViewLayout(), animated: true)
        view.backgroundColor = .red
    }
    
    func getText(_ text: String) {
        subscribe(text)
    }
    
    private
    func subscribe(_ text: String) {
        let behaiviorText = BehaviorRelay(value: text)
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.disposeBag = .init()
    }
}
