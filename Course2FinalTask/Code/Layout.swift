//
//  Layout.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 28.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize
    func collectionView(_ collectionView: UICollectionView, kind: String, sizeForTextAtIndexPath indexPath: IndexPath) -> CGSize?
}

class PinterestLayout: UICollectionViewLayout {
  // 1
    weak var delegate: PinterestLayoutDelegate?

  // 2
    private let numberOfColumns = 3
    private let cellPadding: CGFloat = 5

  // 3
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var cacheForSupplementaryView: [UICollectionViewLayoutAttributes] = []

  // 4
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
//        return collectionView.bounds.width
    }

  // 5
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
  
    override func prepare() {
    // 1
        guard let collectionView = collectionView, collectionView.numberOfSections != 0 else {
            return
        }
        cacheForSupplementaryView = []
        cache = []
    // 2
        if let supplementaryViewHeight = delegate?.collectionView(collectionView, kind: "Header", sizeForTextAtIndexPath: IndexPath(item: 0, section: 0))?.height {
            let supplementaryAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "Header", with: IndexPath(item: 0, section: 0))
            supplementaryAttributes.frame = CGRect(x: 0, y: 0, width: contentWidth, height: delegate?.collectionView(collectionView, kind: "Header", sizeForTextAtIndexPath: IndexPath(item: 0, section: 0))?.height ?? 100)
            cacheForSupplementaryView.append(supplementaryAttributes)
        }
        
        let columnWidth = (contentWidth - cellPadding * CGFloat(numberOfColumns + 1)) / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth + cellPadding * (CGFloat(column) + 1))
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: (cacheForSupplementaryView.isEmpty ? 0 : cacheForSupplementaryView[0].frame.height) + cellPadding, count: numberOfColumns)
      
    // 3
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
        
      // 4
            let photoSize = delegate?.collectionView(collectionView, sizeForPhotoAtIndexPath: indexPath) ?? CGSize(width: 1, height: 1)
            let aspectRatio = photoSize.width / photoSize.height
            let height = columnWidth / aspectRatio
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
      // 5
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
        
      // 6
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height + cellPadding
        
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
  
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        for attributes in cacheForSupplementaryView {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes.isEmpty ? nil : visibleLayoutAttributes
    }
  
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.isEmpty ? nil : cache[indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cacheForSupplementaryView.isEmpty ? nil : cacheForSupplementaryView[indexPath.item]
    }
}
