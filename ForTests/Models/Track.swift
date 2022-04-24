//
//  Track.swift
//  ForTests
//
//  Created by Anton on 19/04/2022.
//

import Foundation

class Track {
    
    // MARK: - Constants
    
    let artist: String
    let name: String
    let previewURL: URL?
    let artworkUrl60: URL?
    let artworkUrl100: URL?
    let trackViewURL: URL?
    
    // MARK: - Initialization
    
    init(name: String, artist: String, previewURL: URL? = nil, artworkUrl60: URL? = nil, artworkUrl100: URL? = nil, trackViewURL: URL? = nil) {
        self.name = name
        self.artist = artist
        self.previewURL = previewURL
        self.artworkUrl60 = artworkUrl60
        self.artworkUrl100 = artworkUrl100
        self.trackViewURL = trackViewURL
    }
}
