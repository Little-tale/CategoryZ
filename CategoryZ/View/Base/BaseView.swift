//
//  BaseView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//

import UIKit

class BaseView: UIView, BaseViewType {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        designView()
        register()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy(){
        
    }
    func configureLayout(){
        
    }
    func designView(){
        
    }
    func register(){
        
    }
}
