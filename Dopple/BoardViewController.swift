//
//  BoardViewController.swift
//  Dopple
//
//  Created by Giles Van Gruisen on 1/24/15.
//  Copyright (c) 2015 Giles Van Gruisen. All rights reserved.
//

import UIKit
import AVFoundation
import Publinks

class BoardViewController: UIViewController {

    @IBOutlet var buttons: [Button]!
    @IBOutlet var middleButton: Button!

    override func viewDidLoad() {

        // Start audio session for play and record, use real speaker
        var error: NSError?
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
        AVAudioSession.sharedInstance().setActive(true, error: &error)
        AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: &error)

        // Subscribe to middleButton's up/downlink
        middleButton.downlink >>> middleDown
        middleButton.uplink >>> middleUp
    }

    func middleDown(button: Button) {}
    func middleUp(button: Button) {}

}

class PlaybackViewController: BoardViewController {

    /** Player objects built automatically when `urls` is set */
    var players: [Player] = [Player]()

    /** URLs of audio files to be played */
    var urls: [NSURL]! {
        didSet {
            // Build players
            players = urls.map { Player(sound: $0) }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set URLs
        urls = recordingURLs(8, "m4a")

        // Enumerate buttons and subscribe to each
        for (index, button) in enumerate(buttons) {

            // Subscribe to each button's downlink
            button.downlink >>> { _ in

                // Call playSound with button index
                self.playSound(index)
            }
        }
    }

    /** Player sound from URL at specified index */
    func playSound(index: Int) {

        // Remove existing player for same sound
        self.players = self.players.filter { player in
            return player.audioPlayer?.url! != self.urls[index]
        }

        // Build new player and add to players
        let player = Player(sound: self.urls[index])
        self.players += [player]

        // Play sound
        player.playFromBeginning()
    }


    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Set urls upon transition
        let recordVC = segue.destinationViewController as RecordViewController
        recordVC.urls = urls
    }

}

class RecordViewController: BoardViewController {

    /** Recorder used to record, reset upon each recording */
    var recorder: Recorder!

    /** Audio destination file URLs */
    var urls: [NSURL]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Enumerate buttons and subscribe to each
        for (index, button) in enumerate(buttons) {

            // Start recording for index upon button down
            button.downlink >>> { _ in
                self.startRecording(index)
            }

            // Stop recording upon button up
            button.uplink >>> stopRecording
        }
    }

    /** Start recording to URL at specified index */
    func startRecording(index: Int) {
        recorder = Recorder(URL: self.urls[index])
        recorder.record()
    }

    /** Stop recording and write to URL at index specified upon `startRecording(index: Int)` */
    func stopRecording(button: Button) {
        recorder.stop()
    }


    // MARK: BoardViewController override

    override func middleUp(button: Button) {
        let playbackVC = self.presentingViewController as PlaybackViewController

        playbackVC.urls = urls
        playbackVC.dismissViewControllerAnimated(true, completion: nil)
    }

}

// Returns array of `n` recording URLs w/ specified `ext` in docs dir. (e.g. .../Documents/recording0.m4a)
public func recordingURLs(n: Int, ext: String) -> [NSURL] {

    // Find basePath in documents directory
    let basePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray).lastObject! as String

    // Return 0..<n mapped to [NSURL] where each = basePath + "recording\(i).\(ext)"
    return Array(0..<n).map { i -> NSURL in
        return NSURL.fileURLWithPathComponents([basePath, "recording\(i).\(ext)"])!
    }

}

