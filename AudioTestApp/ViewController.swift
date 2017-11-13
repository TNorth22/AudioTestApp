//
//  ViewController.swift
//  AudioTestApp
//
//  Created by Travis Roberson on 11/9/17.
//  Copyright © 2017 Travis Roberson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var engine : AudioEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engine = AudioEngine()
    }
    
    @IBAction func startRecording(_ sender: UIButton) {
             engine.startRecording()
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        engine.stopRecording()
    }
 
    @IBAction func playOriginal(_ sender: UIButton) {
        engine.playOriginal()
    }
    
    @IBAction func stopOriginal(_ sender: UIButton) {
        engine.stopPlayingOriginal()
    }
    
    @IBAction func playProcessed(_ sender: UIButton) {
        engine.playProcessed()
    }
    
    @IBAction func stopProcessed(_ sender: UIButton) {
        engine.stopProcessed()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

