//
//  Recorder.swift
//  Dopple
//
//  Created by Giles Van Gruisen on 1/25/15.
//  Copyright (c) 2015 Giles Van Gruisen. All rights reserved.
//

import Foundation
import AVFoundation
import Publinks

/** Provides an interface to record audio and write data to specified URL */
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


