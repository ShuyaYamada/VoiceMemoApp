//
//  FolderViewController.swift
//  RefactoringVoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/01.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import UIKit
import RealmSwift

class FolderViewController: UIViewController {
    
    let realm = try! Realm()
    var memoDataPrimaryKey: Int?
    var memoData: MemoData = MemoData()
    var sortedAudioDatas: Results<AudioData> {
        memoData.audioDatas.sorted(byKeyPath: "order", ascending: false)
    }
    var documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var folderTitleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        folderTitleTextField.delegate = self
        contentTextView.delegate = self
        
        navigationItem.rightBarButtonItem = editButtonItem
        setupToolBar()
        
        if let data = realm.object(ofType: MemoData.self, forPrimaryKey: memoDataPrimaryKey) {
            memoData = data
        }
        folderTitleTextField.text = memoData.title
        contentTextView.text = memoData.content
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }
    
    
    //MARK: - View Will Disappear with update data
    override func viewWillDisappear(_ animated: Bool) {
        do {
            try realm.write {
                if folderTitleTextField.text == "" {
                    memoData.title = "Folder"
                } else {
                    memoData.title = folderTitleTextField.text!
                }
                memoData.content = contentTextView.text
                realm.add(memoData)
            }
        } catch {
            print("DEBUG_ERROR: MemoData Update")
        }
    }
}


//MARK: - Destination Record or Play ViewController
extension FolderViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tappedRecordingSegue" {
            //playVCへの遷移
            
        } else {
            //recordVCへの遷移
            do {
                try realm.write {
                    let audioData = AudioData()
                    if memoData.audioDatas.count != 0 {
                        audioData.id = memoData.audioDatas.max(ofProperty: "id")! + 1
                        audioData.order = memoData.audioDatas.max(ofProperty: "order")!
                    } else {
                        audioData.id = Int("\(memoData.id)\(memoData.id)\(audioData.id)")!
                    }
                    memoData.audioDatas.append(audioData)
                    let recordVC = segue.destination as! RecordViewController
                    recordVC.audioData = audioData
                    tableView.reloadData()
                }
            } catch {
                print("DEBUG_ERROR: 新規AudioData作成時")
            }
        }
    }
}



//MARK: - TableView DataSouce
extension FolderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedAudioDatas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as! RecordingTableViewCell
       // memoData.audioDatas.sorted(byKeyPath: "order", ascending: false)
        cell.recordingName.text = sortedAudioDatas[indexPath.row].titile
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: sortedAudioDatas[indexPath.row].date)
        cell.dateLabel.text = dateString
        
        //cell.recordingTimeLabel.text = sortedAudioDatas[indexPath.row]. AudioDataにTimeLabelを追加したら
        return cell
    }
}


//MARK: - TableView Dlegate
extension FolderViewController: UITableViewDelegate {
    
    //MARK: - TableViewCell Tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "tappedRecordingSegue", sender: nil)
    }
    
    
    //MARK: - TableViewCell Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let audioData = sortedAudioDatas[indexPath.row]
            
            do {
                //let url = documentPath.appendingPathComponent("\(audioData.id).m4a")
                //try FileManager.default.removeItem(at: url)
                try realm.write {
                    realm.delete(audioData)
                }
            } catch {
                print("DEBUG_ERROR: TableViewCell Delete時")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    
    //MARK: - TableViewCell Move
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        do {
            try realm.write {
                let sourceAD: AudioData = sortedAudioDatas[sourceIndexPath.row]
                let destinationAD = sortedAudioDatas[destinationIndexPath.row]
                let destinationADOrder = destinationAD.order
                if sourceIndexPath.row < destinationIndexPath.row {
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        let ad = sortedAudioDatas[index]
                        ad.order += 1
                    }
                } else {
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                        let ad = sortedAudioDatas[index]
                        ad.order -= 1
                    }
                }
                sourceAD.order = destinationADOrder
                tableView.reloadData()
            }
        } catch {
            print("DEBUG_ERRPR: TableViewCell 移動時")
        }
    }
}


//MARK: - TextField, TextViewのKeybordの設定
extension FolderViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true

    }
    
    func setupToolBar() {
        // ツールバー生成
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        // スタイルを設定
        toolBar.barStyle = UIBarStyle.default
        // 画面幅に合わせてサイズを変更
        toolBar.sizeToFit()
        // 閉じるボタンを右に配置するためのスペース?
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(commiButtonTapped))
        // スペース、閉じるボタンを右側に配置
        toolBar.items = [spacer, commitButton]
        // textViewのキーボードにツールバーを設定
        contentTextView.inputAccessoryView = toolBar
    }
    @objc func commiButtonTapped() {
        self.view.endEditing(true)
    }
}
