//
//  DonateViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import UIKit
import RxSwift
import RxCocoa

final class DonateViewController: RxHomeBaseViewController<DonateView> {
    
    private
    let viewModel = DonateViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func setModel(_ userID: String) {
        subscribe(userID)
    }
    
    private
    func subscribe(_ userID : String) {
        
        Observable.just(PriceModel.allCases)
            .bind(to: homeView.pricePicker.rx.itemTitles) { _, item in
                return item.price
            }
            .disposed(by: disPoseBag)
        
        
        let inputUserId = BehaviorRelay<String> (value: userID)
        
        let input = DonateViewModel.Input(inputUserId: inputUserId)
        
        let output = viewModel.transform(input)
        
        output.successProfile
            .drive(with: self) { owner, model in
                if model.profileImage != "" {
                    owner.homeView.profileImageView.downloadImage(
                        imageUrl: model.profileImage,
                        resizing: owner.homeView.profileImageView.frame.size
                    )
                } else {
                    owner.homeView.profileImageView.image = JHImage.defaultImage
                }
                
                owner.homeView.userNameLabel.text = model.nick
            }
            .disposed(by: disPoseBag)
        

        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
        
        // 후원 포스터
        output.successModel
            .filter({ $0.count != 0 })
            .drive(with: self) { owner, models in
                let model = models.first
                
            }
            .disposed(by: disPoseBag)
    }
    
}
