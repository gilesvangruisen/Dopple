//
//  Player.swift
//  Dopple
//
//  Created by Giles Van Gruisen on 1/24/15.
//  Copyright (c) 2015 Giles Van Gruisen. All rights reserved.
//

import UIKit
import AVFoundation
import Publinks
import Pipeline

// MARK: Player

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


// MARK: Recorder

/** Records audio and writes to specified URL */
public class Recorder: NSObject, AVAudioRecorderDelegate {

    /** Only exists if URL is not empty */
    var audioRecorder: AVAudioRecorder?

    /** Recorder settings, default records AAC to m4a file */
    public let recorderSettings = [
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: 0,
        AVLinearPCMIsFloatKey: 0,
        AVNumberOfChannelsKey: 2,
        AVFormatIDKey: kAudioFormatMPEG4AAC,
    ]

    /** Publishes URL when recording is finished */
    public let link = Publink<NSURL>()

    /** Returns a new Recorder */
    public init(URL recorderURL: NSURL?) {
        super.init()

        // Init recorder only if URL exists
        if let recorderURL = recorderURL {

            // Init recorder
            var error: NSError?
            audioRecorder = AVAudioRecorder(URL: recorderURL, settings: recorderSettings, error: &error)

            // Check for error
            if let err = error {
                println("[Recorder error] \(err)")
                return
            }

            // Prepare recorder
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
        }
    }


    // MARK: Recorder controls

    /** Start recording */
    public func record() {
        audioRecorder?.record()
    }

    /** Stop recording */
    public func stop() {
        audioRecorder?.stop()
    }


    // MARK: AVAudioRecorderDelegate

    public func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        link.publish(recorder.url)
    }

    public func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("[Recorder error] \(error)")
    }

}


