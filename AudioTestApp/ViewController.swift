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
    
    @IBAction func pressRecord(_ sender: UIButton) {
             engine.record()
    }
    
    @IBAction func pressStop(_ sender: UIButton) {
        engine.stop()
    }
 
    @IBAction func pressPlay(_ sender: UIButton) {
        engine.play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

