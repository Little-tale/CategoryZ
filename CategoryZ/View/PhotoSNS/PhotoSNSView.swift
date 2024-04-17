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
    
    lazy var headerView = SNSHeaderWithCollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 80)
    )
    
    let tableView = UITableView(frame: .zero)
   
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
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
    }
    /*
     회고 레이어 안보이는 이유
     -> 테이블뷰 헤더뷰 높이에 대한 고려 안함 이슈
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let borderWidth: CGFloat = 0.5

        layerLine.frame = CGRect(x: 0, y: 80, width: tableView.frame.width, height: borderWidth)
        
    }
    
    override func register() {
        tableView.register(SNSTableViewCell.self, forCellReuseIdentifier: SNSTableViewCell.identi)
    }
    
    override func designView() {
        
    }
}
