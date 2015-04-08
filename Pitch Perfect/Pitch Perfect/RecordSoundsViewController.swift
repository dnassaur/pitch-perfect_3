//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Douglas Nassaur on 3/10/15.
//  Copyright (c) 2015 Douglas Nassaur. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController,AVAudioRecorderDelegate {
    
    //Mark: Outlets
    
    @IBOutlet weak var tapToRecord: UILabel!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    //Mark: Globals
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    //MARK: Override Functions
    //MARK: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
        recordButton.enabled = true
        tapToRecord.hidden = false

    }
    
    //MARK: Interface Builder Actions

    @IBAction func recordAudio(sender: UIButton) {

        // Manage Button Visibility
        tapToRecord.hidden = true
        recordingInProgress.hidden = false
        stopButton.hidden = false
        recordButton.enabled = false
        
        // Path to the working directory
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) [0] as String
        
        var currentDateTime = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyy-HHmmss"
        var recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        var pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)

        // Setup audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        // Initialize and prepare the recorder
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true;
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        // Save the recorded audio - The file and the path
        if(flag){
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title:recorder.url.lastPathComponent!)
            // Move to the next scene - aka perform the segue
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }else{
            println("Recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

    @IBAction func stopRecordAudio(sender: UIButton) {
        tapToRecord.hidden = true
        recordingInProgress.hidden = true
        stopButton.hidden = true
        recordButton.enabled = true
        // Stop recording the users voice
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance();
        audioSession.setActive(false, error: nil)
    }
}

