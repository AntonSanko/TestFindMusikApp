//
//  MockMatchingHelper.swift
//  ForTests
//
//  Created by Anton on 21/04/2022.
//

import Foundation
import ShazamKit
import MusicKit

class MockMatchingHelper: MatchingHelperService {
    
    var errorMsg: String
    let error: NSError = NSError(domain: "error", code: 42)
   
    let matchedItem = SHMatchedMediaItem(properties: [.artist: "Aaron Smith",
                                        .title: "Dancin",
                                        .appleMusicURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/c2/da/e7/c2dae768-3f21-b104-fc4c-1140c4d30978/mzaf_11396732760881163242.plus.aac.p.m4a")!,
                                        .artworkURL: URL(string: "https://is3-ssl.mzstatic.com/image/thumb/Music115/v4/70/f5/10/70f51090-5725-11c9-3d00-e99446b406ea/source/100x100bb.jpg")!,
                                            
   ])
    
    private var matchHandler: ((SHMatchedMediaItem?, Error?) -> Void)?
    
    init(matchHandler: ((SHMatchedMediaItem?, Error?) -> Void)?) {
        self.matchHandler = matchHandler
        self.errorMsg = ""
    }
    func stopListening() {
        //
    }
    func match() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.matchHandler?(self.matchedItem, nil)
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.matchHandler?(nil, self.error)
//        }
    }
}
