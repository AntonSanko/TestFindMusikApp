//
//  CustomButton.swift
//  ForTests
//
//  Created by Anton on 28/05/2022.
//

import UIKit.UIButton

class CustomButton {
    static func createMathButton() -> UIButton {
        let button = UIButton()
        button.configuration = .setCustomImage("mic.circle.fill", config: .tinted(), pointSize: 80, scale: .large)
        return button
    }
    static func createMyMusicButton() -> UIButton {
        let button = UIButton()
        button.configuration = .setCustomImage("music.note.list", config: .tinted(), pointSize: 40, scale: .large)
        return button
    }
    static func createSearchButton() -> UIButton {
        let button = UIButton()
        button.configuration = .setCustomImage("text.magnifyingglass", config: .tinted(), pointSize: 40, scale: .large)
        return button
    }
    static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.configuration = .setCustomImage("xmark", config: .tinted(), pointSize: 30, scale: .small)
        button.configuration?.title = "Cancel"
        button.configuration?.attributedTitle?.font = UIFont.boldSystemFont(ofSize: 25)
        button.configuration?.imagePadding = 5
        button.alpha = 0
        return button
    }
}
