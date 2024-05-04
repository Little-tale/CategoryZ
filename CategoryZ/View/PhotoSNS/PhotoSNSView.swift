//
//  PhotoSNSView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import UIKit
import SnapKit
import Then

final class PhotoSNSView: RxBaseView {
    
    lazy var headerView = SNSHeaderWithCollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 74)
    )
    
    let tableView = UITableView(frame: .zero).then {
        $0.separatorStyle = .none
    }
   
    private let layerLine = CALayer().then {
        $0.borderColor = JHColor.darkGray.cgColor
        $0.borderWidth = 0.5
    }
    
    override func configureHierarchy() {
        addSubview(tableView)
        tableView.layer.addSublayer(layerLine)
    }
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(safeAreaLayoutGuide) // 슈퍼뷰로 해야 네비가 정상 작동됨...? 왜지
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 240
    }
    
    override func register() {
        tableView.register(SNSTableViewCell.self, forCellReuseIdentifier: SNSTableViewCell.reusableIdenti)
    }
    
}

