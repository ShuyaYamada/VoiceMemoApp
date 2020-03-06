//
//  HomeViewController.swift
//  RefactoringVoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/01.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import RealmSwift
import UIKit

class HomeViewController: UIViewController {
    let memoDataBrain = MemoDataBrain()
    let audioDataBrain = AudioDataBrain()
    var memoDataArray: Results<MemoData>?
    var documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    @IBOutlet var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.title = NSLocalizedString("navigationBarTitleKey", comment: "")

        memoDataArray = memoDataBrain.getAllMemoData()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }

    // MARK: - Destination FolderVC

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        let folderVC = segue.destination as! FolderViewController

        // 既存データで遷移
        if segue.identifier == "tappedCellSegue" {
            let indexPath = tableView.indexPathForSelectedRow!
            folderVC.memoDataPrimaryKey = memoDataArray![indexPath.row].id

        } else {
            // 新規データで遷移
            folderVC.memoDataPrimaryKey = memoDataBrain.createNewMemoData()!.id
        }
    }
}

// MARK: - TableView DataSouce

extension HomeViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return memoDataArray!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! FolderCell

        cell.folderNameLabel.text = memoDataArray![indexPath.row].title
        return cell
    }
}

// MARK: - TableView Delegate

extension HomeViewController: UITableViewDelegate {
    // MARK: - TableViewCell Tapped

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        performSegue(withIdentifier: "tappedCellSegue", sender: nil)
    }

    // MARK: - TableViewCell Delete Method

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let memoData = memoDataArray![indexPath.row]

            for audioData in memoData.audioDatas {
                do {
                    // let url = documentPath.appendingPathComponent("\(audioData.id).m4a")
                    // try FileManager.default.removeItem(at: url)
                    audioDataBrain.delete(data: audioData)
                } catch {
                    print("DEBUG_ERROR: セル消去時")
                }
            }

            memoDataBrain.delete(data: memoData)

            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }

    // MARK: - TableViewCell Move Method

    func tableView(_: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceMD = memoDataArray![sourceIndexPath.row]
        let destinationMD = memoDataArray![destinationIndexPath.row]
        let destinationMDOrder = destinationMD.order

        if sourceIndexPath.row < destinationIndexPath.row {
            let indexes = sourceIndexPath.row ... destinationIndexPath.row
            memoDataBrain.upOrder(datas: memoDataArray!, indexes: indexes, sourceData: sourceMD, destinationOrder: destinationMDOrder)
        } else {
            let indexes = (destinationIndexPath.row ..< sourceIndexPath.row).reversed()
            memoDataBrain.downOrder(datas: memoDataArray!, indexes: indexes, sourceData: sourceMD, destinationOrder: destinationMDOrder)
        }
        tableView.reloadData()
    }
}
