//
//  SearchGIFsViewController.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import UIKit
import Combine
import CombineCocoa

final class SearchGIFsViewController: UIViewController {
        
    // MARK: - UI properties
    
    private let searchController: UISearchController = .init()
    private let collectionView: UICollectionView = .make()

    // MARK: - Helper properties
        
    private var cancellable: Set<AnyCancellable> = []
    private let dataSource: SingleSectionCollectionViewDataSource<DefaultGIFCellViewModel>
    
    // MARK: - Dependencies
    
    private let viewModel: SearchGIFsViewModel
    
    // MARK: - Constructors
    
    init(viewModel: SearchGIFsViewModel) {
        self.viewModel = viewModel
        self.dataSource = .make(collectionView: collectionView)
        self.collectionView.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.searchController = searchController
        navigationItem.title = "Search"
        configureViewHierarchy()
        configureLayout()
        configureSubviews()
        configureInputs()
        configureOutputs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.onAppear.send()
    }
    
    // MARK: - Configuration
    
    private func configureInputs() {
        collectionView.didSelectItemPublisher
            .subscribe(viewModel.inputs.selectedIndexPath)
            .store(in: &cancellable)
        
        collectionView.reachedBottomPublisher()
            .subscribe(viewModel.inputs.reachedBottom)
            .store(in: &cancellable)
        
        searchController.searchBar.textDidChangePublisher
            .mapToOptional()
            .subscribe(viewModel.inputs.search)
            .store(in: &cancellable)
        
        searchController.searchBar.cancelButtonClickedPublisher
            .map { "" }
            .subscribe(viewModel.inputs.search)
            .store(in: &cancellable)
    }
    
    private func configureOutputs() {
        viewModel.outputs.items
            .receive(on: DispatchQueue.main)
            .subscribe(dataSource.snapshotSubscriber(animated: false))
    }
}

// MARK: - Subviews

private extension SearchGIFsViewController {
    func configureSubviews() {
        collectionView.setCollectionViewLayout(.makeWaterfall(itemSizeProvider: dataSource), animated: false)
    }
}

// MARK: - View hierarchy

private extension SearchGIFsViewController {
    func configureViewHierarchy() {
        view.addSubview(collectionView)
    }
}

// MARK: - Layout

private extension SearchGIFsViewController {
    func configureLayout() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Factories

extension UICollectionView {
    static func make() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(GIFCell.self, forCellWithReuseIdentifier: GIFCell.cellIdentifier)
        collectionView.alwaysBounceVertical = true
        return collectionView
    }
}

extension UICollectionViewDiffableDataSource where SectionIdentifierType == SingleSection, ItemIdentifierType == DefaultGIFCellViewModel {
    static func make(collectionView: UICollectionView) -> SingleSectionCollectionViewDataSource<DefaultGIFCellViewModel> {
        return .init(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GIFCell.cellIdentifier, for: indexPath) as? GIFCell
            cell?.configure(with: item)
            return cell
        }
    }
}

protocol WaterfallLayoutItemSizeProvider {
    func sizeForItem(at indexPath: IndexPath) -> CGSize
    func numberOfItems(in section: Int) -> Int
}

extension SingleSectionCollectionViewDataSource: WaterfallLayoutItemSizeProvider where ItemIdentifierType == DefaultGIFCellViewModel {
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard
            let dimensions = itemIdentifier(for: indexPath)?.gif.dimensions,
            let width = dimensions.first,
            let height = dimensions.last
        else {
            return .zero
        }
        return CGSize(width: width, height: height)
    }
    
    func numberOfItems(in section: Int) -> Int {
        return snapshot().itemIdentifiers.count
    }
}
