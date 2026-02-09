//
//  FileDownloader.swift
//  School Chimes
//
//  Created by Chandhru on 19/05/25.
//

import Foundation
class FileDownloader: NSObject, URLSessionDownloadDelegate {
    
    private var completion: ((Result<URL, Error>) -> Void)?
    private var destinationURL: URL?
    
    func downloadFile(from urlString: String, folderName: String, fileName: String, completion: ((Result<URL, Error>) -> Void)? = nil) {
        guard let fileURL = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            }
            return
        }

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderURL = documentsURL.appendingPathComponent(folderName, isDirectory: true)
        self.destinationURL = folderURL.appendingPathComponent(fileName)
        self.completion = completion
        
        // Ensure folder exists
        do {
            if !fileManager.fileExists(atPath: folderURL.path) {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
                print("📁 Created folder at: \(folderURL.path)")
            }
        } catch {
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }

        // Start loader
        DispatchQueue.main.async {
            CircularProgressLoader.shared.show()
        }
        
        // Start download with delegate
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        let task = session.downloadTask(with: fileURL)
        task.resume()
    }

    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            CircularProgressLoader.shared.updateProgress(to: Double(progress))
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let destinationURL = self.destinationURL else { return }

        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: location, to: destinationURL)

            DispatchQueue.main.async {
                CircularProgressLoader.shared.hide()
                self.completion?(.success(destinationURL))
            }
        } catch {
            DispatchQueue.main.async {
                CircularProgressLoader.shared.hide()
                self.completion?(.failure(error))
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                CircularProgressLoader.shared.hide()
                self.completion?(.failure(error))
            }
        }
    }
}
