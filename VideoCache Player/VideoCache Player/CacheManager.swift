//
//  CacheManager.swift
//  VideoCache Player
//
//  Created by DREAMWORLD on 08/04/22.
//

import Foundation


public enum Result<String> {
    case success(String)
    case failure(NSError)
}

class CacheManager {

    static let shared = CacheManager()

    private let fileManager = FileManager.default

    private lazy var mainDirectoryUrl: URL = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsUrl
    }()

    func getFileWith(stringUrl: String, completionHandler: @escaping (_ success: Bool,_ path: URL?,_ message: String) -> Void ) {

        DispatchQueue.main.async { [self] in
            let file = directoryFor(stringUrl: stringUrl)

            //return file path if already exists in cache directory
            guard !fileManager.fileExists(atPath: file.path)  else {
                print("****************************** LOADED FROM CACHE ******************************")
                completionHandler(true, file, "video loaded from cache")
                return
            }
            let url = URL(string: stringUrl)!
            
            //check network reachability
            guard NetworkManager.isConnectedToNetwork() else {
                completionHandler(false, nil, "Internet connection lost")
                return
            }
            print("****************************** FIRST TIME LOAD ******************************")
            completionHandler(true, url, "video first time load")

            DispatchQueue.global(qos: .background).async {
                //background task code
                    print("****************************** START URL TO DATA ******************************")
                    if let videoData = NSData(contentsOf: url) {
                        print("****************************** START WRITING IN URL ******************************")
                        videoData.write(to: file, atomically: true)
                        print("****************************** DONE WRITING IN URL ******************************")
                    } else {
                        completionHandler(false, nil, "Video content not supported to play")
                        print("****************************** CONTENT URL NOT CONVERTED IN DATA ******************************")
                    }
            }
        }
    }

    private func directoryFor(stringUrl: String) -> URL {

        let fileURL = URL(string: stringUrl)!.lastPathComponent

        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)

        return file
    }
    
    public func clearCache(){
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                    }
                    catch let error as NSError {
                        debugPrint("Ooops! Something went wrong: \(error)")
                    }

                }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
