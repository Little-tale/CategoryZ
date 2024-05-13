//
//  LikeViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/28/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then


final class LikeViewController: RxBaseViewController {
    
    weak var pinteresLayoutCreator: PinterestLayoutCreator?
    let layoutClass = PinterestCompostionalLayout()
    typealias DataSourceSnapShot = NSDiffableDataSourceSnapshot<Int, SNSDataModel>
    typealias DataSource = UICollectionViewDiffableDataSource<Int, SNSDataModel>
    
    let button = UIButton()
    
    private
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.register(PinterestCell.self, forCellWithReuseIdentifier: PinterestCell.reusableIdenti)
    
    }
    
    private
    let viewModel = LikeViewModel()

    var dataSource: DataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()

    }
    
    override func subscriver() {
        let startTriggerSub = BehaviorRelay<Void> (value: ())
        
        let currentCellItemAt = PublishRelay<Int> ()
        
        let reloadTrigger = PublishRelay<Void> ()
        
        let input = LikeViewModel.Input(
            startTriggerSub: startTriggerSub,
            currentCellItemAt: currentCellItemAt,
            reloadTrigger: reloadTrigger
        )
        
        let output = viewModel.transform(input)
        
        networkError(output.networkError)
        
        collectionViewRxSetting(output.successData)
        
        collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                let vc = SingleSNSViewController()
                
                let model = output.successData.value[indexPath.item]
                
                model.currentRow = indexPath.item
                
                vc.setModel(model)
                
                vc.ifChangeOfLikeDelegate = owner.viewModel
                
                vc.deleteClosure = {
                    reloadTrigger.accept(())
                }
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
        
        collectionView.rx.willDisplayCell
            .bind { cellInfo in
                currentCellItemAt.accept(cellInfo.at.item)
            }
            .disposed(by: disPoseBag)
        
    }
    
    private
    func networkError(_ error:  Driver<NetworkError>) {
        error.drive(with: self) { owner, error in
            owner.errorCatch(error)
        }
        .disposed(by: disPoseBag)
    }
    private
    func collectionViewRxSetting(_ models: BehaviorRelay<[SNSDataModel]>) {
        
        models
            .bind(with: self) { owner, models in
                owner.makeSnapshot(models: models)
            }
            .disposed(by: disPoseBag)
        
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
        
        pinteresLayoutCreator = layoutClass
        
        createLayout()
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        makeDataSource()
        makeSnapshot(models: [])
    }
    
    override func navigationSetting(){
        navigationItem.title = "좋아요 모아요"
    }
    
    private
    func makeDataSource() {
        let register = colelctionCellRegiter()
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: register, for: indexPath, item: itemIdentifier)
        })
    }
    
    private
    func colelctionCellRegiter() -> UICollectionView.CellRegistration<PinterestCell, SNSDataModel> {
        UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.setModel(itemIdentifier)
        }
    }
    
    private
    func makeSnapshot(models: [SNSDataModel]) {
        var snapshot = DataSourceSnapShot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        
        snapshot.appendItems(models.map{$0}, toSection: 0)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private
    func createLayout() {
        let config = PinterestConfiguration(
            numberOfColumns: 2,
            interItemSpacing: 6,
            edgeInset: .init(top: 0, leading: 6, bottom: 0, trailing: 6)) { [weak self] item, _ in
                guard let self else { return 150 }
                let aspectString = viewModel.realModel.value[item].content3
                let aspect = CGFloat(Double(aspectString) ?? 1)
                let result = (view.bounds.width / 2 / aspect) + 60
                return result
            } itemCountProfider: { [weak self] in
                guard let self else { return 0 }
                return viewModel.realModel.value.count
            }
        
        pinteresLayoutCreator?
            .createPinterstLayout(for: collectionView, config: config, viewWidth: view.bounds.width)
    }
    
}

