//
//  PlayViewController.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/03.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import RealmSwift
import UIKit

class PlayViewController: UIViewController {
    private let realm = try! Realm()
    var audioData: AudioData!
    var audioDataBrain = AudioDataBrain()

    @IBOutlet var recordingTitleTextField: UITextField!
    @IBOutlet var recordingContentTextView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        recordingTitleTextField.delegate = self
        recordingContentTextView.delegate = self
        setupToolBar()

        recordingTitleTextField.text = audioData.titile
    }

    // MARK: - ViewDidDisappear with AudioData updating

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioDataBrain.saveTitle(title: recordingTitleTextField.text!, data: audioData)
    }

    @IBAction func PlayAndPouseButtonPressed(_: UIButton) {}

    @IBAction func skipButtonPressed(_: UIButton) {}

    @IBAction func rewindButtonPressed(_: UIButton) {}
}

// MARK: - TextField, TextViewのKeybordの設定

extension PlayViewController: UITextFieldDelegate, UITextViewDelegate {
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
        recordingContentTextView.inputAccessoryView = toolBar
    }

    @objc func commiButtonTapped() {
        view.endEditing(true)
    }
}
