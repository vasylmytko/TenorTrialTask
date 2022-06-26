//
//  GradientView.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import UIKit

class GradientView: UIView {
    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer? {
        return layer as? CAGradientLayer
    }

    func applyGradientColors(_ colors: [UIColor?]) {
        gradientLayer?.colors = colors.compactMap { $0?.cgColor }
    }
}
