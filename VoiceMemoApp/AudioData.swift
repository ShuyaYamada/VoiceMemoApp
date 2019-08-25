//
//  AudioData.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2019/08/23.
//  Copyright © 2019 ShuyaYamada. All rights reserved.
//

import Foundation
import RealmSwift

class AudioData: Object {
    //primaryKeyにするid
    @objc dynamic var id = 0
    
    @objc dynamic var titile = "新規録音"
    
    @objc dynamic var date = Date()
    
     //他のプロパティも追加予定
    
    
    override static func primaryKey() -> String {
        return "id"
    }
}
