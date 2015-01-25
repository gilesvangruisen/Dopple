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

public class Player: NSObject, AVAudioPlayerDelegate {

    let sound: NSURL
    public var audioPlayer: AVAudioPlayer?
    var error: NSError?

    let background = dispatch_queue_create("com.gilesvangruisen.Dopple.player", DISPATCH_QUEUE_SERIAL)

    init(sound: NSURL) {
        self.sound = sound

        super.init()

        var error: NSError?

        audioPlayer = AVAudioPlayer(contentsOfURL: self.sound, error: &error)

        if let error = error {
            println("[Player error] \(error)")
        }

        dispatch_async(background) {
            self.audioPlayer?.delegate = self
            self.audioPlayer?.prepareToPlay()
        }

    }

    public func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("[Player finished] \(flag)")
    }

    public func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("[Player error] \(error)")
    }

    public func play() {
        dispatch_async(background) {
            self.audioPlayer?.currentTime = 0
//            dispatch_async(dispatch_get_main_queue()) {
                let x = self.audioPlayer?.play()
//            }
        }
    }

}

public class Recorder: NSObject, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder?

    public let link = Publink<NSURL>()

    public init(URL recorderURL: NSURL?) {
        super.init()

        if let recorderURL = recorderURL {

            var error: NSError?

            audioRecorder = AVAudioRecorder(URL: recorderURL, settings: recorderSettings(), error: &error)
            audioRecorder?.delegate = self

            if let error = error {
                println("[Recorder error] \(error)")
            }
        }
    }

    private func recorderSettings() -> [NSObject: AnyObject] {
        return [
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: 0,
            AVLinearPCMIsFloatKey: 0,
            AVNumberOfChannelsKey: 2,
            AVFormatIDKey: kAudioFormatMPEG4AAC,
        ]
    }

    public func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        link.publish(recorder.url)
    }

    public func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("[Recorder error] \(error)")
    }

    public func record() {
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
    }

    public func stop() {
        audioRecorder?.stop()
    }

}


