//
//  DonateListViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import UIKit
import RxSwift
import RxCocoa

final class DonateListViewController: RxHomeBaseViewController<DonateListView> {
    
    private
    let viewModel = DonateListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startTrigger = rx.viewWillAppear
            .map { _ in () }
        
        let input = DonateListViewModel.Input(
            startTrigger: startTrigger
        )
        
        let output = viewModel.transform(input)
        
        output.successModels
            .bind(to: homeView.tableView.rx.items(
                cellIdentifier: DonateListCell.reusableIdenti, cellType: DonateListCell.self
            )) {row, item, cell in
                cell.setModel(item)
            }
            .disposed(by: disPoseBag)
        
        output.emptySignal
            .drive(with: self) { owner, bool in
                owner.homeView.emaptyImageView
                    .isHidden = !bool
            }
            .disposed(by: disPoseBag)
        
        output.networkError
            .drive(with: self) { owner, error  in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
    }
    
    override func navigationSetting() {
        navigationItem.title = "결제 내역 조회"
    }
    
    override func designView() {
        homeView.tableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.homeView.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disPoseBag)
    }
}

