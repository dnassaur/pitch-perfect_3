//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Douglas Nassaur on 3/13/15.
//  Copyright (c) 2015 Douglas Nassaur. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    //MARK: Outlets
    
    @IBOutlet weak var stopPlayButton: UIButton!

    //MARK: Globals
    
    var audioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var audioPlayerNode:AVAudioPlayerNode!
    var fileTimer: NSTimer?
    
    //MARK: Override Functions
    //MARK: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        stopPlayButton.hidden = true

        // Initialize the engine and player, enable the rate property and identify as delegate for player controls
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
        
        // Prepare audio file for reading
        
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        stopPlayButton.hidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        
        // Remove recorded audio when user leaves playback view to prevent disk space filling up with old files.
        let fileManager = NSFileManager.defaultManager()
        var error: NSError?
        
        if fileManager.removeItemAtURL(receivedAudio.filePathUrl,error:&error) {
            println("Deleting file")
        } else {
            println("Remove failed: \(error!.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Interface Builder Actions

    @IBAction func playSoundSlow(sender: UIButton) {
        playAudioWithVariableSpeed(0.5)
    }
    @IBAction func playSoundFast(sender: UIButton) {
        playAudioWithVariableSpeed(2.5)
    }

    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        println("Stopping Audio Playback")
        stopPlayButton.hidden = true
        stopAllAudio()
    }
    //MARK: Play Functions
    
    // Creating single function for slow/fast play
    
    func playAudioWithVariableSpeed(speed: Float){
        
        //Reset the audioPlayer and audioEngine each time
        
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        //Address session activity so sound is directed to main speaker
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        
        session.setCategory(AVAudioSessionCategoryPlayback, error:&error)
        session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: &error)
        session.setActive(true, error: &error)
        
        //Set the new speed, prepare the file for play and play
        audioPlayer.rate = speed
        audioPlayer.delegate = self
        println("New Run...Preparing to Play Sound")
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        // Make stopPlayButton visible while the file is playing
        if (self.audioPlayer.playing) {
            stopPlayButton.hidden = false
        }
        
    }
    
    func playAudioWithVariablePitch(pitch: Float){
        
        //Reset the audioPlayer and audioEngine each time
        
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        //Address session activity so sound is directed to main speaker
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        
        session.setCategory(AVAudioSessionCategoryPlayback, error:&error)
        session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: &error)
        session.setActive(true, error: &error)
        
        // Initialize audioPlayerNode and attach it to the audioEngine
        
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Create pitch object and attach it to the AVAudioEngine and player
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        // Connect the audio player to the pitch effect
        audioEngine.connect(audioPlayerNode, to:changePitchEffect, format:nil)
        
        // Connect objects to the speakers
        audioEngine.connect(changePitchEffect, to:audioEngine.outputNode, format:nil)
        
        // Prepare audioPlayerNode and audioEngine for playback and then play
        println("New Run...Preparing to Play Sound")
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: completionHandler)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
        
        // Make stopPlayButton visible while the file is playing
        if (self.audioPlayerNode.playing) {
            stopPlayButton.hidden = false
        }
        
    }
    
    //MARK: Helper Functions
    
    func audioPlayerDidFinishPlaying(audioPlayer:AVAudioPlayer!, successfully flag: Bool){
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        
        //Return the session to inactive
        session.setActive(false, error: &error)
        
        println("File is done playing, be a good citizen and de-activate session...")
        stopPlayButton.hidden = true
    }
    
    func completionHandler(){
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
                
        println("File is done playing, be a good citizen and de-activate session...")
        stopPlayButton.hidden = true

    }
    
    func stopAllAudio() {
        
        //Check to see if audioPlayerNode was initialized before trying to stop it.
        println("stopAllAudio: audioPlayerNode = \(audioPlayerNode)")
        if ((audioPlayerNode) != nil) {
            println("audioPlayerNode detected...shutting down")
            audioPlayerNode.stop()
        }
        audioPlayer.currentTime = 0.0
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }

}
