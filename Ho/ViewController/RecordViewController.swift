//
//  RecordViewController.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/05.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import EZAudio
import KYShutterButton
import UNAlertView

class RecordViewController: UIViewController, EZMicrophoneDelegate, EZRecorderDelegate {
    @IBOutlet weak var recordButton: KYShutterButton!
    @IBOutlet weak var audioPlot: EZAudioPlot! {
        didSet {
            audioPlot.plotType = EZPlotType.Buffer
            audioPlot.shouldFill = true
            audioPlot.shouldMirror = true
        }
    }
    private var mic: EZMicrophone! = {
        let _mic = EZMicrophone.sharedMicrophone()
        _mic.startFetchingAudio()
        _mic.device = EZAudioDevice.inputDevices().last as! EZAudioDevice!
        return _mic
    }()
    private var recorder: EZRecorder!
    
    @IBAction func didPushRecordButton(sender: AnyObject) {
        changeRecordState()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioManager.sharedInstance.start()
        self.mic.delegate = self
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private func changeRecordState() {
        switch self.recordButton.buttonState {
        case .Normal:
            setupRecord()
            self.recordButton.buttonState = .Recording
            
            break
        case .Recording:
            self.recordButton.buttonState = .Normal
            showSaveAlert()
            break
        }
    }
    
    private func showSaveAlert() {
        let alertView = UNAlertView(title: "録音終了", message: "保存しますか？")
        alertView.addButton("No", backgroundColor: Color.HoColor, action: {
        })
        
        alertView.addButton("Yes", backgroundColor: Color.HoColor, action: {
            self.saveRecordData()
        })
        alertView.show()
    }
    
    private func setupRecord() {
        self.recorder = EZRecorder(URL: getRecordFileURL(), clientFormat: self.mic.audioStreamBasicDescription(), fileType: .AIFF)
        self.recorder.delegate = self
        _ = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: Selector("stopRecord"), userInfo: nil, repeats: false)
    }
    
    func stopRecord() {
        if self.recordButton.buttonState == .Recording {
            changeRecordState()
        }
    }
    
    private func saveRecordData() {
        self.recorder.closeAudioFile()
        self.recorder.delegate = nil
    }
    
    private func getRecordFileURL() -> NSURL {
        let dirURL = getDocumentsDirectoryURL()
        let fileName = "recording.aiff"
        let recordingsURL = dirURL.URLByAppendingPathComponent(fileName)
        return recordingsURL
    }
    
    private func getDocumentsDirectoryURL() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory,
            inDomains: NSSearchPathDomainMask.UserDomainMask)
        
        if urls.isEmpty {
            fatalError("URLs for directory are empty.")
        }
        return urls[0]
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        if self.recordButton.buttonState == .Recording {
            self.recorder.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
    }
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        })
    }
    
    // MARK: - EZRecorderDelegate
    func recorderDidClose(recorder: EZRecorder!) {
//        FileManager.sharedInstance.uploadFile(NSUUID().UUIDString + ".aiff",
//            url: getRecordFileURL())
        UserManager.sharedInstance.updateHo(NSUUID().UUIDString + ".aiff", url: getRecordFileURL())
    }
}