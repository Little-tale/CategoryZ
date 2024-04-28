//
//  SingleViewRx.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SingleViewRx: RxBaseView {
    let singleView = SingleSNSView()
    
    override func configureHierarchy() {
        addSubview(singleView)
    }
    override func configureLayout() {
        singleView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    

}
