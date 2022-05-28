//
//  SearchViewController.swift
//  ForTests
//
//  Created by Anton on 19/04/2022.
//

import UIKit

class SearchViewController: UIViewController {
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    // MARK: - Constants
    private let queryService = QueryService()
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    private var searchResults: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        tableView.delegate = self
        tableView.dataSource = self
        setupSearchBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: true)
    }
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Songs or Artists"
        searchController.searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
  
    guard let searchText = searchBar.text, !searchText.isEmpty else { return }
    queryService.getSearchResults(searchTerm: searchText) { [weak self] results, errorMessage in
      if let results = results {
        self?.searchResults = results
        self?.tableView.reloadData()
      }
      if !errorMessage.isEmpty {
        print("Search error: " + errorMessage)
      }
    }
      tableView.reloadData()
  }
}
// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch queryService.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results:
            return searchResults.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch queryService.state {
        case .notSearchedYet:
            print("?????")
            return UITableViewCell()
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let activityIndicator = cell.viewWithTag(100) as! UIActivityIndicatorView
            activityIndicator.startAnimating()
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        case .results:
            let cell = tableView.dequeueReusableCell(withIdentifier:TableView.CellIdentifiers.searchResultCell,
              for: indexPath) as! SearchResultCell
           
            let searchResult = searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "playerVC") as? PlayerViewController else { return }
        playerVC.track = searchResults[indexPath.row]
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch queryService.state {
        case .notSearchedYet, .loading, .noResults:
          return nil
        case .results:
          return indexPath
        }
    }
}
