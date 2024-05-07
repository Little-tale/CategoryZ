//
//  CustomPinterestLayout.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/27/24.
//

import UIKit


protocol CustomPinterestLayoutDelegate: AnyObject {
    
    func collectionView(for collectionView: UICollectionView, heightForAtIndexPath indexPath: IndexPath) -> CGFloat
    
}

final class CustomPinterestLayout: UICollectionViewFlowLayout {
    
    weak var delegate: CustomPinterestLayoutDelegate?
    
    /// 한 행의 아이템 갯수
    private let numberOfColums: Int // 한 행의 아이템 갯수
    /// 셀의 패딩
    private let cellPadding: CGFloat // 셀의 패딩
    /// 필요의 경우 헤더의 높이 지정: Int
    private
    let headerHeight: CGFloat?
    
    // Options 다시 레이아웃을 계산할 필요가 없도록 메모리에 저장한다.
    private
    var cache: [UICollectionViewLayoutAttributes] = []
    
    // 1. 컬렉션뷰 컨텐츠 사이즈를 지정해야한다.
    // 1.1 컨텐츠 높이의 그릇을 만들고 (프로퍼티)
    private
    var contentsHeight: CGFloat = 0
    
    
    // 1.2 컨텐츠 넓이를 정하는데...
    private
    var contetnsWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        // 여백의 정보를 받아와
        let insets = collectionView.contentInset
        // 좌우여백을 더한값을
        let totalInset = insets.left + insets.right
        // 컬렉션뷰넓이에 값을 빼면. 넓이가 나온다.
        return collectionView.bounds.width - (totalInset)
    }
    
    
    init(numberOfColums: Int, cellPadding: CGFloat,_ headerHeight: CGFloat? = nil) {
        self.numberOfColums = numberOfColums
        self.cellPadding = cellPadding
        self.headerHeight = headerHeight
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
  
    
    // 1.END 컬렉션뷰의 컨텐츠 사이즈를 지정
    override var collectionViewContentSize: CGSize {
        // let minHeight = collectionView?.bounds.height ?? 0
        
        return CGSize(width: contetnsWidth, height: contentsHeight)
    }
        
    // 2. 컬렉션뷰가 처음 초기화 되거나, 뷰가 변경될때 실행됩니다.
    // ... 해당 메서드는 레이아웃을 미리 계산 하고  메모리에 캐쉬하여
    // ... 불필요한 반복적인 연산을 하는것을 방지하도록 해야한다.
    override func prepare() {
        super.prepare()
        
        guard
            cache.isEmpty,
            let collectionView = collectionView
            else {
              return
          }
        
//        cache.removeAll()
        
        // xOffset 계산
        let columnWidth: CGFloat = contetnsWidth / CGFloat(numberOfColums) // 컨텐츠 / 셀갯수
        var xOffset: [CGFloat] = [] // X 축 저장 배열
        for column in 0..<numberOfColums {
            let offset = CGFloat(column) * columnWidth // 각열의 x축 위치 계산
            xOffset += [offset] // "계산된 위치를 배열에 추가
        }
        
        // yOffset 계산
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColums) // 각 열의 y축 시작 위치를 저장할 배열
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let imageHeight = delegate?.collectionView(
                for: collectionView,
                heightForAtIndexPath: indexPath
            ) ?? 0
            
            // 셀의 전체 높이를 계산 (상하 패딩 포함)
            let height = cellPadding * 2 + imageHeight
            
            let frame = CGRect(
                x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: height
            )
            
            let insetFrame = frame.insetBy(
                dx: cellPadding,
                dy: cellPadding
            )
            
            // cache 저장
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = insetFrame // 레이아웃 속성에 저장
            
            cache.append(attributes) // 캐시에도 저장
            
            // 새로 계산된 항목의 프레임을 설명하도록 확장
            contentsHeight = max(contentsHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            // 다음 항목이 다음 열에 배치되도록 설정
            column = column < (numberOfColums - 1) ? (column + 1) : 0
        }
        
    }
    
    // 3. 모든 셀과 서브 뷰의 레이아웃 정보를 리턴한다. (Rect) 기반
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attribute in cache {
            // intersects 메서드는 두 사각형이 겹치는지 여부를 반환
            if attribute.frame.intersects(rect){
                // 셀 프레임과 요청과 교차한다면 리턴 값의 추가
                    visibleLayoutAttributes.append(attribute)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    // 4. 모든 셀의 레이아웃 정보를 리턴한다. IndexPath 기반
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    
}
