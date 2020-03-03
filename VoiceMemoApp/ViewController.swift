//
//  ViewController.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2019/08/27.
//  Copyright © 2019 ShuyaYamada. All rights reserved.
//

import RealmSwift
import UIKit

class ViewController: UIViewController {
    // Data関係
    let realm = try! Realm()
    var memoDataArray = try! Realm().objects(MemoData.self).sorted(byKeyPath: "order", ascending: false)

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // navigationControllerの設定
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.isToolbarHidden = false
        navigationItem.title = "フォルダ一覧"
        navigationItem.leftBarButtonItem = editButtonItem
        navigationController?.navigationBar.tintColor = UIColor.white

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }

    // START---setEditing---
    override func setEditing(_ editing: Bool, animated _: Bool) {
        super.setEditing(editing, animated: true)
        tableView.isEditing = editing
    }

    func getURL() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = path[0]
        return url
    }
}

// MARK: - TableView DataSource Methods

extension ViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return memoDataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let memoData = memoDataArray[indexPath.row]
        cell.textLabel?.text = memoData.title
        return cell
    }
}

// MARK: - TableView Delegate Methods

extension ViewController: UITableViewDelegate {
    // MARK: - Delete Cell

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // memoDataを取得
            let memoData = memoDataArray[indexPath.row]

            // 録音データの保存されているURLを取得
            if memoData.audioDatas.count != 0 {
                for ad in memoData.audioDatas {
                    let url = getURL().appendingPathComponent("\(ad.id).m4a")
                    try! FileManager.default.removeItem(at: url)
                    try! realm.write {
                        realm.delete(ad)
                    }
                }
            }
            try! realm.write {
                realm.delete(memoData)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }

    // MARK: - Destination DetailView

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        // 遷移先のDetailViewControllerを取得
        let detailViewController = segue.destination as! DetailViewController
        // 新規作成・編集のそれぞれに合わせた処理をする
        if segue.identifier == "cellSegue" {
            // 既存データを渡す
            let indexPath = tableView.indexPathForSelectedRow
            try! realm.write {
                // detailViewController.memoData = memoDataArray[indexPath!.row]
            }
        } else {
            try! realm.write {
                let memoData = MemoData()
                let allMemoData = realm.objects(MemoData.self)
                if allMemoData.count != 0 {
                    memoData.id = allMemoData.max(ofProperty: "id")! + 1
                    memoData.order = allMemoData.max(ofProperty: "order")! + 1
                }
                // detailViewController.memoData = memoData
                realm.add(memoData)
            }
        }
    }

    // MARK: - Move Cell

    func tableView(_: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceMD = memoDataArray[sourceIndexPath.row]
        let destinationMD = memoDataArray[destinationIndexPath.row]
        let destinationMDOrder = destinationMD.order

        try! realm.write {
            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row ... destinationIndexPath.row {
                    let md = memoDataArray[index]
                    md.order += 1
                }
            } else {
                for index in (destinationIndexPath.row ..< sourceIndexPath.row).reversed() {
                    let md = memoDataArray[index]
                    md.order -= 1
                }
            }
            sourceMD.order = destinationMDOrder
        }
        tableView.reloadData()
    }
}
