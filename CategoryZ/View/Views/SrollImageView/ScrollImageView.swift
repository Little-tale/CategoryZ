//
//  ScrollImageView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/17/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import Kingfisher

final class ScrollImageView: RxBaseView {
    
    private var photoImageView: [UIImageView] = [] {
        didSet {
            settingData()
            print(photoImageView.count)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let totalWidth = scrollView.frame.width * CGFloat(photoImageView.count)
        scrollView.contentSize = CGSize(width: totalWidth, height: scrollView.frame.height)
    }

    
    let scrollView = UIScrollView().then {
        // 수평 스크롤 인디케이터 끔
        $0.showsHorizontalScrollIndicator = false
        // 페이징 여부
        $0.isPagingEnabled = true
        // 바운스 효과 여부
        $0.bounces = false
    }
    // 페이지 컨트롤러
    let pageController = UIPageControl()
    /*
     회고... scrollView.rx.딜리게이트가 많음
     2. Thread 1: Swift runtime failure: Double value cannot be converted to Int because it is either infinite or NaN
     예상되는 부분은 Rx가 더 빨라서 그럴 가능성이 있음
     
     */
    override func register() {
        
        // Rx 적으로변경해보자
        scrollView.rx.didScroll
            .withUnretained(self)
            .map { owner, _ in
                if owner.frame.width == 0 {
                    return 0
                }
                print("현재 X축: \(owner.scrollView.contentOffset.x)")
                return Int(round( // 가로축 좌표 / 뷰 윗스
                    owner.scrollView.contentOffset.x / owner.frame.width
                ))
            }
            .bind(to: pageController.rx.currentPage)
            .disposed(by: disposedBag)
        
        // 페이지 컨트롤러의 값이 변경되면
        pageController.rx.controlEvent(.valueChanged)
            .bind(with: self) { owner, _ in
                // 현재페이지를 받아 실제로 변환되게 하기
                let page = owner.pageController.currentPage
                owner.changeImageView(current: page)
            }
            .disposed(by: disposedBag)
        
    }

    
    override func configureHierarchy() {
        addSubview(scrollView)
        addSubview(pageController)
    }
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageController.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(20)
        }
    }
    
    private func settingData(){
        /// 이미지 를 한번에 스크롤뷰에 넣기
        
        photoImageView.forEach { $0.removeFromSuperview() }
        
        photoImageView.forEach(scrollView.addSubview)
        
        /// 뷰의 갯수에 따라 유동적 레이아웃 잡기
        for (index, view) in photoImageView.enumerated() {
            view.snp.makeConstraints { make in
                make.verticalEdges.equalTo(scrollView)
                make.size.equalTo(scrollView)
                if index == 0 {
                    make.leading.equalTo(scrollView)
                }else {
                    make.leading.equalTo(photoImageView[index - 1].snp.trailing)
                }
                if index == photoImageView.count - 1 {
                    make.trailing.equalTo(scrollView)
                }
            }
        }
        // 페이지 컨트롤러 페이지 갯수는 포토 이미지 갯수와 동일함.
        pageController.numberOfPages = photoImageView.count
    }
    
    func setModel(_ images: [UIImage]) {
        var imageView: [UIImageView] = []
        images.forEach { image in
            let view = UIImageView()
            view.image = image
            imageView.append(view)
        }
        photoImageView = imageView
    }
    
    func setModel(_ urlString: [String]) {
        var imageView: [UIImageView] = []
        urlString.forEach { image in
            
            let view = UIImageView()
            view.kf.setImage(with: URL(string: image), options: [
                .requestModifier(
                    KingFisherNet()
                )
            ])
            imageView.append(view)
        }
        photoImageView = imageView
    }
  
}

extension ScrollImageView {

    private func changeImageView(current: Int) {
        // 현재 페이지의 수를 받아
        // 현재 페이지의 스크롤뷰의 넓이 만큼 즉 해당하는 X 좌표
        let moveTo = CGFloat(current) * scrollView.frame.width
        //  해당하는 좌표를 CGPoint로 변환
        let movePoint = CGPoint(x: moveTo, y: 0)
        
        scrollView.setContentOffset(movePoint, animated: true)
    }
}

/*
 문제의 코드 스크롤이 안되는 이유
 for (index, view) in photoImageView.enumerated() {
     view.snp.makeConstraints { make in
         make.verticalEdges.equalTo(scrollView)
         make.size.equalTo(scrollView)
         if index == 0 {
             make.leading.equalTo(scrollView)
         }else {
             make.leading.equalTo(photoImageView[index - 1].snp.trailing)
         }
         if index == photoImageView.count - 1 {
             make.trailing.equalTo(scrollView)
         }
     }
 }
 */
