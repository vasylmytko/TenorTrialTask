//
//  LayoutItemProvider.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import UIKit

protocol WaterfallLayoutItemSizeProvider {
    func sizeForItem(at indexPath: IndexPath) -> CGSize
    func numberOfItems(in section: Int) -> Int
}

class LayoutItemProvider {
    private let columnCount: CGFloat
    private let itemSizeProvider: WaterfallLayoutItemSizeProvider
    private let spacing: CGFloat
    private let contentSize: CGSize
    private(set) var columnHeights: [CGFloat]

    init(
        configuration: WaterfallLayoutConfiguration,
        environment: NSCollectionLayoutEnvironment
    ) {
        self.columnHeights = [CGFloat](repeating: 0, count: configuration.columnCount)
        self.columnCount = CGFloat(configuration.columnCount)
        self.itemSizeProvider = configuration.itemSizeProvider
        self.spacing = configuration.spacing
        self.contentSize = environment.container.effectiveContentSize
    }
    
    func item(for indexPath: IndexPath) -> NSCollectionLayoutGroupCustomItem {
        let frame = frame(for: indexPath)
        columnHeights[columnIndex()] = frame.maxY + spacing
        return NSCollectionLayoutGroupCustomItem(frame: frame)
    }
    
    private func frame(for indexPath: IndexPath) -> CGRect {
        let size = itemSize(for: indexPath)
        let origin = itemOrigin(width: size.width)
        return CGRect(origin: origin, size: size)
    }
    
    private func itemOrigin(width: CGFloat) -> CGPoint {
        let y = columnHeights[columnIndex()].rounded()
        let x = (width + spacing) * CGFloat(columnIndex())
        return CGPoint(x: x, y: y)
    }
    
    private func itemSize(for indexPath: IndexPath) -> CGSize {
        let width = itemWidth()
        let height = itemHeight(for: indexPath, itemWidth: width)
        return CGSize(width: width, height: height)
    }
    
    private func itemWidth() -> CGFloat {
        let spacing = (columnCount - 1) * spacing
        return (contentSize.width - spacing) / columnCount
    }
    
    private func itemHeight(for indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        let size = itemSizeProvider.sizeForItem(at: indexPath)
        let aspectRatio = size.height / size.width
        let itemHeight = itemWidth * aspectRatio
        return itemHeight.rounded()
    }
    
    private func columnIndex() -> Int {
        columnHeights
            .enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }
}
