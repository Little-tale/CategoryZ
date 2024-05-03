//
//  DonateViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/1/24.
//

import UIKit
import WebKit
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
        var userNick = ""

        Observable.just(PriceModel.allCases)
            .bind(to: homeView.pricePicker.rx.itemTitles) { _, item in
                return item.price
            }
            .disposed(by: disPoseBag)
        
        let inputUserId = BehaviorRelay<String> (value: userID)
        let firstPrice = PriceModel.allCases.first!
        let ifSelectedPrice = BehaviorRelay<PriceModel> (value:firstPrice)
        
        let donateButtonTap = homeView.donateButton.rx.tap
        
        let publishModelRequest = PublishRelay<IamportPayment> ()
       
        let publishModelResponse = PublishRelay<IamportResponse?> ()
        
        let input = DonateViewModel.Input(
            inputUserId: inputUserId,
            ifSelectedPrice: ifSelectedPrice,
            donateButtonTap: donateButtonTap,
            publishModelResponse: publishModelResponse
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
                userNick = model.nick
            }
            .disposed(by: disPoseBag)
        

        output.networkError
            .drive(with: self) { owner, error in
                owner.errorCatch(error)
            }
            .disposed(by: disPoseBag)
        
      
        // 선택 되어질 값
        homeView.pricePicker.rx.modelSelected(PriceModel.self)
            .bind { models in
                ifSelectedPrice.accept(models.first!)
            }
            .disposed(by: disPoseBag)
        // test@test.com
        output.moveToDonateView
            .bind(with: self) { owner, model in

                let modelRequest = model.makePayment()
                
                publishModelRequest.accept(modelRequest)
                
                Iamport.shared.payment(
                    navController: owner.navigationController!,
                    userCode: APIKey.userCode.rawValue,
                    payment: modelRequest,
                    paymentResultCallback: { iamportResponse in
                        
                        print(String(describing: iamportResponse))
                        publishModelResponse.accept(iamportResponse)
                    })
            }
            .disposed(by: disPoseBag)
        
        
        
        output.successTrigger
            .drive(with: self) { owner, model in
                owner.showAlert(
                    title: userNick + "님 결제 성공",
                    message: model.amount + " 원 결제 완료되었어요!",
                    actionTitle: "확인") { _ in
                        owner.navigationController?.popViewController(animated: true)
                    }
            }
            .disposed(by: disPoseBag)
        
        
    }
}



