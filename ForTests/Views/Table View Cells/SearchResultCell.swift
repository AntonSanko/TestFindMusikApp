//
//  SearchResultCell.swift
//  ForTests
//
//  Created by Anton on 19/04/2022.
//
import UIKit

class SearchResultCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!

  var downloadTask: URLSessionDownloadTask?

  override func awakeFromNib() {
    super.awakeFromNib()
      artworkImageView.layer.cornerRadius = 5
      accessoryType = .disclosureIndicator
  }

  override func prepareForReuse() {
      
    super.prepareForReuse()
    downloadTask?.cancel()
    downloadTask = nil
  }
    
    func configure(for result: Track) {
        nameLabel.text = result.name
        artistNameLabel.text = result.artist 
        artworkImageView.image = UIImage(systemName: "square")
        guard let url = result.artworkUrl60 else { return }
        downloadTask = artworkImageView.loadImage(url: url)
    }
}
