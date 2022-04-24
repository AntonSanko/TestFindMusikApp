//
//  MatchingHelperService.swift
//  ForTests
//
//  Created by Anton on 21/04/2022.
//

import Foundation

protocol MatchingHelperService {
    var errorMsg: String { get }
    func match()
    func stopListening()
}

