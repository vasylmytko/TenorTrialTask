//
//  GIFCell.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import UIKit
import SDWebImage

final class GIFCell: UICollectionViewCell {
    
    static let cellIdentifier = "gifCell"
    
    private let imageView: SDAnimatedImageView = .make()
    private let favouriteIcon: UIImageView = .makeFavourite()
    
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
        favouriteIcon.isHidden = !gif.isFavourite
    }
}

// MARK: - Subviews

private extension GIFCell {
    func configureSubviews() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}

// MARK: - View hierarchy

private extension GIFCell {
    func configureViewHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(favouriteIcon)
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
        
        NSLayoutConstraint.activate([
            favouriteIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            favouriteIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            favouriteIcon.widthAnchor.constraint(equalToConstant: 30),
            favouriteIcon.heightAnchor.constraint(equalTo: favouriteIcon.widthAnchor)
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

private extension UIImageView {
    static func makeFavourite() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.isHidden = true
        imageView.tintColor = .systemYellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}

extension GIF {
    static let placeholder = GIF(
        id: "",
        url: .init(fileURLWithPath: ""),
        dimensions: [],
        isFavourite: false
    )
}

public protocol HashableByID: Hashable, Identifiable { }

extension HashableByID {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
