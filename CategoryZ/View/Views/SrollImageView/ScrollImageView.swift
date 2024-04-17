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

final class ScrollImageView: RxBaseView {
    
    private var photoImageView: [UIImageView] = [] {
        didSet {
            settingData()
        }
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
     */
    override func register() {
        
        // Rx 적으로변경해보자
        scrollView.rx.didScroll
            .withUnretained(self)
            .map { owner, _ in
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
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageController.snp.makeConstraints { make in
            make.bottom.equalTo(scrollView).inset(30)
            make.horizontalEdges.equalTo(scrollView)
            make.height.equalTo(30)
        }
    }
    
    private func settingData(){
        /// 이미지 를 한번에 스크롤뷰에 넣기
        photoImageView.forEach { [weak self] view in
            guard let self else { return }
            scrollView.addSubview(view)
        }
        
        /// 뷰의 갯수에 따라 유동적 레이아웃 잡기
        for (index, view) in photoImageView.enumerated() {
            view.snp.makeConstraints { make in
                // 스크롤뷰 사이즈와 동일
                make.size.equalTo(scrollView)
                // 기본적으로 수직은 고정
                make.verticalEdges.equalTo(scrollView)
                if index == 0 {
                    make.leading.equalTo(scrollView.snp.trailing)
                } else if index == photoImageView.count - 1 {
                    make.trailing.equalTo(scrollView)
                } else {
                    make.leading
                        .equalTo(photoImageView[index - 1].snp.trailing)
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
