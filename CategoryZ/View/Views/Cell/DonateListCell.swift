//
//  DonateListCell.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/2/24.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit

final class DonateListCell: RxBaseTableViewCell {
    
    private
    let viewModel = DonateLisCelViewModel()

    private
    let productName = UILabel().then {
        $0.commentStyle()
        $0.textAlignment = .left
        $0.font = JHFont.UIKit.bo14
    }
    
    private
    let DonatedDate = UILabel().then {
        $0.font = JHFont.UIKit.li11
        $0.textAlignment = .right
    }
    
    private
    let contentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = JHFont.UIKit.bo16
        $0.textAlignment = .left
    }
    
    func setModel(_ model: PaymentData) {
        subscribe(model)
    }
    
    private
    func subscribe(_ model: PaymentData) {
        let behModel = BehaviorRelay(value: model)
        
        let input = DonateLisCelViewModel.Input(
            behModel: behModel
        )
        
        let output = viewModel.transform(input)
        
        output.productName
            .drive(productName.rx.text)
            .disposed(by: disposeBag)
        
        output.donateDate
            .drive(DonatedDate.rx.text)
            .disposed(by: disposeBag)
        
        output.contents
            .drive(contentLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        contentView.addSubview(productName)
        contentView.addSubview(DonatedDate)
        contentView.addSubview(contentLabel)
    }
    
    override func configureLayout() {
      
        productName.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(4)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(12)
        }
        
        DonatedDate.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(4)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(productName.snp.bottom).offset(5)
           
            make.leading.equalTo(productName)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(50)
            make.height.greaterThanOrEqualTo(30)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel.disposeBag = .init()
    }
}
