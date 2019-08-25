//
//  CustomCell.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2019/08/25.
//  Copyright © 2019 ShuyaYamada. All rights reserved.
//

import UIKit

protocol CustomCellDelegate {
    func handlePlayButton(message: String)
}

class CustomCell: UITableViewCell {
    private var delegate: CustomCellDelegate?
    private var dataSource: AudioData?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var expandView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        playButton.isExclusiveTouch = true
    }
    
    func setUp(delegate: CustomCellDelegate, dataSource: AudioData) {
        self.delegate = delegate
        self.dataSource = dataSource
        
        titleLabel.text = dataSource.titile
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: dataSource.date)
        dateLabel.text = dateString
        expandView.isHidden = dataSource.isClosed
    }

    @IBAction func handlePlayButton(_ sender: Any) {
        if let title = dataSource?.titile {
            delegate?.handlePlayButton(message: "\(title)のボタンを押しました")
        }
    }
    
}
