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
        print(error)
    }

    func uploadFile(fileName: String, url: NSURL) {
        let data = NSData(contentsOfURL: url)
        var error: NSError?
        let file = NCMBFile.fileWithName(fileName, data: data)
        file.save(&error)
    }

}
