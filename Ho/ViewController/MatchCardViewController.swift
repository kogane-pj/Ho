//
//  MatchCardViewController.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/21.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import EZAudio

class MatchCardViewController: UIViewController, EZAudioFileDelegate, EZAudioPlayerDelegate, EZOutputDataSource {
    
    var urlString: String = ""
    
    private var audioPlayer: EZAudioPlayer! = nil
    private var audioFile: EZAudioFile?
    
    @IBOutlet weak var audioPlot: EZAudioPlot! {
        didSet {
            audioPlot.plotType = EZPlotType.Buffer
            audioPlot.shouldFill = true
            audioPlot.shouldMirror = true
        }
    }

    class func getInstance() -> MatchCardViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewControllerWithIdentifier(Storyboard.MatchCard) as? MatchCardViewController {
            return vc
        }
        
        return self.init()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
//        plaaaay()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setup() {
        AudioManager.sharedInstance.start()
        setupAudioFile()
        play()
    }
    
    private func play() {
        self.audioPlayer.play()
    }
    
    func pause() {
        self.audioPlayer.pause()
    }
    
    // MARK: - Private
    private func plaaaay() {
        if let url = NSURL(string: self.urlString) {
            if FileManager.sharedInstance.downloadAudioFile(url) {
                if let _url = NSURL(string: NSTemporaryDirectory() + "tmp.aiff") {
                    self.audioFile = EZAudioFile(URL: _url, delegate: self)
                    EZOutput.sharedOutput().clientFormat = self.audioFile!.clientFormat
                    if !EZOutput.sharedOutput().isPlaying {
                        EZOutput.sharedOutput().dataSource = self
                        EZOutput.sharedOutput().startPlayback()
                    }
                }
            }
        }
    }
    
    private func setupAudioFile() {
        if let url = NSURL(string: self.urlString) {
            //print(url)
            if FileManager.sharedInstance.downloadAudioFile(url) {
                let path = NSTemporaryDirectory() + "tmp.aiff"
                let _url = NSURL(fileURLWithPath: path)
                print("fileURL: \(_url)")
                //if let _url = u {
                    self.audioPlayer = EZAudioPlayer(audioFile: EZAudioFile(URL: _url))
                    self.audioPlayer.shouldLoop = true
                    self.audioPlayer.delegate = self
                    self.audioPlayer.volume = 1
                //}
            }
        }
    }
 
    // MARK: - EZAudioPlayerDelegate
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        if self.audioPlayer.isPlaying {
            print("play....\n")
        }
        else {
            print("pause....\n")
        }

        //dispatch_async(dispatch_get_main_queue(), {() -> Void in
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        //})
    }

    // MARK: - EZAudioFileDelegate
    func audioFile(audioFile: EZAudioFile!, readAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        })
    }
    
    // MARK: - EZOutputDataSource
    func output(output: EZOutput!, shouldFillAudioBufferList audioBufferList: UnsafeMutablePointer<AudioBufferList>, withNumberOfFrames frames: UInt32, timestamp: UnsafePointer<AudioTimeStamp>) -> OSStatus {
        if let audioFile = self.audioFile {
            var buffer: UInt32 = 0
            var eof = ObjCBool(false)
            audioFile.readFrames(frames, audioBufferList: audioBufferList, bufferSize: &buffer, eof: &eof)
            
        }
        return 0
    }
}
