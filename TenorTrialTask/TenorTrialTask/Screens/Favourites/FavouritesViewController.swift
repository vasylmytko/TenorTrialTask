//
//  FavouritesViewController.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 19.06.2022.
//

import UIKit
import CoreData
import Combine

final class FavouritesViewController: UIViewController {
    
    private let collectionView: UICollectionView = .make()
    private let viewModel: FavouritesViewModel
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(viewModel: FavouritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = "Favourites"
        configureViewHierarchy()
        configureLayout()
        configureSubviews()
        configureBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBindings() {
        viewModel.dataReloaded
            .sink { [weak self] in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellable)
    }
}

extension FavouritesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GIFCell.cellIdentifier, for: indexPath)
        guard
            let gifCell = cell as? GIFCell,
            let gifCellViewModel = viewModel.itemAt(indexPath: indexPath)
        else {
            return cell
        }
        gifCell.configure(with: gifCellViewModel)
        return gifCell
    }
}

extension FavouritesViewController {
    func configureSubviews() {
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(.makeWaterfall(itemSizeProvider: self), animated: false)
    }
}

extension FavouritesViewController: WaterfallLayoutItemSizeProvider {
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard
            let dimensions = viewModel.itemAt(indexPath: indexPath)?.gif.dimensions,
            let width = dimensions.first,
            let height = dimensions.last
        else {
            return .zero
        }
        return CGSize(width: width, height: height)
    }
    
    func numberOfItems(in section: Int) -> Int {
        return viewModel.numberOfItems
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
