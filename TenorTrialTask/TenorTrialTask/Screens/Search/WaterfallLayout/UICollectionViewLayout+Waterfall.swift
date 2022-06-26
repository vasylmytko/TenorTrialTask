//
//  UICollectionViewLayout+Waterfall.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 25.06.2022.
//

import UIKit

extension UICollectionViewLayout {
    static func makeWaterfall(configuration: WaterfallLayoutConfiguration) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { section, environment in
            let itemProvider = LayoutItemProvider(configuration: configuration, environment: environment)
            let items: [NSCollectionLayoutGroupCustomItem] = Array(0..<configuration.itemSizeProvider.numberOfItems(in: section))
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
    }
}

extension WaterfallLayoutConfiguration {
    static func gifs(itemSizeProvider: WaterfallLayoutItemSizeProvider) -> WaterfallLayoutConfiguration {
        return WaterfallLayoutConfiguration(
            columnCount: 2,
            spacing: 8,
            contentInsetsReference: .automatic,
            itemSizeProvider: itemSizeProvider
        )
    }
}
  
