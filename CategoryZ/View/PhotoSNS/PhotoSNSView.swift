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
    
    private
    let emptyView = UIView().then {
        $0.backgroundColor = JHColor.white
    }
    
    let tableView = UITableView(frame: .zero).then {
        $0.separatorStyle = .none
    }
   
    private let layerLine = CALayer().then {
        $0.borderColor = JHColor.darkGray.cgColor
        $0.borderWidth = 0.5
    }
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(emptyView)
        tableView.layer.addSublayer(layerLine)
    }
    override func configureLayout() {
        emptyView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
        }
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
            make.top.equalToSuperview()
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 240
    }
    
    override func register() {
        tableView.register(SNSTableViewCell.self, forCellReuseIdentifier: SNSTableViewCell.reusableIdenti)
    }
    
}

