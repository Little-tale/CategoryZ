//
//  SerchHashTagViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchHashTagViewController: RxHomeBaseViewController<RxCollectionView> {
    
    weak var backNavigation: UINavigationController?
    
    enum Section: Int, CaseIterable{
        case posts
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section,SNSDataModel>
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, SNSDataModel>
    
    let viewModel = SearchHashTagViewModel()
    
    private 
    var dataSource: DataSource?
    init(backNavigation: UINavigationController?) {
        self.backNavigation = backNavigation
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func designView() {
        homeView.collectionView.setCollectionViewLayout(CustomProfileCollectionViewLayout.createSearchCollectionViewLayout(), animated: true)
    }
    
    func getText(_ text: String) {
        subscribe(text)
    }
    
    override func subscriver() {
        configureDataSource()
        applySnapshot()
    }
    
    private
    func subscribe(_ text: String) {
        
        let behaiviorText = BehaviorRelay(value: text)
        
        let input = SearchHashTagViewModel.Input(
            behaiviorText: behaiviorText
        )
        
        let output = viewModel.transform(input)
        
        output.successModel
            .bind(with: self) { owner, models in
                print(models)
                owner.applySnapshot(models: models)
            }
            .disposed(by: disPoseBag)
        
        homeView.collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                // 시점 문제로 인한 처리
                if output.successModel.value.count < indexPath.item + 1 {
                    return
                }
            
                let value = output.successModel.value[indexPath.item]
                
                let vc = SingleSNSViewController()
                vc.setModel(value)
                owner.backNavigation?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
    
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.disposeBag = .init()
        disPoseBag = .init()
    }
    
    deinit{
        print("Deinit For SearchControl")
    }
    
}

extension SearchHashTagViewController {
    private 
    func applySnapshot(models: [SNSDataModel]? = nil) {
        var snapShot = SnapShot()
        
        snapShot.appendSections([.posts])
        
        if let models{
            snapShot.appendItems(models, toSection: .posts)
        }
        
        dataSource?.apply(snapShot,animatingDifferences: true)
    }
}


extension SearchHashTagViewController {
    private
    func configureDataSource() {
        dataSource = DataSource(
            collectionView: homeView.collectionView, cellProvider: { collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnlyRxImageCollectionViewCell.reusableIdenti, for: indexPath) as? OnlyRxImageCollectionViewCell else {
                print("Error")
                    return .init()
                }
                cell.setModel(item.files)
                return cell
            }
        )
        
        dataSource?.supplementaryViewProvider = { [weak self]
            (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let self else { return nil }
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileHeaderView.reusableIdenti,
                for: indexPath) as? ProfileHeaderView else {
                return nil
            }
            header.selectedProductDelegate = viewModel
            return header
        }
    }
}

