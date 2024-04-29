//
//  CustomFlowLayout.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/15/24.
//

import UIKit

final class CustomFlowLayout {
    
    static var postLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .horizontal
        return layout
    }
    
    static var imagesLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        layout.scrollDirection = .horizontal
        return layout
    }
//    static var profilePostLayout: UICollectionViewFlowLayout {
//        
//    }
    
}

final class CustomCollectionViewLayout {
//    
    static func settingCollectionViewLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let compositionalLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return compositionalLayout
    }
}


enum CustomProfileCollectionViewLayout {
   
    static func createProfileLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 3,
            leading: 3,
            bottom: 3,
            trailing: 3
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(280)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    static func createProfilePosterLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalWidth(1/3)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(120)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(72)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.pinToVisibleBounds = true
        section.supplementaryContentInsetsReference = .none
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
}
