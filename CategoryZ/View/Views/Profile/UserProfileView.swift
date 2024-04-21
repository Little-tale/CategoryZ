//
//  OtherUserProfileViewControlelr.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/20/24.
//

import UIKit
import Then
import SnapKit


final class UserProfileView: RxBaseView {
    let scrollView = UIScrollView(frame: .zero)
    
    let profileView = ProfileView()
    let tableView = UITableView(frame: .zero)
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(profileView)
        scrollView.addSubview(tableView)
        scrollView.backgroundColor = .blue
        profileView.backgroundColor = .pointGreen
        tableView.backgroundColor = .like
    }
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(250)
        }
       
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.horizontalEdges.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)  
        }
    }
}
