//
//  GIFsCollectionViewController.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import UIKit
import Combine

final class GIFsCollectionViewController: UIViewController {
    
    private let cellIdentifier = "cellIdentifier"
    private let spacing: CGFloat = 10
    private var cancellable: Set<AnyCancellable> = []
    
    private let searchController: UISearchController = .init()
    
    private var items: [GIF] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Properties
    
    private let viewModel: GIFsCollectionViewModel
    
    // MARK: - UI properties
    
    private let collectionView: UICollectionView = .make()
    
    // MARK: - Constructors
    
    init(viewModel: GIFsCollectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        navigationItem.title = "GIFs"
        configureSubviews()
        configureViewHierarchy()
        configureLayout()
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
    
    private func configureOutputs() {
        viewModel.outputs.items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &cancellable)
    }
}

// MARK: - SearchControllerDelegate

extension GIFsCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.inputs.search.send(searchController.searchBar.text)
    }
}

// MARK: - UICollectionViewDataSource

extension GIFsCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->  UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        guard let gifCell = cell as? GIFCell else {
            return cell
        }
        gifCell.gif = items[indexPath.item]
        return gifCell
    }
}

// MARK: - UICollectionViewDelegate

extension GIFsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: (collectionView.frame.width / 2) - spacing * 2, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.inputs.indexWillBeDisplayed.send(indexPath)
    }
}

// MARK: - Subviews

private extension GIFsCollectionViewController {
    func configureSubviews() {
        collectionView.register(GIFCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
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

private extension UICollectionView {
    static func make() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }
}
