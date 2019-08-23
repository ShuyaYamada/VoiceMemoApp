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
    //録音データを識別するURLに使う日付 (録音データ自体はDirectoryに保存)
    @objc dynamic var date = Date()
    
    //他のプロパティも追加予定
    
}
