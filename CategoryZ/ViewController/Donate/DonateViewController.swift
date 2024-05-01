//
//  DonateViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import iamport_ios
/*
 need To DonateModel
 
 */

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
        
        let ifSelectedPrice = BehaviorRelay<PriceModel> (value: .thousand1)
        
        let donateButtonTap = homeView.donateButton.rx.tap
        
        let input = DonateViewModel.Input(
            inputUserId: inputUserId,
            ifSelectedPrice: ifSelectedPrice
            
        )
        
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
        
        // 선택 되어질 값
        homeView.pricePicker.rx.modelSelected(PriceModel.self)
            .bind { models in
                ifSelectedPrice.accept(models.first!)
            }
            .disposed(by: disPoseBag)
        
        // 버튼을 누르면 본인인증을 하게 유도
        donateButtonTap
            .bind(with: self) { owner, _ in
                let vc = CheckedUserViewController()
                vc.checkUserDelegate = owner.viewModel
                vc.modalPresentationStyle = .pageSheet

                owner.navigationController?
                    .present(vc, animated: true)
            }
            .disposed(by: disPoseBag)
    }
}



