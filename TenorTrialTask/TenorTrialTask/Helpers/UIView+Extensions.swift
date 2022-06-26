//
//  UIViewExtensions.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import UIKit

extension UIView {
    func constraintToEdges(of view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func constraintToEdges(of layoutGuide: UILayoutGuide) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)
        ])
    }
    
    func hide() {
        isHidden = true
    }
    
    func show() {
        isHidden = false
    }
}
