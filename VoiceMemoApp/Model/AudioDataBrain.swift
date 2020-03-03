//
//  AudioDataBrain.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/03.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

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
}
