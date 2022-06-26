//
//  StateView.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 25.06.2022.
//

import UIKit

final class StateInfoView: UIView {
    private let imageView: UIImageView = .make()
    private let messageLabel: UILabel = .make()
    
    init() {
        super.init(frame: .zero)
        
        configureViewHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStateInfo(_ stateInfo: StateInfo) {
        imageView.image = stateInfo.icon
        messageLabel.text = stateInfo.message
    }
}

extension StateInfoView {
    func configureViewHierarchy() {
        addSubview(imageView)
        addSubview(messageLabel)
    }
}

extension StateInfoView {
    func configureLayout() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
}

private extension UIImageView {
    static func make() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}

private extension UILabel {
    static func make() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

struct StateInfo {
    let icon: UIImage?
    let message: String
}

extension StateInfo {
    static let errorInfo = StateInfo(
        icon: UIImage(systemName: "magnifyingglass"),
        message: "Type text in search bar"
    )
    
    static let idleInfo = StateInfo(
        icon: UIImage(systemName: "xmark"),
        message: "Error occured while fetching gifs"
    )
}
