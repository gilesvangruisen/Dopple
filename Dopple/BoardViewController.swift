//
//  BoardViewController.swift
//  Dopple
//
//  Created by Giles Van Gruisen on 1/24/15.
//  Copyright (c) 2015 Giles Van Gruisen. All rights reserved.
//

import UIKit

import AVFoundation
import Pipeline
import Publinks
import Deferred

enum BoardState: Int {
    case Record = 0
    case Playback = 1
}

class BoardViewController: UIViewController {

    @IBOutlet var buttons: [Button]!
    @IBOutlet var middleButton: Button!

    override func viewDidLoad() {
        var error: NSError?
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
//        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        AVAudioSession.sharedInstance().setActive(true, error: &error)
        AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: &error)

        middleButton.downlink >>> middleDown
        middleButton.uplink >>> middleUp
    }

    func middleDown(button: Button) {

    }

    func middleUp(button: Button) {

    }

}

class PlaybackViewController: BoardViewController {

    var players: [Player] = [Player]()

    var urls: [NSURL]! {
        didSet {
            players = urls.map { Player(sound: $0) }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        urls = recordingURLs(8)

        for (index, button) in enumerate(buttons) {

            button.downlink >>> { button in
                let player = self.players[index]
                player.stop()
                player.play()
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let recordVC = segue.destinationViewController as RecordViewController
        recordVC.urls = urls

    }

}

class RecordViewController: BoardViewController {

    var recorder: Recorder!

    var urls: [NSURL]!

    override func viewDidLoad() {
        super.viewDidLoad()

        for (index, button) in enumerate(buttons) {

            button.downlink >>> { _ in
                self.recorder = Recorder(URL: self.urls[index])
                self.startRecording()
            }

            button.uplink >>> stopRecording
        }
    }

    func startRecording() {
        recorder.record()
    }

    func stopRecording(button: Button) {
        recorder.stop()
    }

    override func middleUp(button: Button) {
        let playbackVC = self.presentingViewController as PlaybackViewController

        playbackVC.urls = urls
        playbackVC.dismissViewControllerAnimated(true, completion: nil)
    }

}

public func recordingURLs(n: Int) -> [NSURL] {
    let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    var urls = [NSURL]()

    for num in 0...n - 1 {
        let outputFileBase = NSURL.fileURLWithPathComponents([paths.lastObject as String, "recording\(num).m4a"])
        println("URL: \(outputFileBase)")
        if let url = outputFileBase {
            urls += [url]
        }
    }

    return urls
}
