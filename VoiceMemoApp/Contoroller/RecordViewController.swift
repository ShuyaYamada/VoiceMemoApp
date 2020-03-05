//
//  RecordViewController.swift
//  RefactoringVoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/01.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import RealmSwift
import UIKit

class RecordViewController: UIViewController {
    var audioData: AudioData!
    private let audioDataBrain = AudioDataBrain()
    private let audioManager = AudioManager()
    private let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var url: URL?
    private var isRecord = false
    private var isPermission = false
    private var counter = 0
    private var timer = Timer()

    @IBOutlet var recordingTitleTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var isRecordLabel: UILabel!
    @IBOutlet var recordingButton: UIButton!
    @IBOutlet var currentTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        recordingTitleTextField.delegate = self
        contentTextView.delegate = self
        setupToolBar()

        isPermission = audioManager.isRecordPermission()
        url = documentPath.appendingPathComponent("\(audioData.id).m4a")
        recordingTitleTextField.text = audioData.titile

        startRecord()
    }

    // MARK: - ViewDidDisappear with AudioData updating

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioDataBrain.saveTitle(title: recordingTitleTextField.text!, data: audioData)
        audioManager.soundRecordEnd()
    }

    @IBAction func recordingButtonPressed(_: UIButton) {
        if isRecord {
            audioManager.stopRecord()
            isRecord = false
            recordingButton.setImage(UIImage(named: "MicButton"), for: .normal)
            isRecordLabel.isHidden = true
            audioManager.soundRecordEnd()
            timer.invalidate()
        } else {
            startRecord()
        }
    }

    func startRecord() {
        audioManager.record(url: url!)
        isRecord = true
        recordingButton.setImage(UIImage(named: "StopButton"), for: .normal)
        isRecordLabel.isHidden = false
        audioManager.soundRecordStarted()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        counter = 0
        currentTimeLabel.text = String(counter)
    }

    @objc func UpdateTimer() {
        counter = counter + 1
        currentTimeLabel.text = String(counter)
    }
}

// MARK: - TextField, TextViewのKeybordの設定

extension RecordViewController: UITextFieldDelegate, UITextViewDelegate {
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
