//
//  FlowAndFlowingView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/23/24.
//

import UIKit
import SnapKit
import Then


final class FollowerAndFollowingView: RxBaseView {
    
    let tableView = UITableView(frame: .zero)
    
    override func configureHierarchy() {
        addSubview(tableView)
    }
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    override func register() {
        tableView.register(FollowerAndFollwingTableViewCell.self, forCellReuseIdentifier: FollowerAndFollwingTableViewCell.identi)
    }
}
