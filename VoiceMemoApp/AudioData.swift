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
    //PrimaryKey
    @objc dynamic var id = 0
    
    //セルの並べ替えのための値
    @objc dynamic var order = 0
    
    @objc dynamic var titile = "新規録音"
    
    @objc dynamic var date = Date()
    
    //cellのexpandViewをコントロールするための値
    @objc dynamic var isClosed = true
    
     //他のプロパティも追加予定
    
    
    override static func primaryKey() -> String {
        return "id"
    }
}
