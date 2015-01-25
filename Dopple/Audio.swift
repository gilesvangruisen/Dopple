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

public struct Sound {
    public let url: NSURL
}

public class Player: NSObject, AVAudioPlayerDelegate {

    let sound: Sound
    var audioPlayer: AVAudioPlayer?
    var error: NSError?

    init(sound: Sound) {
        self.sound = sound

        super.init()

        var error: NSError?

        audioPlayer = AVAudioPlayer(contentsOfURL: self.sound.url, error: &error)

        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()

        println(audioPlayer)

        if let error = error {
            println(error)
        }
    }

    public func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("finished \(flag)")
    }

    public func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println(error)
    }

    public func play() {
        let playing = audioPlayer?.play()
    }

}

public class Recorder: NSObject, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder?

    public let link = Publink<Sound>()

    public init(URL recorderURL: NSURL?) {
        super.init()

        if let recorderURL = recorderURL {

            var error: NSError?

            audioRecorder = AVAudioRecorder(URL: recorderURL, settings: recorderSettings(), error: &error)
            audioRecorder?.delegate = self

            if let error = error {
                println(error)
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
        link.publish(Sound(url: audioRecorder!.url!))
    }

    public func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println(error)
    }

    public func record() {
        audioRecorder?.deleteRecording()
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
    }

    public func stop() {
        audioRecorder?.stop()
    }

}


