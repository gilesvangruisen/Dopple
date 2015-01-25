//
//  Player.swift
//  Dopple
//
//  Created by Giles Van Gruisen on 1/24/15.
//  Copyright (c) 2015 Giles Van Gruisen. All rights reserved.
//

import UIKit
import AVFoundation

/** Loads audio from specified URL and provides an interface for playback */
public class Player: NSObject, AVAudioPlayerDelegate {

    /** The URL of the audio file to be played */
    private let sound: NSURL

    /** The AVAudioPlayer instance created upon initialization */
    public var audioPlayer: AVAudioPlayer?

    /** Returns a new Player */
    init(sound: NSURL) {
        self.sound = sound
        super.init()

        // Init player
        var error: NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: self.sound, error: &error)

        // Check for error
        if let err = error {
            println("[Player error] \(err)")
            return
        }

        // Prepare player
        self.audioPlayer?.delegate = self
        self.audioPlayer?.prepareToPlay()
    }


    // MARK: Player controls

    /** Play audio player from beginning */
    public func playFromBeginning() {
        self.audioPlayer?.currentTime = 0
        let x = self.audioPlayer?.play()
    }

    /** Play audio player from current time */
    public func play() {
        self.audioPlayer?.play()
    }

    /** Pause audio player at current time */
    public func pause() {
        self.audioPlayer?.pause()
    }

    /** Stop audio player */
    public func stop() {
        self.audioPlayer?.stop()
    }


    // MARK: AVAudioPlayerDelegate

    public func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("[Player finished] \(flag)")
    }

    public func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("[Player error] \(error)")
    }

}

