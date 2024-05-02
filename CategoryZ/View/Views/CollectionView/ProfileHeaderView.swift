//
//  ProfileHeaderView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/21/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

protocol SelectedProductId: NSObject {
    func selected(productID: ProductID)
}

final class ProfileHeaderView: UICollectionReusableView {
    
    private
    let collectionView: UICollectionView
    
    private
    let disPoseBag = DisposeBag()
    
    private
    var selectedProduct = ProductID.dailyRoutine
    
    weak var selectedProductDelegate: SelectedProductId?
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        let itemSize = frame.height - 10
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        register()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private
    func bind(){
        
        let behiber = BehaviorRelay(value: [
            ProductID.dailyRoutine,
            ProductID.fashion,
            ProductID.pet
        ])
        
        let selectedProduct = PublishRelay<ProductID> ()
        
        behiber
        .bind(to: collectionView.rx.items(cellIdentifier: CategoryReusableCell.reusableIdenti, cellType: CategoryReusableCell.self)) { [weak self] row, item ,cell in
            cell.setSection(item)
            cell.isSelected(self?.selectedProduct == item)
        }
        .disposed(by: disPoseBag)
        
        
        collectionView.rx.modelSelected(ProductID.self)
            .bind(with: self) { owner, producId in
               
                owner.selectedProduct = producId
                behiber.accept(behiber.value)
                selectedProduct.accept(producId)
            }
            .disposed(by: disPoseBag)
        
        selectedProduct
            .bind(with: self) { owner, productId in
                NotificationCenter.default.post(name: .selectedProductId, object: nil, userInfo: ["productID": productId])
                owner.selectedProductDelegate?.selected(productID: productId)
            }
            .disposed(by: disPoseBag)
    }
    
    private
     func configureHierarchy() {
        addSubview(collectionView)
    }
    
    private
     func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    private
     func register() {
        collectionView.register(CategoryReusableCell.self, forCellWithReuseIdentifier: CategoryReusableCell.reusableIdenti)
    }
}
