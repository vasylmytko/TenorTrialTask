//
//  GIFCell.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import UIKit
import SDWebImage

final class GIFCell: UICollectionViewCell {
    
    private let imageView: SDAnimatedImageView = .make()
    private var dataTask: URLSessionDataTask?
    
    var gif: GIF = .placeholder {
        didSet {
            updateViews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
        configureViewHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dataTask?.cancel()
    }
    
    private func updateViews() {
        imageView.sd_setImage(with: gif.url, placeholderImage: nil, options: [.progressiveLoad])
    }
}

// MARK: - Subviews

private extension GIFCell {
    func configureSubviews() {
    }
}

// MARK: - View hierarchy

private extension GIFCell {
    func configureViewHierarchy() {
        contentView.addSubview(imageView)
    }
}

// MARK: - Layout

private extension GIFCell {
    func configureLayout() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: - Factories

private extension SDAnimatedImageView {
    static func make() -> SDAnimatedImageView {
        let imageView = SDAnimatedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}

extension GIF {
    static let placeholder = GIF(id: "", url: .init(fileURLWithPath: ""))
}
