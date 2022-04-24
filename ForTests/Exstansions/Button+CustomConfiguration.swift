//
//  Button+CustomConfiguration.swift
//  ForTests
//
//  Created by Anton on 20/04/2022.
//

import Foundation
import UIKit

extension UIButton.Configuration {
    static func setCustomImage( _ string: String, config: UIButton.Configuration, pointSize: CGFloat, scale: UIImage.SymbolScale) -> UIButton.Configuration {
        var config: UIButton.Configuration = config
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .clear
        let largeConfig = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .bold, scale: scale)
        let image = UIImage(systemName: string,withConfiguration: largeConfig)
        config.image = image
        return config
    }
}
