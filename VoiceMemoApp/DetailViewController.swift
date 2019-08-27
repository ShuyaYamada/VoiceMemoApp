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

class DetailViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    //AVAudio系の変数
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    //Data関係
    let realm = try! Realm()
    var memoData: MemoData!
    
    //IBOutlet
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var buttonImage: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //START---Start Record and Stop Record---
    @IBAction func record(_ sender: Any) {
        //編集モード時には実行しない
        if tableView.isEditing == false {
            if audioRecorder == nil {
            //録音開始の処理
                //audioDataを作成
                let audioData = AudioData()
                audioData.date = Date()
                
                //audioDataが1つ以上ならidとorderを+1する
                if memoData.audioDatas.count != 0 {
                    audioData.id = memoData.audioDatas.max(ofProperty: "id")! + 1
                    audioData.order = memoData.audioDatas.max(ofProperty: "order")! + 1
                } else {
                    audioData.id = Int("\(memoData.id)\(memoData.id)\(audioData.id)")!
                }
                
                //memoDataのaudioDatasに作成したaudioDataを追加
                try! realm.write {
                    memoData.audioDatas.append(audioData)
                }
                
                //保存先URLを取得
                let failName = getURL().appendingPathComponent("\(audioData.id).m4a")
                //recorderに必要なsettingsを取得
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                //Record Start
                do {
                    //recorderをインスタンス化
                    audioRecorder = try AVAudioRecorder(url: failName, settings: settings)
                    audioRecorder.delegate = self
                    audioRecorder.record()
                    
                    //ボタンのimageを変更
                    buttonImage.setImage(UIImage(named: "stopBTN"), for: .normal)
                } catch {
                    print("DEBUG_PRINT: 録音失敗")
                    displayAlert(title: "Error", message: "Recording failed")
                }
            } else {
            //録音完了の処理
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
        
        //ViewControllerから受け取ったmemoDataをUIに反映
        titleTextField.text = memoData.title
        contentTextView.text = memoData.content
    }
    //END---viewDidLoad---
    //START---viewWill Appear and Disappear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
        //画面を離れるときにmemoDataを保存する
            self.memoData.title = titleTextField.text!
            self.memoData.content = contentTextView.text
            self.realm.add(memoData)
        }
    }
    //END---viewWill Appear and Disappear
    
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
        if memoData.audioDatas.count != 0 {
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
                        //textFieldが空ならば「新規録音#」をtitleに与える
                        audioData.titile = "新規録音#\(self.memoData.audioDatas.count)"
                    } else {
                        audioData.titile = textField.text!
                    }
                }
                self.tableView.reloadData()

            }))
            present(alert, animated: true, completion: nil)
        } else {
            displayAlert(title: "録音なし", message: "")
        }
    }
    //END---inputAlert---
    
    //START---maxIdAudioData---
    func maxIdAudioData() -> AudioData {
        var audioData: AudioData!
        var maxId = 0
        //for文でidを最大のものを取り出す
        for ad in memoData.audioDatas {
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
    
    //START---setEditing---
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.isEditing = editing
    }
    //END---setEditing---
    
    //START---TableViewCell削除---
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //audioDataを取得
            let sortedDatas = memoData.audioDatas.sorted(byKeyPath: "order", ascending: false)
            let audioData = sortedDatas[indexPath.row]
            
            //録音データの保存されてるURLを取得
            let url = getURL().appendingPathComponent("\(audioData.id).m4a")
            //録音データを削除
            try! FileManager.default.removeItem(at: url)
            //realmのaudioDataを削除
            try! realm.write {
                realm.delete(audioData)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    //END---TableViewCell削除---
    //START---TableViewCell並べ替え---
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sortedDatas = memoData.audioDatas.sorted(byKeyPath: "order", ascending: false)
        try! realm.write {
            let sourceAD: AudioData = sortedDatas[sourceIndexPath.row]
            let destinationAD: AudioData = sortedDatas[destinationIndexPath.row]
            let destinationADOrder = destinationAD.order
            
            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let ad = sortedDatas[index]
                    ad.order += 1
                }
            } else {
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                    let ad = sortedDatas[index]
                    ad.order -= 1
                }
            }
            sourceAD.order = destinationADOrder
        }
        tableView.reloadData()
    }
    //END---TableViewCell並べ替え---
}

//START---TableViewDataSource---
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memoData.audioDatas.count != 0 {
            let sortedDatas = memoData.audioDatas.sorted(byKeyPath: "order", ascending: false)
            return sortedDatas.count
        } else {
            return memoData.audioDatas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell else {
            return UITableViewCell(frame: .zero)
        }
        if memoData.audioDatas.count != 0 {
            let sortedDatas = memoData.audioDatas.sorted(byKeyPath: "order", ascending: false)
            cell.setUp(delegate: self as CustomCellDelegate, dataSource: sortedDatas[indexPath.row])
        } else {
            cell.setUp(delegate: self as CustomCellDelegate, dataSource: memoData.audioDatas[indexPath.row])
        }
        return cell
    }
}
//END---TableViewDataSource---

//START---TableViewDelegate---
extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //選択中を解除するための処理
        tableView.deselectRow(at: indexPath, animated: true)
        
        try! realm.write {
            //セルのexpandViewの開いているのは1つにする
            let sortedDatas = memoData.audioDatas.sorted(byKeyPath: "order", ascending: false)
            for (index, ad) in sortedDatas.enumerated() {
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
//END---TableViewDelegate---

//START---CustomCellDelegate
extension DetailViewController: CustomCellDelegate {
    func handlePlayButton(message: String) {
        var audioData: AudioData?
        //cellのexpandViewが開いているAudioDataを取得する(開いているのが出力するものだから)
        for ad in memoData.audioDatas {
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
