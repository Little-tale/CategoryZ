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
import Then

final class ChattingListViewController: RxBaseViewController {
    
    private
    let tableView = UITableView().then {
        $0.register(
            ChatRoomListCell.self,
            forCellReuseIdentifier: ChatRoomListCell.reusableIdenti
        )
        $0.rowHeight = 70
        $0.separatorStyle = .none
    }
    
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
        
        let output = viewModel.transform(input)
            
        output.chatRoomModels
            .drive(tableView.rx.items(
                cellIdentifier: ChatRoomListCell.reusableIdenti,
                cellType: ChatRoomListCell.self)
            ) { row, item, cell in
                
                cell.setModel(item)
                cell.selectionStyle = .none
            }
            .disposed(by: disPoseBag)
        
        tableView.rx.modelSelected(ChattingListModel.self)
            .bind(with: self) { owner, model in
                if let userId = model.userID {
                    let vc = ChattingViewController()
                    vc.setModel(userId, roomId: model.roomID)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disPoseBag)
    }
}

extension ChattingListViewController {
    
}
