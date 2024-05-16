//
//  RxOnlyRotateTableView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/16/24.
//

import UIKit
import SnapKit
import Then

final class RxOnlyRotateTableView: RxBaseView {
    let tableView = UITableView().then {
        $0.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
}
