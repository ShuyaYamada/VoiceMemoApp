//
//  CustomCell.swift
//  VoiceMemoApp
//
//  Created by ShuyaYamada on 2019/08/25.
//  Copyright © 2019 ShuyaYamada. All rights reserved.
//

import UIKit
import AVFoundation

protocol CustomCellDelegate {
    func handlePlayButton(message: String)
}

class CustomCell: UITableViewCell, AVAudioPlayerDelegate {
    private var delegate: CustomCellDelegate?
    private var dataSource: AudioData?
    
    var audioPlayer: AVAudioPlayer!
    
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
        
        let url = getURL().appendingPathComponent("\(dataSource.id).m4a")
        audioPlayer = try! AVAudioPlayer(contentsOf: url)
        audioPlayer.delegate = self
     
        
        titleLabel.text = dataSource.titile
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: dataSource.date)
        dateLabel.text = dateString
        expandView.isHidden = dataSource.isClosed
    }
    
    func getURL() -> URL {
        //録音データの保存先URLの先頭部分。 このURL+AudioDataのidで識別する。
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = path[0]
        return url
    }

    @IBAction func handlePlayButton(_ sender: Any) {
        if audioPlayer.isPlaying == true {
            audioPlayer.pause()
            playButton.setImage(UIImage(named: "playing"), for: .normal)
        } else {
            audioPlayer.play()
            playButton.setImage(UIImage(named: "stop"), for: .normal)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(named: "playing"), for: .normal)
    }

}

