//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Ivan Perelivskiy on 2015.06.15.
//  Copyright (c) 2015 Ivan Perelivskiy. All rights reserved.
//

import UIKit
import AVFoundation


class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {

    var recordedAudio: RecordedAudio!
    var recordedAudioFile: AVAudioFile!
    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!

    @IBOutlet weak var stopButton: UIButton!

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        AVAudioSession.sharedInstance().overrideOutputAudioPort(.Speaker,
                                                                error: nil)
        recordedAudioFile = AVAudioFile(forReading: recordedAudio.fileURL,
                                        error: nil)
        audioPlayer = AVAudioPlayer(contentsOfURL: recordedAudio.fileURL,
                                    error: nil)
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
        audioEngine = AVAudioEngine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        reset()
    }

    // MARK: AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!,
                                     successfully flag: Bool) {
        stopButton.hidden = true
    }

    // MARK: Actions

    @IBAction func stopPlayback(sender: UIButton) {
        reset()
    }

    @IBAction func playSlowAudio(sender: UIButton) {
        playWithRate(0.5)
    }

    @IBAction func playFastAudio(sender: UIButton) {
        playWithRate(1.5)
    }

    @IBAction func playChipmunkAudio(sender: UIButton) {
        playWithPitchEffect(1000)
    }

    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playWithPitchEffect(-700)
    }

    @IBAction func playEchoAudio(sender: UIButton) {
        playWithEcho()
    }

    @IBAction func playReverbAudio(sender: UIButton) {
        playWithReverb(AVAudioUnitReverbPreset.Cathedral)
    }

    // MARK: Own methods

    func reset() {
        stopButton.hidden = true
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioEngine.stop()
        audioEngine.reset()
    }

    func playWithRate(rate: Float) {
        reset()
        stopButton.hidden = false
        audioPlayer.rate = rate
        audioPlayer.play()
    }

    func playWithEffect(effectNode: AVAudioNode) {
        reset()
        stopButton.hidden = false

        let playerNode = AVAudioPlayerNode()
        audioEngine.attachNode(playerNode)
        audioEngine.attachNode(effectNode)
        audioEngine.connect(playerNode, to: effectNode, format: nil)
        audioEngine.connect(effectNode, to: audioEngine.outputNode,
                            format: nil)
        audioEngine.prepare()
        audioEngine.startAndReturnError(nil)

        playerNode.scheduleFile(
            recordedAudioFile,
            atTime: nil,
            // Floowing is called too early.
            // http://stackoverflow.com/questions/29427253/completionhandler-of-avaudioplayernode-schedulefile-is-called-too-early
            completionHandler: {
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopButton.hidden = true
                })
            }
        )
        playerNode.play()
    }

    func playWithPitchEffect(pitch: Float) {
        let effectNode = AVAudioUnitTimePitch()
        effectNode.pitch = pitch
        playWithEffect(effectNode)
    }

    func playWithReverb(preset: AVAudioUnitReverbPreset) {
        let effectNode = AVAudioUnitReverb()
        effectNode.loadFactoryPreset(preset)
        effectNode.wetDryMix = 60
        playWithEffect(effectNode)
    }

    func playWithEcho() {
        let effectNode = AVAudioUnitDelay()
        effectNode.delayTime = 0.6
        effectNode.wetDryMix = 30
        effectNode.feedback = 40
        playWithEffect(effectNode)
    }
}
