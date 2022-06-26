//
//  WaterfallLayoutConfiguration.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import UIKit

public struct WaterfallLayoutConfiguration {
    let columnCount: Int
    let spacing: CGFloat
    let contentInsetsReference: UIContentInsetsReference
    let itemSizeProvider: WaterfallLayoutItemSizeProvider
        
    init(
        columnCount: Int = 2,
        spacing: CGFloat = 8,
        contentInsetsReference: UIContentInsetsReference = .automatic,
        itemSizeProvider: WaterfallLayoutItemSizeProvider
    ) {
        self.columnCount = columnCount
        self.spacing = spacing
        self.contentInsetsReference = contentInsetsReference
        self.itemSizeProvider = itemSizeProvider
    }
}
