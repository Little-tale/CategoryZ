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
    
    private
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.register(PinterestCell.self, forCellWithReuseIdentifier: PinterestCell.identi)
    }
    
    private
    let viewModel = LikeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSetting()
        let layout = CustomPinterestLayout(
            numberOfColums: 2,
            cellPadding: 4
        )
        layout.delegate = self
        collectionView.collectionViewLayout = layout
    }
    
    override func subscriver() {
        let startTriggerSub = PublishRelay<Void> ()
        
        rx.viewWillAppear
            .bind { _ in
                startTriggerSub.accept(())
            }
            .disposed(by: disPoseBag)
        
        let input = LikeViewModel.Input(
            startTriggerSub: startTriggerSub
        )
        
        let output = viewModel.transform(input)
        
        networkError(output.networkError)
        
        collectionViewRxSetting(output.successData)
        
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
        models.bind(to: collectionView.rx.items(cellIdentifier: PinterestCell.identi, cellType: PinterestCell.self)) {
            row, item, cell in
            cell.setModel(item)
            cell.layer.cornerRadius = 12
        }
        .disposed(by: disPoseBag)
        
        collectionView.rx.modelSelected(SNSDataModel.self)
            .bind(with: self) { owner, model in
                let vc = SingleSNSViewController()
                vc.setModel(model)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disPoseBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func navigationSetting(){
        navigationItem.title = "좋아요 모아요"
    }
    
}

extension LikeViewController: CustomPinterestLayoutDelegate {
    
    func collectionView(for collectionView: UICollectionView, heightForAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        let model = viewModel.realModel
            .value[indexPath.item]
        
        let aspectString = model.content3
        let aspect = CGFloat(Double(aspectString) ?? 1 )
        
        let cellWidth: CGFloat = view.bounds.width / 2
    
        let date: CGFloat = 24
        
        return (cellWidth / aspect) + 24 + date + 12
    }
}
