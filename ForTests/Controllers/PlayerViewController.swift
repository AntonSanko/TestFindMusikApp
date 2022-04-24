//
//  PlayerViewController.swift
//  ForTests
//
//  Created by Anton on 19/04/2022.
//

import UIKit
import AVFoundation
// TODO: - Player don't play on a phone
class PlayerViewController: UIViewController {
    
    enum StateOfPlayButton {
        case play
        case pause
    }
    // MARK: - Variables And Properties
    var downloadTask: URLSessionDownloadTask?
    let gradient = CAGradientLayer()
    var player: AVAudioPlayer?
    let playButton = UIButton()
    let shareButton = UIButton()
    let closeButton = UIButton()
    let imageView = UIImageView()
    var track: Track?
    var stateOfPlayButton = StateOfPlayButton.play
    let activityIndicator = UIActivityIndicatorView(style: .large)
    var state = false
 
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        return label
    }()
    let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        return label
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLabels()
        setImageView()
        setGradient()
        configureShareButton()
        configureCloseButton()
        configurePlayButton()
        addLabelsConstraints()
        playButton.isHidden = state
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let player = player else { return }
        player.stop()
    }
    
    deinit {
        downloadTask?.cancel()
    }
    // MARK: - Private Methods
    private func setLabels() {
        artistLabel.text = track?.artist ?? "Unknown"
        nameLabel.text = track?.name ?? ""
    }
    private func setImageView() {
        imageView.image = UIImage(named: "music")
        if let imageUrl = track?.artworkUrl100 {
            downloadTask?.cancel()
            downloadTask = imageView.loadImage(url: imageUrl)
            imageView.contentMode = .scaleToFill
        }
        imageView.frame.size = CGSize(width: view.bounds.width, height: view.bounds.height * 0.6)
        imageView.frame.origin = CGPoint(x: 0, y: 0 )
        view.addSubview(imageView)
    }
    private func setGradient() {
        gradient.frame = view.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor,UIColor(named: "BackgroundColor")!.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.locations = [0.4, 0.55, 1]
        view.layer.addSublayer(gradient)
    }
    // MARK: - Share Button
    private func configureShareButton() {
        shareButton.configuration = .setCustomImage("square.and.arrow.up", config: .filled(), pointSize: 20, scale: .medium)
        shareButton.configuration?.baseBackgroundColor = .systemGray
        shareButton.configuration?.cornerStyle = .capsule
        shareButton.alpha = 0.5
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        addShareButtonConstraints()
    }
    @objc func share() {
        guard let url = track?.trackViewURL else { return }
        let actItem:[URL] = [url]
        let avc = UIActivityViewController(activityItems: actItem, applicationActivities: nil)
        present(avc, animated: true, completion: nil)
    }
    // MARK: - Close Button
    private func configureCloseButton() {
        closeButton.configuration = .setCustomImage("chevron.down", config: .filled(), pointSize: 20, scale: .medium)
        closeButton.configuration?.baseBackgroundColor = .systemGray
        closeButton.configuration?.cornerStyle = .capsule
        closeButton.alpha = 0.5
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        addCloseButtonConstraints()
    }
    @objc func close() {
        downloadTask?.cancel()
        dismiss(animated: true)
    }
    // MARK: - Play Button
    private func configurePlayButton() {
        playButton.configuration = .setCustomImage("play.circle.fill", config: .tinted(), pointSize: 50, scale: .large)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        addPlayButtonConstraints()
    }
    @objc func play() {
        guard let track = track else { return }

        switch stateOfPlayButton {
        case .play:
            startActivityIndicator()
            playButton.isHidden = true
            guard let url = track.previewURL else { return }
            downloadTask = .downloadData(url: url) {[weak self] data in
                guard let self = self else { return }
                self.stopActivityIndicator()
                self.playButton.isHidden = false
                self.stateOfPlayButton = .pause
                self.configurePlayer(data: data)
                self.playButton.configuration = .setCustomImage("pause.circle.fill", config: .tinted(), pointSize: 50, scale: .large)
            }
        case .pause:
            if let player = player, player.isPlaying {
                playButton.configuration = .setCustomImage("play.circle.fill", config: .tinted(), pointSize: 50, scale: .large)
                player.pause()
            } else {
                playButton.configuration = .setCustomImage("pause.circle.fill", config: .tinted(), pointSize: 50, scale: .large)
                player?.play()
            }
        }
    }
    private func startActivityIndicator() {
        activityIndicator.center = playButton.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    private func stopActivityIndicator () {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    private func configurePlayer(data: Data) {
        do {
            player = try AVAudioPlayer(data: data )
            player?.delegate = self
            guard let player = player else { return }
            player.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Constraints
    private func addPlayButtonConstraints() {
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: 70),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    private func addShareButtonConstraints() {
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareButton.centerYAnchor.constraint(equalTo: view.topAnchor,constant: 80),
            shareButton.widthAnchor.constraint(equalToConstant: 40),
            shareButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    private func addCloseButtonConstraints() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.centerYAnchor.constraint(equalTo: view.topAnchor,constant: 80),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    private func addLabelsConstraints() {
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 40),
            nameLabel.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.6),
            nameLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
        view.addSubview(artistLabel)
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            artistLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            artistLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            artistLabel.widthAnchor.constraint(equalToConstant: view.bounds.width),
            artistLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
    // MARK: - AVAudioPlayerDelegate
extension PlayerViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("delegate stop")
        playButton.configuration = .setCustomImage("play.circle.fill", config: .tinted(), pointSize: 50, scale: .large)
    }
}
    

