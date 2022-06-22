//
//  FavouritesViewController.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 19.06.2022.
//

import UIKit
import CoreData

final class FavouritesViewController: UIViewController {
    
    private let collectionView: UICollectionView = .make()
    private var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>?
    
    private let viewModel: FavouritesViewModel
    
    init(viewModel: FavouritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        configureViewHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FavouritesViewController {
    func configureViewHierarchy() {
        view.addSubview(collectionView)
    }
}

extension FavouritesViewController {
    func configureLayout() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
