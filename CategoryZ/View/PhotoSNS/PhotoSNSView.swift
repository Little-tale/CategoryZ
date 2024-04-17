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
