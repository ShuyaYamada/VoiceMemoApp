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

    func getAllMemoData() -> Results<MemoData> {
        let datas = realm.objects(MemoData.self).sorted(byKeyPath: "order", ascending: false)
        return datas
    }

    func getMemoData(primaryKey: Int?) -> MemoData {
        var memoData = MemoData()
        if let data = realm.object(ofType: MemoData.self, forPrimaryKey: primaryKey) {
            memoData = data
        }
        return memoData
    }

    func createNewMemoData() -> MemoData? {
        do {
            let memoData = MemoData()
            try realm.write {
                let allMemoData = realm.objects(MemoData.self)
                if allMemoData.count != 0 {
                    memoData.id = allMemoData.max(ofProperty: "id")! + 1
                }
                realm.add(memoData)
            }
            return memoData
        } catch {
            print("DEBUG_ERROR: Create New MemoData")
            return nil
        }
    }

    func delete(data: MemoData) {
        do {
            try realm.write {
                realm.delete(data)
            }
        } catch {
            print("DEBUG_ERROR: Delete Memo Data")
        }
    }

    func saveTitle(data: MemoData, title: String, content: String) {
        do {
            try realm.write {
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

    func upOrder(datas: Results<MemoData>, indexes: ClosedRange<Int>, sourceData: MemoData, destinationOrder: Int) {
        do {
            try realm.write {
                for index in indexes {
                    let data = datas[index]
                    data.order += 1
                }
                sourceData.order = destinationOrder
            }
        } catch {
            print("DEBUG_ERROR: Up Order MemoData")
        }
    }

    func downOrder(datas: Results<MemoData>, indexes: ReversedCollection<Range<Int>>, sourceData: MemoData, destinationOrder: Int) {
        do {
            try realm.write {
                for index in indexes {
                    let data = datas[index]
                    data.order -= 1
                }
                sourceData.order = destinationOrder
            }
        } catch {
            print("DEBUG_ERROR: Up Order MemoData")
        }
    }
}
