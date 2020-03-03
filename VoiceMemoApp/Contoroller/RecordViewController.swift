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
    var audioDataBrain = AudioDataBrain()

    @IBOutlet var recordingTitleTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var isRecordLabel: UILabel!
    @IBOutlet var recordingButton: UIButton!
    @IBOutlet var currentTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        recordingTitleTextField.text = audioData.titile
    }

    // MARK: - ViewDidDisappear with AudioData updating

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioDataBrain.saveTitle(title: recordingTitleTextField.text!, data: audioData)
    }

    @IBAction func recordingButtonPressed(_: UIButton) {}
}
