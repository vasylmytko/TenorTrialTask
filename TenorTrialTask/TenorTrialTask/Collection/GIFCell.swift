//
//  GIFCell.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 17.06.2022.
//

import UIKit

final class GIFCell: UICollectionViewCell {
    
    private let imageView: UIImageView = .make()
    
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
    
    private func updateViews() {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: self.gif.url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            } catch let error {
                print(error)
            }
        }
    }
}

// MARK: - Subviews

private extension GIFCell {
    func configureSubviews() {
        contentView.backgroundColor = .yellow
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

private extension UIImageView {
    static func make() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
}

extension GIF {
    static let placeholder = GIF(id: "", url: .init(fileURLWithPath: ""))
}
