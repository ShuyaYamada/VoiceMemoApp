//
//  MemoData.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2019/08/27.
//  Copyright © 2019 ShuyaYamada. All rights reserved.
//

import Foundation
import RealmSwift

class MemoData: Object {
    //PrimaryKey
    @objc dynamic var id = 0
    
    //並び替えに使う値
    @objc dynamic var order = 0
    
    //Memoの内容
    @objc dynamic var title = ""
    @objc dynamic var content = ""
    var audioDatas = List<AudioData>()
    
    
    override static func primaryKey() -> String {
        return "id"
    }
}
