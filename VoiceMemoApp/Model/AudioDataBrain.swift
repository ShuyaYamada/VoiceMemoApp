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
            print("DEBUG_ERROR: AudioData Save Title")
        }
    }
}
