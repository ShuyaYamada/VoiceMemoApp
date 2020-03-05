//
//  AudioDataBrain.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/03.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import AVFoundation
import Foundation
import RealmSwift

class AudioDataBrain {
    private let realm = try! Realm()

    func saveTitle(title: String, data: AudioData) {
        do {
            try realm.write {
                print(title)
                if title == "" {
                    data.titile = "Audio Data"
                } else {
                    data.titile = title
                }
            }
        } catch {
            print("DEBUG_ERROR: Save AudioData Title")
        }
    }

    func delete(data: AudioData) {
        do {
            try realm.write {
                let url = getURL(data: data)
                try FileManager.default.removeItem(at: url)
                realm.delete(data)
            }
        } catch {
            print("DEBUG_ERROR: Delete AudioData")
        }
    }

    func upOrder(datas: Results<AudioData>, indexes: ClosedRange<Int>, sourceData: AudioData, destinationOrder: Int) {
        do {
            try realm.write {
                for index in indexes {
                    let data = datas[index]
                    data.order += 1
                }
                sourceData.order = destinationOrder
            }
        } catch {
            print("DEBUG_ERROR: Up Order AudioData")
        }
    }

    func downOrder(datas: Results<AudioData>, indexes: ReversedCollection<Range<Int>>, sourceData: AudioData, destinationOrder: Int) {
        do {
            try realm.write {
                for index in indexes {
                    let data = datas[index]
                    data.order -= 1
                }
                sourceData.order = destinationOrder
            }
        } catch {
            print("DEBUG_ERROR: Up Order AudioData")
        }
    }

    func getTimeString(data: AudioData) -> String {
        var timeString = "0:00"
        do {
            let url = getURL(data: data)
            let audioFile = try AVAudioFile(forReading: url)
            let sampleRate = audioFile.fileFormat.sampleRate
            let duration: Double = floor(Double(audioFile.length) / sampleRate)
            let min: Double = floor(duration / 60)
            let sec: Double = duration - (min * 60)
            timeString = "\(Int(min)):\(Int(sec))"
            return timeString
        } catch {
            print("DEBUG_ERROR: get audio time")
        }
        return timeString
    }

    func getURL(data: AudioData) -> URL {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentPath.appendingPathComponent("\(data.id).m4a")
        return url
    }
}
