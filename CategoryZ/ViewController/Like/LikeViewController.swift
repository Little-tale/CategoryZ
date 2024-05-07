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
    
    typealias DataSourceSnapShot = NSDiffableDataSourceSnapshot<Int, SNSDataModel>
    typealias DataSource = UICollectionViewDiffableDataSource<Int, SNSDataModel>
    
    private
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.register(PinterestCell.self, forCellWithReuseIdentifier: PinterestCell.reusableIdenti)
    }
    
    private
    let viewModel = LikeViewModel()

    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()

    }
    
    override func subscriver() {
        let startTriggerSub = BehaviorRelay<Void> (value: ())
        
        let currentCellItemAt = PublishRelay<Int> ()
        
        let input = LikeViewModel.Input(
            startTriggerSub: startTriggerSub,
            currentCellItemAt: currentCellItemAt
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
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        
        makeDataSource()
        makeSnapshot(models: [])
    }
    
    override func navigationSetting(){
        navigationItem.title = "좋아요 모아요"
    }
    
    private
    func createPinterstLayout(env: NSCollectionLayoutEnvironment, models: [SNSDataModel], viewWidth: CGFloat) -> NSCollectionLayoutSection {
        
        let layout = PinterestCompostionalLayout.makeLayoutSection(
            config: .init(
                numberOfColumns: 2, // 몇줄?
                interItemSpacing: 8, // 간격은?
                contentInsetsReference: UIContentInsetsReference.automatic, // 알아서
                itemHeightProvider: { item, _ in
                    let aspectString = models[item].content3
                    let aspect = CGFloat(Double(aspectString) ?? 1)
                    let result = (viewWidth / 2 / aspect) + 60
                    print(" 여긴 작동중 ....\(result)")
                    return result
                },
                itemCountProfider: {
                    return models.count
                }
            ),
            environment: env,
            sectionIndex: 0
        )
        
       return layout
           
    }
    
    private
    func makeDataSource(){
        
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PinterestCell.reusableIdenti,
                    for: indexPath
                ) as? PinterestCell else {
                    print("PinterestCell Error")
                    return .init()
                }
                cell.setModel(itemIdentifier)
                return cell
            }
        )
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
    func createLayout() -> UICollectionViewCompositionalLayout {
        let viewWidth = view.bounds.width
        let layout = UICollectionViewCompositionalLayout { [weak self] section, env in
            guard let self else { return nil }
            return createPinterstLayout(env: env, models: viewModel.realModel.value, viewWidth: viewWidth)
        }
        
        return layout
    }
    
}

