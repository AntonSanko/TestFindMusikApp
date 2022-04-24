//
//  QueryService.swift
//  ForTests
//
//  Created by Anton on 19/04/2022.
//

import Foundation

class QueryService {
    
    enum State {
      case notSearchedYet
      case loading
      case noResults
      case results
    }
    
    // MARK: - Properties
    
    let defaultSession = URLSession(configuration: .default)
    
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var tracks: [Track] = []
    private(set) var state: State = .notSearchedYet
    
    // MARK: - Type Alias
    
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([Track]?, String) -> Void
    
    
    // MARK: - Internal Methods
    
    func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
        
        dataTask?.cancel()
        
        state = .loading
        
        if var urlComponents = URLComponents(string: "https://itunes.apple.com/search") {
            urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
            
            guard let url = urlComponents.url else {
                return
            }
            
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                defer {
                    self.dataTask = nil
                }
                var newState = State.notSearchedYet
                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    self.updateSearchResults(data)
                    
                    if self.tracks.isEmpty {
                        newState = .noResults
                    } else {
                        newState = .results
                    }
                    DispatchQueue.main.async {
                        self.state = newState
                        completion(self.tracks, self.errorMessage)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    
    // MARK: - Private Methods
    
    private func updateSearchResults(_ data: Data) {
        var response: JSONDictionary?
        tracks.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let array = response!["results"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        for trackDictionary in array {
            if let trackDictionary = trackDictionary as? JSONDictionary,
               let previewURLString = trackDictionary["previewUrl"] as? String,
               let previewURL = URL(string: previewURLString),
               let name = trackDictionary["trackName"] as? String,
               let artist = trackDictionary["artistName"] as? String,
               let imageSmallURL = trackDictionary["artworkUrl60"] as? String,
               let imageSmall = URL(string: imageSmallURL),
               let imageLargeURL = trackDictionary["artworkUrl100"] as? String,
               let imageLarge = URL(string: imageLargeURL),
               let trackURL = trackDictionary["trackViewUrl"] as? String,
               let trackViewURL = URL(string: trackURL) {
                tracks.append(Track(name: name, artist: artist, previewURL: previewURL, artworkUrl60: imageSmall, artworkUrl100: imageLarge, trackViewURL: trackViewURL))

            } else {
                errorMessage += "Problem parsing trackDictionary\n"
            }
        }
    }
}
