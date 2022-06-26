//
//  UITabBarItem+Factories.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import UIKit

extension UITabBarItem {
    static let favourites: UITabBarItem = .init(
        title: "Favourites",
        image: UIImage(systemName: "star.fill"),
        tag: 0
    )
    
    static let search: UITabBarItem = .init(
        title: "Search",
        image: UIImage(systemName: "magnifyingglass"),
        tag: 0
    )
}
