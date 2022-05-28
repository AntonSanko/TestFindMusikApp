//
//  PlayerViewController.swift
//  ForTests
//
//  Created by Anton on 19/04/2022.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    private enum StateOfPlayButton {
        case play
        case pause
    }
    // MARK: - Variables And Properties
    private var downloadTask: URLSessionDownloadTask?
    private var player: AVAudioPlayer?
    private var playButton = CustomButton.createPlayButton()
    private let shareButton = CustomButton.createShareButton()
    private let closeButton = CustomButton.createCloseButton()
    var track: Track?
    private var stateOfPlayButton = StateOfPlayButton.play
    public var state = false
    private var playerView: PlayerView! {
        guard isViewLoaded else { return nil }
        return (view as! PlayerView)
    }
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
        setImageView()
        playButton.isHidden = state
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let player = player else { return }
        player.stop()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setButtons()
    }
    // MARK: - Methods
    private func setLabels() {
        playerView.artistLabel.text = track?.artist ?? "Unknown"
        playerView.nameLabel.text = track?.name ?? ""
    }
    private func setImageView() {
        if let imageUrl = track?.artworkUrl100 {
            downloadTask?.cancel()
            downloadTask = playerView.imageView.loadImage(url: imageUrl)
            playerView.imageView.contentMode = .scaleToFill
        }
    }
    // MARK: -  Buttons
    private func setButtons() {
        shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        addConstraintButtons()
    }
    @objc private func share() {
        guard let url = track?.trackViewURL else { return }
        let actItem:[URL] = [url]
        let avc = UIActivityViewController(activityItems: actItem, applicationActivities: nil)
        present(avc, animated: true, completion: nil)
    }

    @objc private func close() {
        downloadTask?.cancel()
        dismiss(animated: true)
    }
    @objc private func play() {
        guard let track = track else { return }
        switch stateOfPlayButton {
        case .play:
            playerView.startActivityIndicator()
            playerView.activityIndicator.center = playButton.center
            playButton.isHidden = true
            guard let url = track.previewURL else { return }
            downloadTask = .downloadData(url: url) {[weak self] data in
                guard let self = self else { return }
                self.playerView.stopActivityIndicator()
                
                self.playButton.isHidden = false
                self.stateOfPlayButton = .pause
                self.configurePlayer(data: data)
                self.playButton.removeFromSuperview()
                self.playButton = CustomButton.createPauseButton()
            }
        case .pause:
            if let player = player, player.isPlaying {
                playButton.removeFromSuperview()
                playButton = CustomButton.createPlayButton()
                player.pause()
            } else {
                playButton.removeFromSuperview()
                playButton = CustomButton.createPauseButton()
                player?.play()
            }
        }
    }
    // MARK: - Player
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
    private func addConstraintButtons() {
        view.addSubview(playButton)
        view.addSubview(shareButton)
        view.addSubview(closeButton)
        playButton.centerInSuperview(size: .init(width: 50, height: 50), padding: .init(top: 100, left: 0, bottom: 0, right: 0))
        shareButton.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 80, left: 0, bottom: 0, right: 20), size: .init(width: 40, height: 40))
        closeButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 80, left: 20, bottom: 0, right: 0), size: .init(width: 40, height: 40))
    }
}
    // MARK: - AVAudioPlayerDelegate
extension PlayerViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.configuration = .setCustomImage("play.circle.fill", config: .tinted(), pointSize: 50, scale: .large)
    }
}
    

