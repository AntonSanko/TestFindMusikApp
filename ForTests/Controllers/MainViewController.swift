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
    var matchButton = UIButton()
    var myMusicButton = UIButton()
    var searchButton = UIButton()
    var cancelButton = UIButton()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundColor")
//        matcher = MatchingHelper(matchHandler: songMatched)
        matcher = MockMatchingHelper(matchHandler: songMatched)
        
        configureMatchButton()
        configureMyMusicButton()
        configureSearchButton()
        configureCancelButton()
    }
    
    // MARK: - ConfigButtons
    private func configureMatchButton() {
        matchButton.configuration = .setCustomImage("mic.circle.fill", config: .tinted(), pointSize: 80, scale: .large)
        matchButton.addTarget(self, action: #selector(match), for: .touchUpInside)
        addMatchButtonConstraints()
        
    }
    
    private func configureMyMusicButton() {
        myMusicButton.configuration = .setCustomImage("music.note.list", config: .tinted(), pointSize: 40, scale: .large)
        myMusicButton.addTarget(self, action: #selector(toMyMusicVC), for: .touchUpInside)
        addMyMusicButtonConstraints()
        
    }
    
    private func configureSearchButton() {
        searchButton.configuration = .setCustomImage("text.magnifyingglass", config: .tinted(), pointSize: 40, scale: .large)
        searchButton.addTarget(self, action: #selector(toSearchVC), for: .touchUpInside)
        addSearchButtonConstraints()
        
    }
    private func configureCancelButton() {
        cancelButton.configuration = .setCustomImage("xmark", config: .tinted(), pointSize: 30, scale: .small)
        cancelButton.configuration?.title = "Cancel"
        cancelButton.configuration?.attributedTitle?.font = UIFont.boldSystemFont(ofSize: 25)
        cancelButton.configuration?.imagePadding = 5
        cancelButton.alpha = 0
        cancelButton.addTarget(self, action: #selector(actionCancelButton), for: .touchUpInside)
        addCancelButtonConstraints()
        
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
            self.matchButton.transform = CGAffineTransform.identity
        }

    }
    
    // MARK: - Constraints
    private func addMatchButtonConstraints() {
        view.addSubview(matchButton)
        matchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            matchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            matchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: 70),
            matchButton.widthAnchor.constraint(equalToConstant: 80),
            matchButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    private func addMyMusicButtonConstraints() {
        view.addSubview(myMusicButton)
        myMusicButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            myMusicButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            myMusicButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            myMusicButton.widthAnchor.constraint(equalToConstant: 50),
            myMusicButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    private func addSearchButtonConstraints() {
        view.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            searchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            searchButton.widthAnchor.constraint(equalToConstant: 50),
            searchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    private func addCancelButtonConstraints() {
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -20),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0),
            cancelButton.widthAnchor.constraint(equalToConstant: 150),
            cancelButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}

