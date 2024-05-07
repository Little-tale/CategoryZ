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

    var dataSource: DataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
        
//        let layout = CustomPinterestLayout(
//            numberOfColums: 2,
//            cellPadding: 4
//        )
//        layout.delegate = self
//        collectionView.collectionViewLayout = layout
        
    
        
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
        
        let zipCollectionView = Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(SNSDataModel.self))
            
        zipCollectionView
            .bind(with: self) { owner, collectionView in
                let vc = SingleSNSViewController()
                
                let model = collectionView.1
                
                model.currentRow = collectionView.0.item
                
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
        let viewWidth = view.bounds.width
        
        let publishLayoutConfig = PublishRelay<PinterestCompostionalLayout.Configuration> ()
        let nextTrigger = PublishRelay<Void> ()
//        models
//            .distinctUntilChanged()
//            .bind(to: collectionView.rx.items(cellIdentifier: PinterestCell.reusableIdenti, cellType: PinterestCell.self)) {
//                row, item, cell in
//                print("** 방출시점 갯수",models.value.count)
//                cell.layer.cornerRadius = 12
//               
//                cell.setModel(item)
//            }
//            .disposed(by: disPoseBag)
        models
            .distinctUntilChanged()
            .bind(with: self , onNext: { owner, models in
                let config = owner.makePinterestLayoutConfiguration(models, viewWidth: viewWidth)
                publishLayoutConfig.accept(config)
            })
            .disposed(by: disPoseBag)
    
        publishLayoutConfig.bind(with: self) { owner, configuration in
            let layout = UICollectionViewCompositionalLayout { index, environment in
                return PinterestCompostionalLayout.makeLayoutSection(
                    config: configuration,
                    environment: environment,
                    sectionIndex: index
                )
            }
            owner.collectionView.setCollectionViewLayout(layout, animated: true)
            nextTrigger.accept(())
        }
        .disposed(by: disPoseBag)
        
        nextTrigger
            .withLatestFrom(models)
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
        
        makeDataSource()
        makeSnapshot(models: [])
    }
    
    override func navigationSetting(){
        navigationItem.title = "좋아요 모아요"
    }
    
    private
    func makePinterestLayoutConfiguration(
        _ models:[SNSDataModel],
        viewWidth: CGFloat ) -> PinterestCompostionalLayout.Configuration {
            
            return PinterestCompostionalLayout.Configuration(
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
        )
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
                cell.backgroundColor = .red
                return cell
            }
        )
    }
    
    private
    func makeSnapshot(models: [SNSDataModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int,SNSDataModel> ()
        snapshot.appendSections([0])
        snapshot.appendItems(models, toSection: 0)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    
}

//extension LikeViewController: CustomPinterestLayoutDelegate {
//    
//    func collectionView(for collectionView: UICollectionView, heightForAtIndexPath indexPath: IndexPath) -> CGFloat {
//        print("**셀을 그리는 펑션입장 : \(indexPath.item)")
//        let model = viewModel.realModel.value[indexPath.item]
//        
//        let aspectString = model.content3
//        let aspect = CGFloat(Double(aspectString) ?? 1 )
//        let cellWidth: CGFloat = view.bounds.width / 2
//        let date: CGFloat = 24
//        return (cellWidth / aspect) + 24 + date + 12
//    }
//}
