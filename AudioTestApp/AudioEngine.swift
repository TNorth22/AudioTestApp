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
    private var reverb: AVAudioUnitReverb!
    private var delay: AVAudioUnitDelay!
    private var shift: AVAudioUnitTimePitch!
    private var mixer: AVAudioMixerNode!
    
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
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
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
            print ("failed to setup audio session")
            // failed to record!
        }
        
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("NewRecording.mp4")
        print(audioFilename)

        
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
        
        
        engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        
        mixer = AVAudioMixerNode()
        
        playerNode = AVAudioPlayerNode()
        
        distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(AVAudioUnitDistortionPreset.multiCellphoneConcert)
        distortion.wetDryMix = 20
        
        reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(AVAudioUnitReverbPreset.largeChamber)
        reverb.wetDryMix = 15
        
        delay = AVAudioUnitDelay()
        delay.wetDryMix = 0
        
        shift = AVAudioUnitTimePitch()
        shift.pitch = -200
        
        engine.attach(playerNode)
        engine.attach(distortion)
        engine.attach(reverb)
        engine.attach(delay)
        engine.attach(shift)
        engine.attach(mixer)
        
        engine.connect(playerNode, to: distortion, format: format)
        engine.connect(distortion, to: reverb, format: format)
        engine.connect(reverb, to: delay, format: format)
        engine.connect(delay, to: shift, format: format)
        engine.connect(shift, to: mixer, format: format)
        
        engine.connect(mixer, to: engine.mainMixerNode, format: format)
        
 
        try! engine.start()
    }
    
    public func startRecording() {

        audioRecorder.stop()
        
        audioRecorder.prepareToRecord()
        let success = audioRecorder.record()
        
        print ("recording " + success.description)
    }
    
    
    public func stopRecording() {
        print ("stop recording")
        
        audioRecorder.stop()
        
    }
    
    public func playOriginal() {
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
            
            let success = audioPlayer.prepareToPlay()
            
            print ("play original " + success.description)
            
            audioPlayer.play()
            
        } catch {
             print("Couldn't init audio player")
        }
 
        

    }
    
    public func stopPlayingOriginal() {
        
        audioPlayer.stop()
    }
    
    
    public func playProcessed() {
        
        print ("play processed")
        
        do {
            let audioFile = try AVAudioFile(forReading: audioRecorder.url)
            

            let tapFormat = mixer.outputFormat(forBus: 0)
            
            let fileName = getDocumentsDirectory().appendingPathComponent("processed_recording.caf")
            let recordedFile = try AVAudioFile(forWriting: fileName, settings: tapFormat.settings)

            
        

            mixer.installTap(onBus: 0, bufferSize: AVAudioFrameCount(audioFile.length), format: tapFormat) {
                buffer, _ in

                do {

                    try recordedFile.write(from: buffer)

                } catch {

                }


            }

            
            
            playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            playerNode.play()
            
        } catch {
            print ("could not schedule file \(error .localizedDescription)")
        }
        
      

    }
    
    public func stopProcessed() {
        
        print ("stop playing processed")
        playerNode.stop()
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
