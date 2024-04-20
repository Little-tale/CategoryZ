//
//  OtherUserProfileViewControlelr.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/20/24.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit


final class OtherUserProfileViewControlelr: RxBaseViewController {
    let profileView = ProfileView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configureHierarchy() {
        view.addSubview(profileView)
    }
    override func configureLayout() {
        profileView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
