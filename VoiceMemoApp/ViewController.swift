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

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    //AVAudio系の変数
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    //Realmと録音データの配列
    let realm = try! Realm()
    var AudioDataArray = try! Realm().objects(AudioData.self).sorted(byKeyPath: "order", ascending: false)

    //IBOutlet
    @IBOutlet weak var buttonImage: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //START---Start Record and Stop Record---
    @IBAction func record(_ sender: Any) {
        if audioRecorder == nil {
            //audioDataを作成
            let audioData = AudioData()
            audioData.date = Date()
            //audioDataが1つ以上ならidの処理を行う  -追加-orderもorderの最大値+1を
            let allAudioDatas = realm.objects(AudioData.self)
            if allAudioDatas.count != 0 {
                audioData.id = allAudioDatas.max(ofProperty: "id")! + 1
                audioData.order = allAudioDatas.max(ofProperty: "order")! + 1
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
            //inputAlertを表示してaudioDataのtitleを入力させる
            inputAlert()
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
        
        //navigationControllerの設定
        self.navigationController?.isToolbarHidden = false
        navigationItem.title = "VoiceMemo"
        navigationItem.rightBarButtonItem = editButtonItem

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        registerCells()
    }
    //END---viewDidLoad---
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //START---registerCell---
    private func registerCells() {
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
    }
    //END---registerCell

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
        if AudioDataArray.count != 0 {
            //idが最大のaudioData(最新のaudioData)を取得
            let audioData = maxIdAudioData()
            //alert作成
            let alert = UIAlertController(title: "タイトルを入力", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "新規録音"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                let textField = alert.textFields![0]
                //audioDataを保存
                try! self.realm.write {
                    if textField.text == "" {
                        audioData.titile = "新規録音#\(self.AudioDataArray.count)"
                    } else {
                        audioData.titile = textField.text!
                    }
                    self.tableView.reloadData()
                }
            }))
            present(alert, animated: true, completion: nil)
        } else {
            displayAlert(title: "録音なし", message: "")
        }
    }
    //START---maxIdAudioData---
    func maxIdAudioData() -> AudioData {
        var audioData: AudioData!
        var maxId = 0
        for ad in AudioDataArray {
            if maxId <= ad.id {
                maxId = ad.id
                audioData = ad
            }
        }
        return audioData
    }
    //END---maxIdAudioData---
    
    //START---displayAlert---
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    //END---displaaAlert---
    
    //START---TableView編集系メソッド---
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.isEditing = editing
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
    //並び替え系
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            let sourceAD: AudioData = AudioDataArray[sourceIndexPath.row]
            let destinationAD: AudioData = AudioDataArray[destinationIndexPath.row]
            let destinationADOrder = destinationAD.order
            
            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let ad = AudioDataArray[index]
                    ad.order += 1
                }
            } else {
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                    let ad = AudioDataArray[index]
                    ad.order -= 1
                }
            }
            sourceAD.order = destinationADOrder
        }
    }
    //EMD---TableView編集系メソッド---
}

//START---TableViewDataSource---
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AudioDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell else {
            return UITableViewCell(frame: .zero)
        }
        cell.setUp(delegate: self as CustomCellDelegate, dataSource: AudioDataArray[indexPath.row])
        return cell
    }
}
//END---TableViewDataSource---
//START---TableViewDelegate---
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //選択中を解除するための処理
        tableView.deselectRow(at: indexPath, animated: true)
        
        try! realm.write {
            //セルのexpandViewの開いているのは1つにする
            for (index, ad) in AudioDataArray.enumerated() {
                //expandViewが開いていれば閉じる
                if ad.isClosed == false {
                    ad.isClosed = true
                } else {
                    //didSelectしてcellの場合のみ、expandViewが閉じていたら開く
                    if index == indexPath.row {
                        ad.isClosed = false
                    }
                }
            }
        }
        tableView.reloadData()
    }
}
//START---CustomCellDelegate
extension ViewController: CustomCellDelegate {
    func handlePlayButton(message: String) {
        var audioData: AudioData?
        //cellのexpandViewが開いているAudioDataを取得する(開いているのが出力するものだから)
        for ad in AudioDataArray {
            if ad.isClosed == false {
                audioData = ad
            }
        }
        if audioData != nil {
            //録音データの保存されてるURLを取得
            let url = getURL().appendingPathComponent("\(audioData!.id).m4a")
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
    }
}
//END---CustomCellDelegate

//END---TableViewDelegate---

    /*
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
        //選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
        print("DEBUG_PRINT: ID\(audioData.id), order\(audioData.order)")
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    //END---TableView系メソッド---
    */

