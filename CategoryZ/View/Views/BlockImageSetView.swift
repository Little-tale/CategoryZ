//
//  BlockImageSetView.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/20/24.
//

import UIKit
import SnapKit
/// 부모에서 width는 정해주어야 함.
final class BlockImageSetView: BaseView {

    private
    let imageView1 = makeImageView()
    
    private
    let imageView2 = makeImageView()
    
    private
    let imageView3 = makeImageView()
    
    private
    let imageView4 = makeImageView()
    
    private
    let imageView5 = makeImageView()
    
    lazy var imageViews = [
        imageView1,
        imageView2,
        imageView3,
        imageView4,
        imageView5,
    ]
    
    
    override func configureHierarchy() {
        imageViews.forEach { item in
            self.addSubview(item)
        }
    }
}

extension BlockImageSetView {
    
    func setModel(_ models: [String]) {
    
        imageViews.forEach { item in
            item.snp.removeConstraints()
        }
        
        switch models.count {
        case 1: set1Layout()
        case 2: set2Layout()
        case 3: set3Layout()
        case 4: set4Layout()
        case 5: set5Layout()
        default: return
        }
        
        for i in 0..<models.count {
            imageViews[i].downloadImage(
                imageUrl: models[i],
                resizeCase: .low,
                JHImage.defaultImage
            )
        }
    }
    
    func ifNeedReset() {
        imageViews.forEach { $0.isHidden = true }
    }
}

extension BlockImageSetView {
    
    private
    func set1Layout() {
        for i in 1...4 {
            imageViews[i].isHidden = true
        }
        
        imageViews[0].isHidden = false
        
        imageViews[0].snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private
    func set2Layout() {
        for i in 2...4 {
            imageViews[i].isHidden = true
        }
        
        for i in 0...1 {
            imageViews[i].isHidden = false
        }
        
        imageViews[0].snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2).offset(-1)
        }
        imageViews[1].snp.makeConstraints { make in
            make.trailing.verticalEdges.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2).offset(-1)
        }
    }
    
    private
    func set3Layout() {
        for i in 3...4 {
            imageViews[i].isHidden = true
        }
        
        for i in 0...2 {
            imageViews[i].isHidden = false
        }
        
        imageViews[0].snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3).offset(-4/3)
        }
        imageViews[1].snp.makeConstraints { make in
            make.leading.equalTo(imageViews[0].snp.trailing).offset(2)
            make.verticalEdges.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3).offset(-4/3)
        }
        imageViews[2].snp.makeConstraints { make in
            make.leading.equalTo(imageViews[1].snp.trailing).offset(2)
            make.verticalEdges.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3).offset(-4/3)
        }
    }
    
    private
    func set4Layout() {
        imageViews[4].isHidden = true
        for i in 0...3 { imageViews[i].isHidden = false }
        
        imageViews[0].snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalToSuperview().dividedBy(2).offset(-1)
        }
        imageViews[1].snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.width.height.equalToSuperview().dividedBy(2).offset(-1)
        }
        imageViews[2].snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.width.height.equalToSuperview().dividedBy(2).offset(-1)
        }
        imageViews[3].snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.width.height.equalToSuperview().dividedBy(2).offset(-1)
        }
    }
    
    private
    func set5Layout() {
        for i in 0...4 { imageViews[i].isHidden = false }
        imageViews[0].snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2).offset(-1)
            make.width.equalToSuperview().dividedBy(3).offset(-4/3)
        }
        imageViews[1].snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(imageViews[0].snp.trailing).offset(2)
            make.height.width.equalTo(imageViews[0])
        }
        imageViews[2].snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(imageViews[1].snp.trailing).offset(2)
            make.height.width.equalTo(imageViews[0])
        }
        
        imageViews[3].snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.height.width.equalToSuperview().dividedBy(2).offset(-1)
        }
        imageViews[4].snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.height.width.equalTo(imageViews[3])
        }
    }
}


extension BlockImageSetView {
    static func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 6
        return view
    }
}
