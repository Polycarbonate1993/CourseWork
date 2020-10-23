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
    
    internal enum Mode {
        case tableView
        case collectionView
    }
  // 1
    weak var delegate: PinterestLayoutDelegate?

  // 2
    @IBInspectable
    var numberOfColumns: Int = 3
    
    @IBInspectable
    var cellPadding: CGFloat = 5
    
    var mode: Mode = .collectionView {
        didSet {
            cache = []
            cacheForSupplementaryView = []
        }
    }

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
    }

  // 5
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
  
    override func prepare() {
    // 1
        guard let collectionView = collectionView, collectionView.numberOfSections != 0, cache.isEmpty, cacheForSupplementaryView.isEmpty else {
            return
        }
        cacheForSupplementaryView = []
        cache = []
        contentHeight = 0
    // 2
        if delegate?.collectionView(collectionView, kind: "Header", sizeForTextAtIndexPath: IndexPath(item: 0, section: 0))?.height != nil {
            let supplementaryAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "Header", with: IndexPath(item: 0, section: 0))
            supplementaryAttributes.frame = CGRect(x: 0, y: 0, width: contentWidth, height: delegate?.collectionView(collectionView, kind: "Header", sizeForTextAtIndexPath: IndexPath(item: 0, section: 0))?.height ?? 1)
            cacheForSupplementaryView.append(supplementaryAttributes)
        }
        
        
        switch mode {
        case .collectionView:
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
                    let photoSize = delegate?.collectionView(collectionView, sizeForPhotoAtIndexPath: indexPath) ?? CGSize(width: 1, height: 1)
                    let aspectRatio = photoSize.width / photoSize.height
                    let height = columnWidth / aspectRatio
                    let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = frame
                    cache.append(attributes)
                    contentHeight = max(contentHeight, frame.maxY)
                    yOffset[column] = yOffset[column] + height + cellPadding
                    column = column < (numberOfColumns - 1) ? (column + 1) : 0
                }
        case .tableView:
            let width = collectionView.frame.width - cellPadding * 2
            var yOffset: CGFloat = (cacheForSupplementaryView.isEmpty ? 0 : cacheForSupplementaryView[0].frame.height) + cellPadding
            for item in 0..<collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let cellHeight = delegate?.collectionView(collectionView, sizeForPhotoAtIndexPath: indexPath).height ?? 100
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let frame = CGRect(x: cellPadding, y: yOffset, width: width, height: cellHeight)
                attributes.frame = frame
                cache.append(attributes)
                contentHeight = max(contentHeight, frame.maxY)
                yOffset += cellHeight + cellPadding
            }
        }
        
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        switch mode {
        case .tableView:
            for item in updateItems {
                if item.updateAction == .insert {
                    guard let collectionView = collectionView else {
                        return
                    }
                    let width = collectionView.frame.width - cellPadding * 2
                    let yOffset: CGFloat = (cache.last?.frame.maxY ?? 0) + cellPadding
                    let cellHeight = delegate?.collectionView(collectionView, sizeForPhotoAtIndexPath: item.indexPathAfterUpdate!).height ?? 100
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: item.indexPathAfterUpdate!)
                    let frame = CGRect(x: cellPadding, y: yOffset, width: width, height: cellHeight)
                    attributes.frame = frame
                    attributes.alpha = 1
                    cache.append(attributes)
                    contentHeight = max(contentHeight, frame.maxY)
                }
            }
        case .collectionView:
            let columnWidth = (contentWidth - cellPadding * CGFloat(numberOfColumns + 1)) / CGFloat(numberOfColumns)
            var xOffset: [CGFloat] = []
            for column in 0..<numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth + cellPadding * (CGFloat(column) + 1))
            }
            var yOffset: [CGFloat] = []
            var column: Int = {
                let columnNumber = ((self.cache.last?.frame.minX ?? self.cellPadding) - self.cellPadding)/(columnWidth + self.cellPadding)
                let column = Int(columnNumber)
                return column
            }()
            for i in 0..<numberOfColumns {
                if i < cache.count {
                    if i <= column {
                        let index = cache.endIndex - 1 - column + i
                        yOffset.append(cache[index].frame.maxY + cellPadding)
                    } else {
                        let index = cache.endIndex - 1 - column - numberOfColumns + i
                        yOffset.append(cache[index].frame.maxY + cellPadding)
                    }
                } else {
                    yOffset.append(cellPadding + cacheForSupplementaryView[0].frame.maxY)
                }
            }
            for item in updateItems {
                if item.updateAction == .insert {
                    guard let collectionView = collectionView else {
                        return
                    }
                    column = column < (numberOfColumns - 1) ? (column + 1) : 0
                    let photoSize = delegate?.collectionView(collectionView, sizeForPhotoAtIndexPath: item.indexPathAfterUpdate!) ?? CGSize(width: 1, height: 1)
                    let aspectRatio = photoSize.width / photoSize.height
                    let height = columnWidth / aspectRatio
                    let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: item.indexPathAfterUpdate!)
                    attributes.frame = frame
                    attributes.alpha = 1
                    cache.append(attributes)
                    contentHeight = max(contentHeight, frame.maxY)
                    yOffset[column] = yOffset[column] + height + cellPadding
                }
            }
        }
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if mode == .collectionView {
            let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
            let new = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
            new.frame = attributes!.frame
            new.transform = CGAffineTransform(translationX: 0, y: -500)
            new.alpha = 0
            return new
        }
        return nil
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
    
    func reset() {
        cache.removeAll()
        cacheForSupplementaryView.removeAll()
        prepare()
    }
    
}
