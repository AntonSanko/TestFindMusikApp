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
    var matcher: MatchingHelperService?
    lazy var coreDataStack = CoreDataStack(modelName: "MyMusic")
    var track: Track? {
        didSet {
            stopAnimation()
            toPlayerVC()
        }
    }
    var matchButton = CustomButton.createMathButton()
    var myMusicButton = CustomButton.createMyMusicButton()
    var searchButton = CustomButton.createSearchButton()
    var cancelButton = CustomButton.createCancelButton()
    
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
        animateMatchPulse()
        matcher?.match()
    }
    @objc func actionCancelButton() {
        stopAnimation()
        matcher?.stopListening()
    }
    @objc func toSearchVC() {
        performSegue(withIdentifier: "searchVC", sender: nil)
    }
    @objc func toMyMusicVC() {
        performSegue(withIdentifier: "myMusicVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myMusicVC" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! MyMusicViewController
            controller.coreDataStack = coreDataStack
        }
    }
    func toPlayerVC() {
        let viewController = toViewController(with: "playerVC") as! PlayerViewController
        viewController.track = track
        viewController.state = true
        present(viewController, animated: true)
    }
    func toViewController(with identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        return controller
    }
    func songMatched(item: SHMatchedMediaItem?, error: Error?) {
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
    func saveTrack(_ item: SHMatchedMediaItem?) {
        let music = MyTrack(context: coreDataStack.managerContext)
        music.name = item?.title
        music.artist = item?.artist
        music.artworkUrl = item?.artworkURL
        music.trackViewURL = item?.appleMusicURL
        
        coreDataStack.saveContext()
    }
    // MARK: - Alert
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    // MARK: Animation
    func startAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.myMusicButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.myMusicButton.alpha = 0
            self.searchButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.searchButton.alpha = 0
            self.cancelButton.alpha = 1
        }
    }
    func stopAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.myMusicButton.transform = CGAffineTransform.identity
            self.myMusicButton.alpha = 1
            self.searchButton.transform = CGAffineTransform.identity
            self.searchButton.alpha = 1
            self.cancelButton.alpha = 0
            self.matchButton.layer.removeAllAnimations()
        }
    }
    func animateMatchPulse() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [.repeat, .autoreverse]) {
            self.matchButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { _ in
            UIView.animate(withDuration: 1, delay: 0) {
                self.matchButton.transform = CGAffineTransform.identity
            }
        }
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
       
        matchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            matchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            matchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: 70),
            matchButton.widthAnchor.constraint(equalToConstant: 80),
            matchButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

