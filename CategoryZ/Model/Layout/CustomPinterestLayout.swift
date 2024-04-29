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
    
    
    init(numberOfColums: Int, cellPadding: CGFloat,_ headerHeight: CGFloat? = nil) {
        self.numberOfColums = numberOfColums
        self.cellPadding = cellPadding
        self.headerHeight = headerHeight
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 1. 컬렉션뷰 컨텐츠 사이즈를 지정해야한다.
    // 1.1 컨텐츠 높이의 그릇을 만들고 (프로퍼티)
    private
    var contentsHeight: CGFloat = 0
    
    // Options 다시 레이아웃을 계산할 필요가 없도록 메모리에 저장한다.
    private
    var cache: [UICollectionViewLayoutAttributes] = []
    
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
    
    // 1.END 컬렉션뷰의 컨텐츠 사이즈를 지정
    override var collectionViewContentSize: CGSize {
        let minHeight = collectionView?.bounds.height ?? 0
        
        return CGSize(width: contetnsWidth, height: max(contentsHeight,minHeight))
    }
        
    // 2. 컬렉션뷰가 처음 초기화 되거나, 뷰가 변경될때 실행됩니다.
    // ... 해당 메서드는 레이아웃을 미리 계산 하고  메모리에 캐쉬하여
    // ... 불필요한 반복적인 연산을 하는것을 방지하도록 해야한다.
    override func prepare() {
        guard let collectionView = collectionView,
              collectionView.numberOfSections > 0,
              collectionView.numberOfItems(inSection: 0) > 0,
              cache.isEmpty else {
            return
        }
        cache.removeAll()
        
        let cellWidth = contetnsWidth / CGFloat(numberOfColums)
        
        var yOffSet:[CGFloat] = []
        
        if let headerHeight {
            // 헤더 레이아웃 속성
            let headerIndexPath = IndexPath(item: 0, section: 0)

            let headerAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: headerIndexPath)
            
            headerAttribute.frame = CGRect(
                x: 0,
                y: 0,
                width: collectionView.bounds.width,
                height: headerHeight
            ) // 헤더높이 지정
            
            cache.append(headerAttribute)
            // cell 의 Y위치를 나타내는 배열입니다.
            yOffSet = [CGFloat](repeating: headerAttribute.frame.maxY, count: numberOfColums)
            
            yOffSet[0] = headerAttribute.frame.maxY
            
        } else {
            yOffSet = [CGFloat](repeating: 0, count: numberOfColums)
        }
        
        // cell 의 X위치를 나타내는 배열입니다.
        let xOffSet:[CGFloat] = [0, cellWidth]

        var colum: Int = 0 // 현재 행의 위치
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            // 인덱스 패스를 통해
            let indexPath = IndexPath(item: item, section: 0)
            // 인덱스 패스에 맞는 셀의 크기를 계산합니다.
            let customContentHeight = delegate?.collectionView(for: collectionView, heightForAtIndexPath: indexPath) ?? 100
            // 상항 패딩(패딩 2배) 에 컨테트 높이를 더한 값은 높이
            let height = cellPadding * 2 + customContentHeight
            
            let frame = CGRect(
                x: xOffSet[colum],
                y: yOffSet[colum],
                width: cellWidth,
                height: height
            )
            
            // 생소한 dx, dy가 나왔는데
            // dx: x축 방향의 패딩 값 -> 좌우 프레임 안으로 이동
            // dy: y축 방향의 패딩 값 -> 상하 프레임 안으로 이동
            let insetFrame = frame.insetBy(
                dx: cellPadding, dy: cellPadding
            )
            
            // 계산한 Frame를 통해 레이아웃정보를 반영하고 캐쉬에 저장
            let attribute = UICollectionViewLayoutAttributes(
                forCellWith: indexPath
            )
            // 레이아웃정보를 반영
            attribute.frame = insetFrame
            cache.append(attribute)
            
            // 컬렉션뷰의 높이를 다시 지정한다.
            // frame.maxY -> 현재 셀의 프레임이 끝나는 Y축 위치 -> 셀 상단 위치에서 셀 높이를 더한값
            contentsHeight = max(contentsHeight, frame.maxY)
            // 새로운 셀의 frame.maxY중 더큰 값을 선택하여 컬렉션뷰의 전체 컨텐츠 높이를 업데이트
            
            yOffSet[colum] = yOffSet[colum] + height
            
            // 다른 이미지 크기로 인해, 한쪽열에만 이미지가 추가됨을 방지
            colum = yOffSet[0] > yOffSet[1] ? 1 : 0
            // 만약 첫번째 열의 높이가 두번째 열의 높이보다 크다면
            // 새 셀들 두번째 열에 배치하는데
            // 아닐시 새 셀을 첫번째 열에 배치한다.
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
