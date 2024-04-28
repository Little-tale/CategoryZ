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
    
 
    private
    let behaivorImageView = PublishRelay<[UIImageView]>()
    
    private
    lazy var imageProcesor = ResizingImageProcessor(referenceSize: CGSize(width: 500, height: 400), mode: .aspectFill)
    
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
    
    init() {
        super.init(frame: .zero)
        subscribe()
    }
   
    override func register() {
        
        // Rx 적으로변경해보자
        scrollView.rx.didScroll
            .withUnretained(self)
            .map { owner, _ in
                if owner.frame.width == 0 {
                    return 0
                }else {
                    return Int(round( // 가로축 좌표 / 뷰 윗스
                        owner.scrollView.contentOffset.x / owner.scrollView.frame.width
                    ))
                }
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
    
    private
    func subscribe() {
        behaivorImageView
            .bind(with: self) { owner , imageViews in
                
                owner.scrollView.subviews.forEach { $0.removeFromSuperview() }
                
                imageViews.forEach { owner.scrollView.addSubview($0)}
                
                for (index, view) in imageViews.enumerated() {
                    view.snp.makeConstraints { make in
                        make.verticalEdges.equalTo(owner.scrollView)
                        make.size.equalTo(owner.scrollView)
                        if index == 0 {
                            // 0번째 일때 스크롤뷰 앞
                            make.leading.equalTo(owner.scrollView)
                        } else {
                            // 그게아니면 다 전뷰의 뒤를 앞
                            make.leading.equalTo(
                                imageViews[index - 1].snp.trailing
                            )
                        }
                        if index == imageViews.count - 1 {
                            make.trailing.equalTo(owner.scrollView)
                        }
                    }
                }
                owner.pageController.numberOfPages = imageViews.count
            }
            .disposed(by: disposedBag)
    }
    
    func setModel(_ images: [UIImage]) {
        var imageViews: [UIImageView] = []
        images.forEach { image in
            let view = UIImageView()
            view.image = image
            imageViews.append(view)
        }
        behaivorImageView.accept(imageViews)
    }
    
    func setModel(_ urlString: [String]) {
        var imageViews: [UIImageView] = []
        urlString.forEach { image in
            let view = UIImageView()
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            view.backgroundColor = JHColor.darkGray
            view.downloadImage(imageUrl: image,resizing: .init(width: 400, height: 300))
            imageViews.append(view)
        }
        
        behaivorImageView.accept(imageViews)
        
        let totalWidth = scrollView.frame.width * CGFloat(imageViews.count)
        scrollView.contentSize = CGSize(width: totalWidth, height: scrollView.frame.height)
        
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


//            view.kf.setImage(with: URL(string: image), options: [
//                .processor(imageProcesor),
//                .transition(.fade(1)),
//                .cacheOriginalImage,
//                .requestModifier(
//                    KingFisherNet()
//                ),
//            ]) { result in
//                switch result {
//                case .success(let s):
//                    // print(s)
//                    break
//                case .failure(let e):
//                    // 에러 발생시 다 알려야 하는가? 애매한 부분
//                    // print(e.errorDescription)
//                    break
//                }
//            }
