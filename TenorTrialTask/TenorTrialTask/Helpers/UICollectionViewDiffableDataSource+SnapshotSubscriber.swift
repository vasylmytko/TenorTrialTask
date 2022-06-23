//
//  UICollectionViewDiffableDataSource+SnapshotSubscriber.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 22.06.2022.
//

import UIKit
import Combine

extension UICollectionViewDiffableDataSource where SectionIdentifierType == SingleSection {
    func snapshotSubscriber(
        animated: Bool = true
    ) -> SingleSectionCollectionViewSnapshotSubscriber<ItemIdentifierType> {
        return SingleSectionCollectionViewSnapshotSubscriber(dataSource: self, animated: animated)
    }
}

typealias SingleSectionCollectionViewDataSource<T: Hashable> =
    UICollectionViewDiffableDataSource<SingleSection, T>

final class SingleSectionCollectionViewSnapshotSubscriber<T: Hashable>: Subscriber {

    typealias Input = [T]
    typealias Failure = Never

    private let dataSource: SingleSectionCollectionViewDataSource<T>
    private let animated: Bool

    init(dataSource: SingleSectionCollectionViewDataSource<T>,
         animated: Bool) {
        self.dataSource = dataSource
        self.animated = animated
    }

    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, T>()
        snapshot.appendSections([.main])
        snapshot.appendItems(input, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animated)
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Never>) { }
}
