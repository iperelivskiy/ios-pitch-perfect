//
//  ViewController.swift
//  Pitch Perfect
//
//  Created by Ivan Perelivskiy on 6/5/15.
//  Copyright (c) 2015 Ivan Perelivskiy. All rights reserved.
//

import UIKit
import AVFoundation


class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    var recorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var tapImages: [String:UIImage?]!
    var paused = false

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var tapView: UIImageView!

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        tapImages = [
            "microphone": UIImage(named:"Microphone"),
            "pause": UIImage(named:"Pause")
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        initControls()
    }

    // MARK: AVAudioRecorderDelegate protocol

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!,
                                         successfully flag: Bool) {
        if flag {
            recordedAudio = RecordedAudio(
                title: recorder.url.lastPathComponent!, fileURL: recorder.url)
            self.performSegueWithIdentifier("playSoundsSegue", sender: nil)
        } else {
            println("Recording audio error.")
            initControls()
        }
    }

    // MARK: Actions

    @IBAction func recordAudio(sender: UIButton) {
        let isRecording = recorder != nil && recorder.recording

        animateTapView(isRecording)

        if isRecording {
            stopButton.hidden = true
            recordingLabel.text = "Recording paused. Tap to resume."
            recorder.pause()
            paused = true
        } else {
            stopButton.hidden = false
            recordingLabel.text = "Recording. Tap to pause."

            if paused {
                recorder.record()
            } else {
                AVAudioSession.sharedInstance().setCategory(
                    AVAudioSessionCategoryPlayAndRecord, error: nil)

                let dirPaths = NSSearchPathForDirectoriesInDomains(
                    .DocumentDirectory, .UserDomainMask, true)
                let dirPath = dirPaths[0] as! NSString
                let filePath = NSURL.fileURLWithPathComponents(
                    [dirPath, "recorded-audio.wav"])

                recorder = AVAudioRecorder(URL: filePath, settings: nil,
                                           error: nil)
                recorder.meteringEnabled = true
                recorder.delegate = self
                recorder.prepareToRecord()
                recorder.record()
            }

            paused = false
        }
    }

    @IBAction func stopRecording(sender: UIButton) {
        recorder.stop()
        AVAudioSession.sharedInstance().setActive(false, error: nil)
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue,
                                  sender: AnyObject?) {
        if segue.identifier == "playSoundsSegue" {
            let controller: PlaySoundsViewController =
                segue.destinationViewController as! PlaySoundsViewController
            controller.recordedAudio = recordedAudio
        }
    }

    // MARK: Own methods

    func initControls() {
        recordButton.enabled = true
        recordingLabel.text = "Tap to record."
        stopButton.hidden = true
    }

    func animateTapView(isRecording: Bool) {
        if isRecording {
            tapView.image = tapImages["pause"]!
        } else {
            tapView.image = tapImages["microphone"]!
        }

        tapView.stopAnimating()
        tapView.alpha = 0.8
        tapView.hidden = false
        tapView.transform = CGAffineTransformMakeScale(1, 1)

        UIView.animateWithDuration(
            0.6,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.tapView.transform =
                    CGAffineTransformMakeScale(8, 8)
                self.tapView.alpha = 0
            },
            completion: nil
        )
    }
}
