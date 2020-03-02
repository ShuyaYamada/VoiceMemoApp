//
//  RecordingTableViewCell.swift
//  RefactoringVoiceMemoApp
//
//  Created by ShuyaYamada on 2020/03/01.
//  Copyright © 2020 ShuyaYamada. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var recordingName: UILabel!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
