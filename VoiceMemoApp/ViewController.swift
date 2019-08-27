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
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
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
