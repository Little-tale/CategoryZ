//
//  PinterestCompostionalLayout.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/7/24.
//

import UIKit
/// 핀터레스트 컴포지셔널 레이아웃입니다.
final class PinterestCompostionalLayout {
    
    /// 핀터레스트 레이아웃 구성에 필요한 세부사항들을 정의하는 구조체입니다.
    struct Configuration {
        let numberOfColumns: Int // 열 갯수
        let interItemSpacing: CGFloat // 열과 행 간격 -> 아이템 간격
        let contentInsetsReference: UIContentInsetsReference // 섹션 ( 컨텐츠 ) 인셋
        let itemHeightProvider: (_ index: Int,_ itemWidth: CGFloat) -> CGFloat // 특정 인뎃스 아이템 높이 클로저
        let itemCountProfider: () -> Int // 섹션의 항목(아이템)수 제공하는 클로저
        
        init( numberOfColumns: Int, // 상동
             interItemSpacing: CGFloat, // 상동
             contentInsetsReference: UIContentInsetsReference, // 상동
             itemHeightProvider: @escaping (_: Int, _: CGFloat) -> CGFloat, // 상동
             itemCountProfider: @escaping () -> Int // 상동
        ) {
            self.numberOfColumns = numberOfColumns
            self.interItemSpacing = interItemSpacing
            self.contentInsetsReference = contentInsetsReference
            self.itemHeightProvider = itemHeightProvider
            self.itemCountProfider = itemCountProfider
        }
    }
    
    // 레이아웃을 구성하는데에 필요한 데이터를 계산하는 클래스 입니다.
    final class LayoutBuilder {
        private var columnHeights: [CGFloat] // 열 높이들을 저장하죠
        private let numberOfColumns: CGFloat // 열 갯수
        private let interItemSpacing: CGFloat // 열과 행 (아이템) 간격
        private let itemHeightProvider: (_ index: Int,_ itemWidth: CGFloat) -> CGFloat // 특정 아이템 높이 계산하는 클로저
        private let collectionWidth: CGFloat // 컬렉션뷰 넓이
        
        init(configuration: Configuration, collectionWidth: CGFloat) {
            // 초기화시 기본값 설정 합니당
            // 모든 열의 초기 높이를 0으로 설정해요
            columnHeights = [CGFloat](repeating: 0, count: configuration.numberOfColumns)
            numberOfColumns = CGFloat(configuration.numberOfColumns)
            itemHeightProvider = configuration.itemHeightProvider
            interItemSpacing = configuration.interItemSpacing
            self.collectionWidth = collectionWidth
        }
        
        /// 각 열의 너비를 계산하는 계산 속성
        private
        var columnWidth: CGFloat {
            // 행 갯수 - 1 (총 인덱스) * 아이템 간격
            let spacing = (numberOfColumns - 1) * interItemSpacing
            // 전체 컬렉션뷰 넓이에서 간격을 제거 -> 행 갯수를 나눔 -> 하나의 행 넓이
            return (collectionWidth - spacing) / numberOfColumns
        }
        
        /// 특정 아이템의 프레임을 계산하는 메서드에요
        private
        func frame(for row: Int) -> CGRect {
            let width = columnWidth // 열의 너비를 가져옵니다
            let height = itemHeightProvider(row, width) // 클로저를 사용하여 아이템의 높이를 계산해요
            let size = CGSize(width: width, height: height) // 계산된 높이와 너비를 통해 사이즈 만들기
            let origin = itemOrigin(width: size.width) // 아이템의 위치를 어디에 할지 계산합니다.
            return CGRect(origin: origin, size: size) // 위치와 사이즈를 통해 REACT ( 사각형 알죠? ) 생성해요
        }
        
        // 행 레이아웃 아이템 생성
        func makeLayoutItem(for row: Int) -> NSCollectionLayoutGroupCustomItem {
            let frame = frame(for: row) // 아이템 프레임을 계산해요
            columnHeights[columnIndex()] = frame.maxY + interItemSpacing // 계산된 프레임 maxY 간격을 더한값을 현재 열의 높이로 설정합니다.
            return NSCollectionLayoutGroupCustomItem(frame: frame)
        }
        
        // 가장 낮은 열의 인덱스를 반환하는 메서드입니다.
        private
        func columnIndex() -> Int {
            columnHeights
                .enumerated() // 인덱스화 했는데..? -> 각 열의 높이, 인덱스를 포함하는 [0:0.0] 시퀀스를 만들어요
                .min(by: { $0.element < $1.element })? .offset ?? 0 // 두 인덱스 튜플에서 더 작은 값을 찾고, 가장 작은 높이값은 같는 튜플을 반환합니당 이때 .offset 은 인덱스를 가져온다는 의미!
            //만약 min(by: _ ) 에서 nil 일때는, 0를 반환 하죠
        }
        
        // item x,y 좌표가 어딘지 계산해주는 메서드에요
        private
        func itemOrigin(width: CGFloat) -> CGPoint {
            let y = columnHeights[columnIndex()].rounded() // 선택된 열의 높이를 반올림 하고, Y좌표로 사용합니다.
            let x = (width + interItemSpacing) * CGFloat(columnIndex()) // 선택된 열의 인덱스를 이용하여 X 좌표를 계산해요
            return CGPoint(x: x, y: y) // 계산된 x, y 좌표를 통해 CGPoint를 생성하여 반환합니다
        }
        /*
         columnHeights[columnIndex()] 의 이해
         만약 [100.0, 200.0, 50.0] 이라고 가정할때,
         가장 낮은값은 50.0 이고 이값은 "2" 인덱스에 위치하기에 "2" 를 반환할것입니다.
         그럼 자연스럽게 columnHeights[columnIndex()].rounded() 는 반올림 하게 되면  50이 되겠죠?
         100이 될것 같겠지만 CGFloat에서의 반올림은 소수점을 반올림 하는 개념이기에 50이 됩니다.
         */
        
        // 모든 열중 가장 높은 높이를 반환해줘요
        fileprivate
        func maxcolumHeight() -> CGFloat {
            // 가장 높은 열의 높이를 받아요
            return columnHeights.max() ?? 0
        }
        
    }
    
    // 지정된 설정, 레이아웃 상태에 따라 컬렉션뷰 섹션의 레이아웃을 생성하는 메서드
    static
    func makeLayoutSection(
        config: Configuration, // 위에서 만든 구조체를 활용
        environment: NSCollectionLayoutEnvironment, // 레이아웃 상태
        sectionIndex: Int // 섹션 인덱스
    ) -> NSCollectionLayoutSection {
        var items: [NSCollectionLayoutGroupCustomItem] = [] // 아이템을 저장할 배열이죠
        let itemProvider = LayoutBuilder(
            configuration: config,
            collectionWidth: environment.container.contentSize.width
        )
        
        for i in 0..<config.itemCountProfider() {
            let item = itemProvider.makeLayoutItem(for: i) // 아이템 별 레이아웃 생성
            items.append(item) // 생성된 레이아웃 아이템을 배열에 추가할 거에요
        }
        
        let groupLayoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1), // 그룹에 너비는 컨테이너의 전체 너비
            heightDimension: .absolute(itemProvider.maxcolumHeight()) // 그룹의 높이는 가장 높은 열의 높이를 사용
        )
        
        let group = NSCollectionLayoutGroup.custom(
            layoutSize: groupLayoutSize) { _ in // 레이아웃 그룹 생성후, 설정된 아이템 배열을 반환해요
                return items
            }
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsetsReference = config.contentInsetsReference // 색션 여백 설정
        return section
    }
    
    

}
