//
//  MusicCollectionCell.swift
//  ForTests
//
//  Created by Anton on 22/04/2022.
//

import UIKit

class MusicCollectionCell: UICollectionViewCell {
    static let identifier = "musicCollection"
    
    // MARK: -  Properties
    var downloadTask: URLSessionDownloadTask?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        constraintLabels()
        imageView.frame.size.width = contentView.bounds.width
        imageView.frame.size.height = contentView.bounds.height * 0.7
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    // MARK: - Config
    func configureCell(for track: MyTrack) {
        nameLabel.text = track.name
        artistLabel.text = track.artist
        
        imageView.image = UIImage(named: "music")
        guard let url = track.artworkUrl else { return }
        downloadTask = imageView.loadImage(url: url)
        
    }
    
    private func setupContentView() {
        contentView.backgroundColor = UIColor(named: "BackgroundColor")
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 5
        contentView.layer.borderWidth = 0.1
        contentView.layer.borderColor = UIColor.white.cgColor
    }
    // MARK: - Constraints
    private func constraintLabels() {
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 3),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.widthAnchor.constraint(equalToConstant: contentView.bounds.width),
            nameLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        contentView.addSubview(artistLabel)
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            artistLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            artistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            artistLabel.widthAnchor.constraint(equalToConstant: contentView.bounds.width),
            artistLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
}
