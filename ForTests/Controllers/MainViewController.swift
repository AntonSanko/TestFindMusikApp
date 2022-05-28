//
//  ViewController.swift
//  ForTests
//
//  Created by Anton on 19/04/2022.
//

import UIKit
import ShazamKit
import CoreData

class MainViewController: UIViewController {
    
    // MARK: -  Properties
    private var matcher: MatchingHelperService?
    lazy private var coreDataStack = CoreDataStack(modelName: "MyMusic")
    private var track: Track? {
        didSet {
            stopAnimation()
            toPlayerVC()
        }
    }
    private var matchButton = CustomButton.createMathButton()
    private var myMusicButton = CustomButton.createMyMusicButton()
    private var searchButton = CustomButton.createSearchButton()
    private var cancelButton = CustomButton.createCancelButton()
    private let animator = Animator()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundColor")
//        matcher = MatchingHelper(matchHandler: songMatched)
        matcher = MockMatchingHelper(matchHandler: songMatched)
        setUpButtons()
    }
    // MARK: - ConfigButtons
    private func setUpButtons() {
        setConstraints()
        matchButton.addTarget(self, action: #selector(match), for: .touchUpInside)
        myMusicButton.addTarget(self, action: #selector(toMyMusicVC), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(toSearchVC), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(actionCancelButton), for: .touchUpInside)
    }
    // MARK: Buttons action
    @objc private func match() {
        startAnimation()
        matcher?.match()
    }
    @objc private func actionCancelButton() {
        stopAnimation()
        matcher?.stopListening()
    }
    @objc private func toSearchVC() {
        performSegue(withIdentifier: "searchVC", sender: nil)
    }
    @objc private func toMyMusicVC() {
        performSegue(withIdentifier: "myMusicVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myMusicVC" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! MyMusicViewController
            controller.coreDataStack = coreDataStack
        }
    }
    private func toPlayerVC() {
        let viewController = toViewController(with: "playerVC") as! PlayerViewController
        viewController.track = track
        viewController.state = true
        present(viewController, animated: true)
    }
    private func toViewController(with identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        return controller
    }
    private func songMatched(item: SHMatchedMediaItem?, error: Error?) {
        if error != nil {
            stopAnimation()
            if let errorMsg = matcher?.errorMsg, !errorMsg.isEmpty {
                showAlert(errorMsg)
            } else {
            showAlert("Something went wrong\n:(")
            }
        } else {
            saveTrack(item)
            track = Track(name: item?.title ?? "Unknown", artist: item?.artist ?? "", artworkUrl100: item?.artworkURL, trackViewURL: item?.appleMusicURL)
        }
    }
    private func saveTrack(_ item: SHMatchedMediaItem?) {
        let music = MyTrack(context: coreDataStack.managerContext)
        music.name = item?.title
        music.artist = item?.artist
        music.artworkUrl = item?.artworkURL
        music.trackViewURL = item?.appleMusicURL
        
        coreDataStack.saveContext()
    }
    // MARK: - Alert
    private func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    // MARK: Animation
    private func startAnimation() {
        animator.scaleAndFade(views: [myMusicButton, searchButton], identity: false)
        animator.animateMatchPulse(view: matchButton)
        animator.fade(view: cancelButton, fade: false)
    }
    private func stopAnimation() {
        animator.fade(view: cancelButton, fade: true)
        animator.scaleAndFade(views: [myMusicButton, searchButton], identity: true)
        matchButton.layer.removeAllAnimations()
    }
    // MARK: - Constraints
    private func setConstraints() {
        view.addSubview(myMusicButton)
        view.addSubview(searchButton)
        view.addSubview(cancelButton)
        view.addSubview(matchButton)
        myMusicButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 60, bottom: 100, right: 0), size: CGSize(width: 50, height: 50))
        searchButton.anchor(top: nil, leading: nil, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 100, right: 60), size: .init(width: 50, height: 50))
        cancelButton.anchor(top: view.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 100, left: 0, bottom: 0, right: 20), size: .init(width: 150, height: 30))
        matchButton.centerInSuperview(size: .init(width: 80, height: 80), padding: .init(top: 100, left: 0, bottom: 0, right: 0))
    }
}

