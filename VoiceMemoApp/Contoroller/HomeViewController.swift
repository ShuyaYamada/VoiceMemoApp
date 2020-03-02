//
//  HomeViewController.swift
//  RefactoringVoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/01.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    
    let realm = try! Realm()
    var memoDataArray = try! Realm().objects(MemoData.self).sorted(byKeyPath: "order", ascending: false)
    var documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }
    
    //MARK: - AddButton Method
    @IBAction func AddButtonPressed(_ sender: UIButton) {
        print("Add Button Pressed")
        
        do {
            try realm.write {
                let memoData = MemoData()
                let allMemoData = realm.objects(MemoData.self)
                if allMemoData.count != 0 {
                    memoData.id = allMemoData.max(ofProperty: "id")! + 1
                }
                realm.add(memoData)
            }
        } catch {
            print("DEBUG_ERROR: 新規フォルダー作成時")
        }
    }
}

//MARK: - TableView DataSouce
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! FolderCell
        
        cell.folderNameLabel.text = memoDataArray[indexPath.row].title
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    
    //MARK: - TableViewCell Tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "tappedCellSegue", sender: nil)
    }
    
    //MARK: - TableViewCell Delete Method
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("Cell Delete")
        if editingStyle == .delete {
            
            let memoData = memoDataArray[indexPath.row]
            
            for audioData in memoData.audioDatas {
                do {
                    let url = documentPath.appendingPathComponent("\(audioData.id).m4a")
                    try FileManager.default.removeItem(at: url)
                    try self.realm.write {
                        realm.delete(audioData)
                    }
                } catch {
                    print("DEBUG_ERROR: セル消去時")
                }
            }
            
            do {
                try realm.write {
                    realm.delete(memoData)
                }
            } catch {
                print("DEBUG_ERROR: セル消去時")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    //MARK: - TableViewCell Move Method
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceMD = memoDataArray[sourceIndexPath.row]
        let destinationMD = memoDataArray[destinationIndexPath.row]
        let destinationMDOrder = destinationMD.order
        
        try! realm.write {
            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let md = memoDataArray[index]
                    md.order += 1
                }
            } else {
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                    let md = memoDataArray[index]
                    md.order -= 1
                }
            }
            sourceMD.order = destinationMDOrder
        }
        tableView.reloadData()
    }
}
