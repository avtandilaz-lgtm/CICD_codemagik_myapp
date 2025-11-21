//
//  UIImage+SFSymbol.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import UIKit

extension UIImage {
    static func from(systemName: String, pointSize: CGFloat, weight: SymbolWeight = .regular, color: UIColor = .white) -> UIImage? {
        let config = SymbolConfiguration(pointSize: pointSize, weight: weight)
        return UIImage(systemName: systemName, withConfiguration: config)?.withTintColor(color, renderingMode: .alwaysOriginal)
    }
}

