//
//  SearchGIFsViewController.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import UIKit
import Combine
import CombineCocoa

typealias SingleSectionCollectionViewDataSource<T: Hashable> =
    UICollectionViewDiffableDataSource<SingleSection, T>

final class SearchGIFsViewController: UIViewController {
        
    // MARK: - UI properties
    
    private let searchController: UISearchController = .make()
    private let stateInfoView: StateInfoView = .make()
    private let collectionView: UICollectionView = .make()
    private let activityIndicatorView: UIActivityIndicatorView = .make()

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
        
        navigationItem.title = "Search"
        view.backgroundColor = .black
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
    }
    
    private func configureOutputs() {
        viewModel.outputs.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.configureUI(with: state)
            }
            .store(in: &cancellable)
    }
    
    private func configureUI(with state: SearchGIFs.State) {
        switch state {
        case .idle(let stateInfo):
            configureStateView(with: stateInfo)
        case .error(let stateInfo):
            configureStateView(with: stateInfo)
        case .results(let viewModels):
            configureUIForResults(viewModels)
        case .loading:
            configureUIForLoading()
        }
    }
    
    private func configureUIForResults(_ results: [DefaultGIFCellViewModel]) {
        dataSource.reloadWithGIFs(results)
        collectionView.show()
        stateInfoView.hide()
        activityIndicatorView.hide()
    }
    
    private func configureStateView(with stateInfo: StateInfo) {
        stateInfoView.setStateInfo(stateInfo)
        stateInfoView.show()
        collectionView.hide()
        activityIndicatorView.hide()
    }
    
    private func configureUIForLoading() {
        stateInfoView.hide()
        collectionView.hide()
        activityIndicatorView.show()
    }
}

// MARK: - Subviews

private extension SearchGIFsViewController {
    func configureSubviews() {
        collectionView.setCollectionViewLayout(
            .makeWaterfall(configuration: .gifs(itemSizeProvider: dataSource)),
            animated: false
        )
    }
}

// MARK: - View hierarchy

private extension SearchGIFsViewController {
    func configureViewHierarchy() {
        navigationItem.searchController = searchController
        view.addSubview(activityIndicatorView)
        view.addSubview(stateInfoView)
        view.addSubview(collectionView)
    }
}

// MARK: - Layout

private extension SearchGIFsViewController {
    func configureLayout() {
        collectionView.constraintToEdges(of: view.safeAreaLayoutGuide)
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.heightAnchor.constraint(equalTo: activityIndicatorView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stateInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateInfoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stateInfoView.heightAnchor.constraint(equalToConstant: 170),
            stateInfoView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
}

// MARK: - Factories

extension UISearchController {
    static func make() -> UISearchController {
        let searchController = UISearchController()
        searchController.searchBar.returnKeyType = .done
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        return searchController
    }
}

extension UICollectionView {
    static func make() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(GIFCell.self, forCellWithReuseIdentifier: GIFCell.cellIdentifier)
        collectionView.alwaysBounceVertical = true
        return collectionView
    }
}

extension UIActivityIndicatorView {
    static func make() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.isHidden = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
}

extension StateInfoView {
    static func make() -> StateInfoView {
        let stateInfoView = StateInfoView()
        stateInfoView.translatesAutoresizingMaskIntoConstraints = false
        return stateInfoView
    }
}

// MARK: - Helpers

enum SingleSection {
    case main
}

extension UICollectionViewDiffableDataSource where SectionIdentifierType == SingleSection, ItemIdentifierType == DefaultGIFCellViewModel {
    static func make(collectionView: UICollectionView) -> SingleSectionCollectionViewDataSource<DefaultGIFCellViewModel> {
        return .init(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GIFCell.cellIdentifier, for: indexPath) as? GIFCell
            cell?.configure(with: item)
            return cell
        }
    }
    
    func reloadWithGIFs(_ viewModels: [DefaultGIFCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, DefaultGIFCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels, toSection: .main)
        apply(snapshot, animatingDifferences: false)
    }
}

extension SingleSectionCollectionViewDataSource: WaterfallLayoutItemSizeProvider where ItemIdentifierType == DefaultGIFCellViewModel {
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        return itemIdentifier(for: indexPath)?.gif.size ?? .zero
    }
    
    func numberOfItems(in section: Int) -> Int {
        return snapshot().itemIdentifiers.count
    }
}

extension GIF {
    var size: CGSize {
        guard let width = dimensions.first, let height = dimensions.last else {
            return .zero
        }
        return CGSize(width: width, height: height)
    }
}
