//
//  ViewController.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2019/08/27.
//  Copyright © 2019 ShuyaYamada. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    //Data関係
    let realm = try! Realm()
    var memoDataArray = try! Realm().objects(MemoData.self).sorted(byKeyPath: "order", ascending: false)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationControllerの設定
        self.navigationController?.isToolbarHidden = false
        navigationItem.title = "VoiceMemo"
        navigationItem.leftBarButtonItem = editButtonItem

        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    //START---setEditing---
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.isEditing = editing
    }
    //END---setEditiing---
    
    //START---TableViewCell削除---
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //memoDataを取得
            let memoData = memoDataArray[indexPath.row]
            
            //録音データの保存されているURLを取得
            if memoData.audioDatas.count != 0 {
                for ad in memoData.audioDatas {
                    let url = getURL().appendingPathComponent("\(ad.id).m4a")
                    try! FileManager.default.removeItem(at: url)
                    try! self.realm.write {
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
    func getURL() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = path[0]
        return url
    }
    //END---TableViewCell削除---
    
    //START---TableViewCell---
    
}

//START---TableViewDataSource---
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let memoData = memoDataArray[indexPath.row]
        cell.textLabel?.text = memoData.title
        return cell
    }
}
//END---TableViewDataSource---

//START---TableViewDelegate---
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //遷移先のDetailViewControllerを取得
        let detailViewController = segue.destination as! DetailViewController
        //新規作成・編集のそれぞれに合わせた処理をする
        if segue.identifier == "cellSegue" {
        //既存データを渡す
            let indexPath = self.tableView.indexPathForSelectedRow
            try! realm.write {
                detailViewController.memoData = memoDataArray[indexPath!.row]
            }
        } else {
        //新規作成
            try! realm.write {
                let memoData = MemoData()
                let allMemoData = realm.objects(MemoData.self)
                if allMemoData.count != 0 {
                    memoData.id = allMemoData.max(ofProperty: "id")! + 1
                    memoData.order = allMemoData.max(ofProperty: "order")! + 1
                }
                detailViewController.memoData = memoData
                realm.add(memoData)
            }
        }
    }
}
//END---TableViewDelegate---
