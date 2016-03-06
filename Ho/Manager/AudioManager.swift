//
//  AudioManager.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/06.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import AVFoundation

class AudioManager: NSObject {
    
    static let sharedInstance = AudioManager()
    
    var audioSession: AVAudioSession!
    
    override init() {
        super.init()
        start()
    }
    
    func start() {
        setupAudioSession()
    }
    
    func setupAudioSession() {
        self.audioSession = AVAudioSession.sharedInstance()
        
        do {
            try self.audioSession.setCategory(AVAudioSessionCategoryMultiRoute)
            try self.audioSession.setActive(true)
        }
        catch {
        }
    }
}
