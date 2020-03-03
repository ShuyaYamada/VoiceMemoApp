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
    var memoData: MemoData!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var folderTitleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    var recordings = ["testtesttesttesttesttesttesttesttesttest", "home", "pods", "ipad"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        folderTitleTextField.text = memoData.title
        contentTextView.text = memoData.content
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
        return recordings.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as! RecordingTableViewCell
        cell.recordingName.text = recordings[indexPath.row]
        return cell
    }
}


//MARK: - TableView Dlegate
extension FolderViewController: UITableViewDelegate {
    
    //MARK: - TableViewCell Tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "tappedRecordingSegue", sender: nil)
    }
}
