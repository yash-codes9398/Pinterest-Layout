//
//  PinterestLayout.swift
//  Pinterest Layout
//
//  Created by Yash Shah on 13/03/22.
//

import Foundation
import UIKit

public protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView,
                        heightForCellAtIndexPath indexPath: IndexPath,
                        withCellWidth width: CGFloat) -> CGFloat
}

public final class PinterestLayout: UICollectionViewLayout {
    
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let numberOfColumns: Int
    private var layoutAttributesCache: [Int: [UICollectionViewLayoutAttributes]] = [:]
    public weak var delegate: PinterestLayoutDelegate?
    
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return .zero }
        let inset = collectionView.contentInset
        return collectionView.frame.width - inset.left - inset.right
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    public init(withNumberOfColumns columns: Int,
                horizontalSpacing: CGFloat,
                verticalSpacing: CGFloat) {
        numberOfColumns = columns
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepare() {
        guard layoutAttributesCache.isEmpty,
              numberOfColumns > 0,
              let collectionView = collectionView else { return }
        // Available width for content
        let availableWidth = contentWidth - CGFloat((numberOfColumns - 1))*horizontalSpacing
        // Width of item in each column
        let columnWidth = availableWidth/CGFloat(numberOfColumns)
        
        // Offset of each column
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * (columnWidth + horizontalSpacing))
        }
        
        var column: Int = 0
        var yOffset: [CGFloat] = .init(repeating: .zero, count: numberOfColumns)
        
        for section in 0..<collectionView.numberOfSections {
            layoutAttributesCache[section] = []
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let cellHeight: CGFloat = delegate?.collectionView(collectionView,
                                                                   heightForCellAtIndexPath: IndexPath(item: item, section: section),
                                                                   withCellWidth: columnWidth) ?? .zero
                let frame = CGRect(x: xOffset[column],
                                   y: yOffset[column],
                                   width: columnWidth,
                                   height: cellHeight)
                
                let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: section))
                layoutAttributes.frame = frame
                layoutAttributesCache[section]?.append(layoutAttributes)
                
                contentHeight = max(contentHeight, frame.maxY + verticalSpacing)
                yOffset[column] = frame.maxY + verticalSpacing
                
                column = (column + 1)%numberOfColumns
            }
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for section in layoutAttributesCache.keys {
            let filteredAttributes: [UICollectionViewLayoutAttributes] = layoutAttributesCache[section]?.filter({ $0.frame.intersects(rect) }) ?? []
            visibleLayoutAttributes.append(contentsOf: filteredAttributes)
        }
        
        return visibleLayoutAttributes
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesCache[indexPath.section]?[indexPath.item]
    }
    
    public func sizeForItem(atIndexPath indexPath: IndexPath) -> CGSize? {
        guard let width = layoutAttributesForItem(at: indexPath)?.frame.width,
              let height = layoutAttributesForItem(at: indexPath)?.frame.height else { return nil }
        return CGSize(width: width, height: height)
    }
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        layoutAttributesCache.removeAll()
    }
}
