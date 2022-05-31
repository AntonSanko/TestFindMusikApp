//
//  PlayerView.swift
//  ForTests
//
//  Created by Anton on 28/05/2022.
//

import UIKit

class PlayerView: UIView {
    // MARK: -  Properties
    public let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        return label
    }()
    public let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = UIColor.lightGray
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        return label
    }()
    public let imageView = UIImageView()
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    private let gradient = CAGradientLayer()
    public let activityIndicator = UIActivityIndicatorView(style: .large)
    // MARK: - LifeCycle
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        setImageView()
        setGradient()
        addLabelsConstraints()
    }
    // MARK: - Private Methods
    private func setImageView() {
        imageView.image = UIImage(named: "music")
        imageView.frame.size = CGSize(width: bounds.width, height: bounds.height * 0.6)
        imageView.frame.origin = CGPoint(x: 0, y: 0 )
        addSubview(imageView)
    }
    private func setGradient() {
        gradient.frame = bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor,UIColor(named: "BackgroundColor")!.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.locations = [0.4, 0.55, 1]
        layer.addSublayer(gradient)
    }
    private func addLabelsConstraints() {
        addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        let width = self.frame.width - 20
        nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
        artistLabel.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
        stackView.addArrangedSubview(artistLabel)
        stackView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 20, bottom: 200, right: 20))
        layoutIfNeeded()
    }
    public func startActivityIndicator() {
        
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    public func stopActivityIndicator () {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
