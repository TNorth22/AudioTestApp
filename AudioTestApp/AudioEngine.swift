//
//  File.swift
//  AudioTestApp
//
//  Created by Travis Roberson on 11/9/17.
//  Copyright © 2017 Travis Roberson. All rights reserved.
//

import Foundation
import AVFoundation


class AudioEngine: NSObject {
    
    //MARK: AudioEngine
    
    private var engine: AVAudioEngine!
    private var distortion: AVAudioUnitDistortion!
    private var playerNode: AVAudioPlayerNode!
    
    private var outputFile: AVAudioFile?
    
    private var audioPlayer: AVAudioPlayer!
    
    private var audioRecorder: AVAudioRecorder!
    
    private var recordingSession: AVAudioSession!
    
    
    override init() {
        super.init()
        
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                       print ("allowed recording")
                    } else {
                        print ("nope")
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("/NewRecording.caf")

        engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        

        print(audioFilename)
        do {
            
            try outputFile = AVAudioFile(forWriting: audioFilename, settings: engine.mainMixerNode.outputFormat(forBus: 0).settings)
           
            
        }
        catch {
               print("Couldn't init audio file")
        }
        
        do {
           
            try audioPlayer = AVAudioPlayer(contentsOf: audioFilename)
            
        }
        catch {
            print("Couldn't init audio player")
        }
        
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            
            try audioRecorder = AVAudioRecorder(url: audioFilename, settings: settings)
            
        }
        catch {
            print("Couldn't init audio player")
        }
        
        
        distortion = AVAudioUnitDistortion()
        engine.attach(distortion)
        engine.connect(input, to: distortion, format: format)
        engine.connect(distortion, to: engine.mainMixerNode, format: format)
        
     //   try! engine.start()
        
    }
    
    public func record() {
        
        print ("recording")
        
        audioRecorder.stop()
        audioPlayer.stop()
        
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    public func processAudio() {
        
    }
    
    
    
    public func play() {
        
        print ("playing")
        
        audioPlayer.stop()
        engine.stop()
        engine.reset()
        
        audioPlayer.prepareToPlay()
        audioPlayer.play()

    }
    
    public func stop() {
        
        print ("stopping")
        audioRecorder.stop()
        audioPlayer.stop()
        engine.stop()
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    
    
    
    
}
