//
//  WaterfallLayout.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 25.06.2022.
//

import UIKit

public typealias UICollectionViewWaterfallLayoutItemSizeProvider = (IndexPath) -> (w: CGFloat, h: CGFloat)

public struct UICollectionLayoutWaterfallConfiguration {
    
    public let columnCount: Int
    public let spacing: CGFloat
    public let contentInsetsReference: UIContentInsetsReference
    public let itemSizeProvider: UICollectionViewWaterfallLayoutItemSizeProvider
        
    public init(
        columnCount: Int = 2,
        spacing: CGFloat = 8,
        contentInsetsReference: UIContentInsetsReference = .automatic,
        itemSizeProvider: @escaping UICollectionViewWaterfallLayoutItemSizeProvider
    ) {
        self.columnCount = columnCount
        self.spacing = spacing
        self.contentInsetsReference = contentInsetsReference
        self.itemSizeProvider = itemSizeProvider
    }
}

class LayoutItemProvider {
    private let columnCount: CGFloat
    private let itemSizeProvider: UICollectionViewWaterfallLayoutItemSizeProvider
    private let spacing: CGFloat
    private let contentSize: CGSize
    var columnHeights: [CGFloat]

    init(
        configuration: UICollectionLayoutWaterfallConfiguration,
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
        let (w, h) = itemSizeProvider(indexPath)
        let aspectRatio = h / w
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

extension UICollectionViewCompositionalLayout {
    static func makeWaterfall(configuration: UICollectionLayoutWaterfallConfiguration) -> UICollectionViewCompositionalLayout {
        var numberOfItems: (Int) -> Int = { _ in 0 }
            
        let layout = UICollectionViewCompositionalLayout { section, environment in
            let itemProvider = LayoutItemProvider(configuration: configuration, environment: environment)
            let items: [NSCollectionLayoutGroupCustomItem] = Array(0..<numberOfItems(section))
                .map { itemProvider.item(for: IndexPath(item: $0, section: section)) }
            let heightFraction = (itemProvider.columnHeights.max() ?? 0) / environment.container.contentSize.height
            
            let groupLayoutSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(heightFraction)
            )
            
            let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { _ in
                return items
            }
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsetsReference = configuration.contentInsetsReference
            return section
        }
        
        numberOfItems = { [weak layout] in
            layout?.collectionView?.numberOfItems(inSection: $0) ?? 0
        }
        
        return layout
    }
}
