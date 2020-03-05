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
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?

    // MARK: - マイク使用許可

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

    // MARK: - 効果音

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

// MARK: - Recorder Methods

extension AudioManager {
    func record(url: URL) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder!.record()
        } catch {
            print("DEBUG_ERROR: record")
        }
    }

    func stopRecord() {
        recorder?.stop()
        recorder = nil
    }
}

// MARK: - Player methods

extension AudioManager {
    func playerPlay(url: URL) {
        do {
            try player = AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("DEBUG_ERROR: get played")
        }
    }

    func playerPouse() {
        player?.pause()
    }

    func getAudioPlayerDuration(url: URL) -> Float {
        var value: Float = 0.0
        do {
            try player = AVAudioPlayer(contentsOf: url)
            value = Float(player!.duration)
        } catch {
            print("DEBUG_ERROR: get audio player duration")
        }
        return value
    }

    func setPlayerCurrentTime(time: TimeInterval) {
        player?.currentTime = time
    }

    func getPlayerCurrentTime() -> Float {
        return Float(player!.currentTime)
    }

    func getCurrentTimeString() -> String {
        var timeString = "0:00"
        let min = floor(player!.currentTime / 60)
        let sec = player!.currentTime - (min * 60)
        if sec < 10 {
            timeString = "0\(Int(min)):0\(Int(sec))"
        } else if sec >= 10, min < 10 {
            timeString = "0\(Int(min)):\(Int(sec))"
        } else {
            timeString = "\(Int(min)):\(Int(sec))"
        }
        return timeString
    }
}
