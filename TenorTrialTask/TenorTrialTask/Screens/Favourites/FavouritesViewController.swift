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
        configureSubviews()
        configureViewHierarchy()
        configureLayout()
        configureBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onLoad.send()
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
        collectionView.setCollectionViewLayout(
            .makeWaterfall(configuration: .gifs(itemSizeProvider: self)),
            animated: false
        )
        collectionView.dataSource = self
    }
}

extension FavouritesViewController: WaterfallLayoutItemSizeProvider {
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        return viewModel.itemAt(indexPath: indexPath)?.gif.size ?? .zero
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
        collectionView.constraintToEdges(of: view)
    }
}
