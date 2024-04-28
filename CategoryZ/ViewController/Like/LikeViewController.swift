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
        $0.register(ProfilePostCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePostCollectionViewCell.identi)
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
        
        rx.viewDidAppear
            .filter { $0 == true }
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
        models.bind(to: collectionView.rx.items(cellIdentifier: ProfilePostCollectionViewCell.identi, cellType: ProfilePostCollectionViewCell.self)) {
            row, item, cell in
            
            if let url =  item.files.first {
                cell.postImageView.downloadImage(imageUrl:url , resizing: cell.postImageView.frame.size)
            }
            
            cell.postContentLabel.text = DateManager.shared.differenceDateString(item.createdAt)
            
            cell.postContentLabel.text = item.content
            
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 12
        }
        .disposed(by: disPoseBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private
    func navigationSetting(){
        navigationItem.title = "좋아요 모아요"
    }
}

extension LikeViewController: CustomPinterestLayoutDelegate {
    
    func collectionView(for collectionView: UICollectionView, heightForAtIndexPath indexPath: IndexPath) -> CGFloat {
        let aspectString = viewModel.realModel
            .value[indexPath.item].content3
        let aspect = CGFloat(Double(aspectString) ?? 1 )
        
        let cellWidth: CGFloat = view.bounds.width / 2
        
        return cellWidth / aspect
    }

}
