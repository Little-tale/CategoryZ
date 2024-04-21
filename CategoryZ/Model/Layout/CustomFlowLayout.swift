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
    static var profilePostLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 165, height: 210)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18
        )
        layout.scrollDirection = .vertical
        return layout
    }
    
}

