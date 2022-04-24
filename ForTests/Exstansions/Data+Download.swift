//
//  Data+Download.swift
//  ForTests
//
//  Created by Anton on 20/04/2022.
//

import Foundation

extension URLSessionDownloadTask {
    static func downloadData(url: URL, completion: @escaping (Data) -> Void) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { url, _, error in
            if error == nil, let url = url, let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    completion(data)
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
}
