//
//  FavoriteViewController.swift
//  ForTests
//
//  Created by Anton on 19/04/2022.
//

import UIKit
import CoreData

class MyMusicViewController: UIViewController {
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: MyMusicViewController.createLayout())
    
    // MARK: -  Properties
    public var coreDataStack: CoreDataStack?
    private var myTrack: [MyTrack] = []
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        navigationController?.navigationBar.backgroundColor = UIColor(named: "BackgroundColor")
        navigationController?.navigationBar.prefersLargeTitles = true
        fetchData()
        myTrack = deleteDuplicate(in: myTrack)
        
    }
    
    // MARK: - Methods
    private func fetchData() {
        guard let coreDataStack = coreDataStack else { return }
        let fetch: NSFetchRequest<MyTrack> = MyTrack.fetchRequest()
        do {
            let results = try coreDataStack.managerContext.fetch(fetch)
            myTrack = results
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
    private func deleteDuplicate(in array: [MyTrack]?) -> [MyTrack] {
        guard array != nil else { return [] }
        var newMyTrack:[MyTrack] = []
        
        for item in myTrack {
            for newItem in newMyTrack {
                if item.trackViewURL == newItem.trackViewURL {
                    newMyTrack.removeLast()
                    coreDataStack?.managerContext.delete(newItem)
                }
            }
            newMyTrack.append(item)
        }
        
        coreDataStack?.saveContext()
        return newMyTrack
    }
    // MARK: - Setup CollectionView
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(MusicCollectionCell.self, forCellWithReuseIdentifier: MusicCollectionCell.identifier)
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        
    }
   private static func createLayout() -> UICollectionViewCompositionalLayout {
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(2/4.5)), subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
// MARK: - CollectionView DataSource
extension MyMusicViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        myTrack.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCollectionCell.identifier, for: indexPath) as! MusicCollectionCell
        let item = myTrack[indexPath.item]
        cell.configureCell(for: item)
        return cell
    }
}
