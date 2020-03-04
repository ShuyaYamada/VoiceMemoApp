//
//  AudioManager.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/04.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import AVFoundation
import Foundation

class AudioManager {
    var player: AVAudioPlayer?
    var recorder: AVAudioRecorder?

    func isRecordPermission() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
            try session.setActive(true)
            session.requestRecordPermission { bool in
                bool
            }
        } catch {
            print("DEBUG_PRINT: sessionでエラー")
        }
        return false
    }

    func record(url: URL) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
        } catch {
            print("DEBUG_ERROR: record")
        }
    }

    func stopRecord() {
        recorder?.stop()
        recorder = nil
    }

    func soundRecordStarted() {
        let soundFilePath = Bundle.main.path(forResource: "RecordStarted", ofType: "wav")!
        let sound: URL = URL(fileURLWithPath: soundFilePath)
        do {
            player = try AVAudioPlayer(contentsOf: sound, fileTypeHint: nil)
            player?.play()
        } catch {
            print("DEBUG_ERROR: sound record started")
        }
    }

    func soundRecordEnd() {
        let soundFilePath = Bundle.main.path(forResource: "RecordEnd", ofType: "wav")!
        let sound: URL = URL(fileURLWithPath: soundFilePath)
        do {
            player = try AVAudioPlayer(contentsOf: sound, fileTypeHint: nil)
            player?.play()
        } catch {
            print("DEBUG_ERROR: sound record End")
        }
    }
}
