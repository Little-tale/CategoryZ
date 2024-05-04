//
//  CustomTabbar.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/4/24.
//

import UIKit
import Then
import SnapKit
/*
 현재 연구중입니다.
 */

final class CustomTabbar: UITabBar {
    
    private 
    var color: UIColor?
    
    private
    var radii: CGFloat
    
    init(backColor: UIColor?, radius: CGFloat, frame: CGRect) {
        color = backColor
        radii = radius
        super.init(frame: frame)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private
    var shapeLayer: CALayer?
    
    
    override func draw(_ rect: CGRect) {
       
    }
    
    private
    func addShape() {
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = JHColor.likeColor.cgColor
        shapeLayer.fillColor = color?.cgColor ?? JHColor.white.cgColor
        shapeLayer.shadowColor = JHColor.gray.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: -2)
        shapeLayer.shadowOpacity = 0.21
        shapeLayer.shadowRadius = 8
        shapeLayer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: radii
        ).cgPath
        
        
        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }
        
        self.shapeLayer = shapeLayer
    }
    
    private
    func createPath() -> CGPath {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: .init(width: radii, height: 0.0)
        )
        
        return path.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isTranslucent = true
        var tabFrame = frame
        tabFrame.size.height = 65 + safeAreaInsets.bottom
        
        tabFrame.origin.y = frame.origin.y + frame.height - 65 - safeAreaInsets.bottom
        
        layer.frame = tabFrame
        items?.forEach({
            $0.titlePositionAdjustment = UIOffset(
                horizontal: 0, vertical: -5
            )
        })
        
    }
    
}
