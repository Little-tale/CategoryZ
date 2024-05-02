//
//  DonateListView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import UIKit
import SnapKit
import Then

final class DonateListView: RxBaseView {
    
    let tableView = UITableView(frame: .zero).then { $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 100
    }
    
    
    let emaptyImageView = UIImageView(frame: .zero).then {
        $0.image = JHImage.emptyForPaymentsList
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(emaptyImageView)
    }
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        emaptyImageView.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
            make.width.equalTo(150)
            make.height.equalTo(180)
        }
    }
    
    override func register() {
        tableView.register(DonateListCell.self, forCellReuseIdentifier: DonateListCell.reusableIdenti)
    }
}
