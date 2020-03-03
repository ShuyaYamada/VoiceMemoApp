//
//  FolderViewController.swift
//  RefactoringVoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/01.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import RealmSwift
import UIKit

class FolderViewController: UIViewController {
    let memoDataBrain = MemoDataBrain()
    let audioDataBrain = AudioDataBrain()
    var memoDataPrimaryKey: Int?
    private var memoData: MemoData = MemoData()
    var sortedAudioDatas: Results<AudioData> {
        memoData.audioDatas.sorted(byKeyPath: "order", ascending: false)
    }

    var documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    @IBOutlet var tableView: UITableView!
    @IBOutlet var folderTitleTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!

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

        memoData = memoDataBrain.getMemoData(primaryKey: memoDataPrimaryKey)

        folderTitleTextField.text = memoData.title
        contentTextView.text = memoData.content
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }

    // MARK: - View Will Disappear with update data

    override func viewWillDisappear(_: Bool) {
        let title = folderTitleTextField.text!
        let content = contentTextView.text!
        memoDataBrain.saveTitle(data: memoData, title: title, content: content)
    }
}

// MARK: - Destination Record or Play ViewController

extension FolderViewController {
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "tappedRecordingSegue" {
            // playVCへの遷移
            let playVC = segue.destination as! PlayViewController
            let indexPath = tableView.indexPathForSelectedRow
            playVC.audioData = sortedAudioDatas[indexPath!.row]
        } else {
            // recordVCへの遷移
            let recordVC = segue.destination as! RecordViewController
            recordVC.audioData = memoDataBrain.addNewAudioData(data: memoData)
            tableView.reloadData()
        }
    }
}

// MARK: - TableView DataSouce

extension FolderViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return sortedAudioDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as! RecordingTableViewCell
        cell.recordingName.text = sortedAudioDatas[indexPath.row].titile

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: sortedAudioDatas[indexPath.row].date)
        cell.dateLabel.text = dateString

        // cell.recordingTimeLabel.text = sortedAudioDatas[indexPath.row]. AudioDataにTimeLabelを追加したら
        return cell
    }
}

extension FolderViewController: UITableViewDelegate {
    // MARK: - TableViewCell Tapped

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        performSegue(withIdentifier: "tappedRecordingSegue", sender: nil)
    }

    // MARK: - TableViewCell Delete

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let audioData = sortedAudioDatas[indexPath.row]

            do {
                // let url = documentPath.appendingPathComponent("\(audioData.id).m4a")
                // try FileManager.default.removeItem(at: url)
                audioDataBrain.delete(data: audioData)
            } catch {
                print("DEBUG_ERROR: TableViewCell Delete時")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }

    // MARK: - TableViewCell Move

    func tableView(_: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceAD: AudioData = sortedAudioDatas[sourceIndexPath.row]
        let destinationAD = sortedAudioDatas[destinationIndexPath.row]
        let destinationADOrder = destinationAD.order

        if sourceIndexPath.row < destinationIndexPath.row {
            let indexes = sourceIndexPath.row ... destinationIndexPath.row
            audioDataBrain.upOrder(datas: sortedAudioDatas, indexes: indexes, sourceData: sourceAD, destinationOrder: destinationADOrder)
        } else {
            let indexes = (destinationIndexPath.row ..< sourceIndexPath.row).reversed()
            audioDataBrain.downOrder(datas: sortedAudioDatas, indexes: indexes, sourceData: sourceAD, destinationOrder: destinationADOrder)
        }

        tableView.reloadData()
    }
}

// MARK: - TextField, TextViewのKeybordの設定

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
        view.endEditing(true)
    }
}
