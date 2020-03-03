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

    @IBOutlet var recordingNameTextField: UITextField!
    @IBOutlet var recordingContentTextView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        recordingNameTextField.text = audioData.titile
    }

    // MARK: - ViewDidDisappear with AudioData updating

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        do {
            try realm.write {
                if recordingNameTextField.text == "" {
                    audioData.titile = "Audio Data"
                } else {
                    audioData.titile = recordingNameTextField.text!
                }
            }
        } catch {
            print("DEBUG_ERROR: AudioData Update")
        }
    }

    @IBAction func PlayAndPouseButtonPressed(_: UIButton) {}

    @IBAction func skipButtonPressed(_: UIButton) {}

    @IBAction func rewindButtonPressed(_: UIButton) {}
}
