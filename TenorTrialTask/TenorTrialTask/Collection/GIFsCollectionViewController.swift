//
//  GIFsCollectionViewController.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import UIKit
import Combine
import CombineCocoa

final class GIFsCollectionViewController: UIViewController {
        
    // MARK: - UI properties
    
    private let searchController: UISearchController = .init()
    private let collectionView: UICollectionView = .make()

    // MARK: - Helper properties
        
    private var cancellable: Set<AnyCancellable> = []
    private let dataSource: SingleSectionCollectionViewDataSource<GIF>
    
    // MARK: - Dependencies
    
    private let viewModel: GIFsCollectionViewModel
    
    // MARK: - Constructors
    
    init(viewModel: GIFsCollectionViewModel) {
        self.viewModel = viewModel
        self.dataSource = .make(collectionView: collectionView)
        self.collectionView.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.searchController = searchController
        navigationItem.title = "GIFs"
        configureViewHierarchy()
        configureLayout()
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
        collectionView.willDisplayCellPublisher
            .map(\.indexPath)
            .subscribe(viewModel.inputs.indexWillBeDisplayed)
            .store(in: &cancellable)
        
        collectionView.didSelectItemPublisher
            .subscribe(viewModel.inputs.selectedIndexPath)
            .store(in: &cancellable)
        
        searchController.searchBar.textDidChangePublisher
            .map { Optional($0) }
            .subscribe(viewModel.inputs.search)
            .store(in: &cancellable)
    }
    
    private func configureOutputs() {
        viewModel.outputs.snapshot
            .receive(on: DispatchQueue.main)
            .subscribe(dataSource.snapshotSubscriber(animated: true))
    }
}

// MARK: - View hierarchy

private extension GIFsCollectionViewController {
    func configureViewHierarchy() {
        view.addSubview(collectionView)
    }
}

// MARK: - Layout

private extension GIFsCollectionViewController {
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
        layout.itemSize = .init(width: 180, height: 180)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GIFCell.self, forCellWithReuseIdentifier: GIFCell.cellIdentifier)
        collectionView.alwaysBounceVertical = true
        return collectionView
    }
}

extension UICollectionViewDiffableDataSource where SectionIdentifierType == SingleSection, ItemIdentifierType == GIF {
    static func make(collectionView: UICollectionView) -> SingleSectionCollectionViewDataSource<GIF> {
        return .init(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GIFCell.cellIdentifier, for: indexPath) as? GIFCell
            cell?.gif = item
            return cell
        }
    }
}
