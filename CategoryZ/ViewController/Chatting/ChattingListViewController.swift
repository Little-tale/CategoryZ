//
//  ChattingListViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChattingListViewController: RxBaseViewController {
    
    private
    let tableView = UITableView()
    
    private
    let viewModel = ChattingListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        view.addSubview(tableView)
    }
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func navigationSetting() {
        let title = UILabel()
        title.text = "채팅"
        title.font = JHFont.UIKit.bo24
        title.textColor = JHColor.black
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: title)
    }
    
    override func subscriver() {
        
        let viewDidApear = rx.viewDidAppear
            .map { $0 == true }
            .map { _ in return () }
        
        let input = ChattingListViewModel.Input(
            viewDidAppear: viewDidApear
        )
        
    }
}

extension ChattingListViewController {
    
}
