//
//  MemoDataBrain.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/03.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import Foundation
import RealmSwift

class MemoDataBrain {
    private let realm = try! Realm()

    func getMemoData(primaryKey: Int?) -> MemoData {
        var memoData = MemoData()
        if let data = realm.object(ofType: MemoData.self, forPrimaryKey: primaryKey) {
            memoData = data
        }
        return memoData
    }

    func saveTitle(data: MemoData, title: String, content: String) {
        do {
            try realm.write {
                print(title)
                if title == "" {
                    data.title = "Folder"
                } else {
                    data.title = title
                }
                data.content = content
            }
        } catch {
            print("DEBUG_ERROR: MemoData Save Title")
        }
    }

    func addNewAudioData(data: MemoData) -> AudioData? {
        do {
            let audioData = AudioData()
            try realm.write {
                if data.audioDatas.count != 0 {
                    audioData.id = data.audioDatas.max(ofProperty: "id")! + 1
                    audioData.order = data.audioDatas.max(ofProperty: "order")!
                } else {
                    audioData.id = Int("\(data.id)\(data.id)\(audioData.id)")!
                }
                data.audioDatas.append(audioData)
            }
            return audioData
        } catch {
            print("DEBUG_ERROR: MemoData Add New AudioData")
            return nil
        }
    }
}
