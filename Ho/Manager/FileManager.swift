//
//  FileManager.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/06.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

class FileManager: NSObject {
    static let sharedInstance = FileManager()
    
    func uploadFile(fileName: String, data: NSData) {
        var error: NSError?
        let file = NCMBFile.fileWithName(fileName, data: data)
        file.save(&error)
    }

    func uploadFile(fileName: String, fileURL: String) {
        let data = NSData(contentsOfFile: fileURL)
        var error: NSError?
        let file = NCMBFile.fileWithName(fileName, data: data)
        file.save(&error)
    }

    func uploadFile(fileName: String, url: NSURL) {
        let data = NSData(contentsOfURL: url)
        var error: NSError?
        let file = NCMBFile.fileWithName(fileName, data: data)
        file.save(&error)
    }

    func uploadFile(fileName: String, url: NSURL, defaultUrl: NSURL?=nil) -> NSURL? {
        let data = NSData(contentsOfURL: url)
        var error: NSError?
        let file = NCMBFile.fileWithName(fileName, data: data)
        file.save(&error)
        if error == nil {
            return file.url
        }
        
        return defaultUrl
    }
    
    func downloadAudioFile(url: NSURL) -> Bool {
        let path = NSTemporaryDirectory() + "tmp.aiff"
        let data = getAudioData(url.description)
        return data.writeToFile(path, atomically: true)
    }

    func getAudioData(url: String) -> NSData {
        let fileName = url
        if let file = NCMBFile.fileWithName(fileName, data: nil) as? NCMBFile {
            return file.getFileData()
        }
        
        return NSData()
    }
}

public extension NCMBFile {
    public func getFileData() -> NSData {
        let request = NCMBURLConnection(path: "files/\(self.name)", method: "GET", data: nil)
        
        do {
            if let responseData = try request.syncConnection() as? NSData {
                return responseData
            }
        }
        catch {
        }
        
        return NSData()
    }
}
