//
//  DonateListView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import UIKit
import SnapKit

final class DonateListView: RxBaseView {
    
    let tableView = UITableView(frame: .zero)
    
    override func configureHierarchy() {
        addSubview(tableView)
    }
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
