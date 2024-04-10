//
//  BaseViewType.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import Foundation


protocol BaseViewType {
    
    /// 뷰계층
    func configureHierarchy()
    /// 레이아웃
    func configureLayout()
    /// 디자인
    func designView()
    /// 레지스터
    func register()
}



protocol RxBaseViewType: BaseViewType {
    
    /// 구독
    func subscribe()
    
}
