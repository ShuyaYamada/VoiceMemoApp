//
//  ViewController.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2019/08/23.
//  Copyright © 2019 ShuyaYamada. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    //AVAudio系の変数
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    //Realmと録音データの配列
    let realm = try! Realm()
    var AudioDataArray = try! Realm().objects(AudioData.self).sorted(byKeyPath: "date", ascending: false)

    //IBOutlet
    @IBOutlet weak var buttonImage: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //START---Start Record and Stop Record---
    @IBAction func record(_ sender: Any) {
        if audioRecorder == nil {
            //audioDataを作成
            let audioData = AudioData()
            audioData.date = Date()
            //audioDataが1つ以上ならidの処理を行う
            let allAudioDatas = realm.objects(AudioData.self)
            if allAudioDatas.count != 0 {
                audioData.id = allAudioDatas.max(ofProperty: "id")! + 1
            }
            
            //audioRecorderに必要なURL
            let failName = getURL().appendingPathComponent("\(audioData.id).m4a")
            //audioRecorderに必要なSettings
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            //Record Start
            do {
                //audioRecorderをインスタンス化
                audioRecorder = try AVAudioRecorder(url: failName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                //audioDataを保存
                try! realm.write {
                    realm.add(audioData.self)
                }
                //ボタンのimageを変更する
                buttonImage.setImage(UIImage(named: "stopBTN"), for: .normal)
            } catch {
                print("DEBUG_PRINT: 録音失敗")
                displayAlert(title: "Error", message: "Recording failed")
            }
        } else {
            //Record Stop
            audioRecorder.stop()
            audioRecorder = nil
            //tableViewをリロード
            tableView.reloadData()
            //ボタンのimageを変更する
            buttonImage.setImage(UIImage(named: "startBTN"), for: .normal)
        }
    }
    //END---Start Record and Stop Record---
    
    
    //START---viewDidLoad---
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    //END---viewDidLoad---
    

    //START---getURL---
    func getURL() -> URL {
        //録音データの保存先URLの先頭部分。 このURL+AudioDataのidで識別する。
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = path[0]
        return url
    }
    //END---getURL---
    
    //START---inputAlert---
    func inputAlert() {
        
    }
    
    
    //START---displayAlert---
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    //END---displaaAlert---
    
    
    //START---TableView系メソッド---
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AudioDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //audioDataを取得
        let audioData = AudioDataArray[indexPath.row]
        //titleをcellに表示
        cell.textLabel?.text = audioData.titile
        //日時の表示形式を設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: audioData.date)
        //日時をcellに表示
        cell.detailTextLabel?.text = dateString
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //audioDataを取得
        let audioData = AudioDataArray[indexPath.row]
        //録音データの保存されてるURLを取得
        let url = getURL().appendingPathComponent("\(audioData.id).m4a")
        
        //録音データ出力
        do {
            //aduioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("DEBUG_PRINT: 出力失敗")
            displayAlert(title: "Error", message: "Playing failed")
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //audioDataを取得
            let audioData = AudioDataArray[indexPath.row]
            //録音データの保存されてるURLを取得
            let url = getURL().appendingPathComponent("\(audioData.id).m4a")
            
            //録音データを削除
            try! FileManager.default.removeItem(at: url)
            //realmのaudioDataを削除
            try! realm.write {
                self.realm.delete(self.AudioDataArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    //END---TableView系メソッド---
    
}

