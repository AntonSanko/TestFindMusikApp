//
//  MatchingHelper.swift
//  ForTests
//
//  Created by Anton on 21/04/2022.
//

import Foundation
import AVFAudio
import ShazamKit

class MatchingHelper: NSObject {
    
    // MARK: - Properties
    private var session = SHSession()
    private let audioEngine = AVAudioEngine()
    var errorMsg = ""
    
    private var matchHandler: ((SHMatchedMediaItem?, Error?) -> Void)?
    
    init(matchHandler: ((SHMatchedMediaItem?, Error?) -> Void)?) {
        self.matchHandler = matchHandler
    }
    
    // MARK: - Internal Methods
    func match() {
        
        session.delegate = self
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission {[weak self] success in
            if success {
                self?.recordAudio()
            } else {
                self?.errorMsg = "Please Allow Microphone Access!"
            }
        }
    }
    // MARK: - Methods
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: .zero)
    }
    
    private func recordAudio() {
        if audioEngine.isRunning {
            stopListening()
            return
        }
        let inputMode = audioEngine.inputNode
        let format = inputMode.outputFormat(forBus: .zero)
        audioEngine.inputNode.removeTap(onBus: .zero)
        inputMode.installTap(onBus: .zero, bufferSize: 1024, format: format) {[weak session] buffer, time in
         
            session?.matchStreamingBuffer(buffer, at: time)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.errorMsg = error.localizedDescription
        }
    }
}
// MARK: - Extensions
extension MatchingHelper: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            if let handler = self.matchHandler {
                handler(match.mediaItems.first, nil)
                self.stopListening()
            }
        }
    }
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        errorMsg = error?.localizedDescription ?? ""
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            
            if let handler = self.matchHandler {
                handler(nil, error)
                self.stopListening()
            }
        }
    }
}
extension MatchingHelper: MatchingHelperService {}
