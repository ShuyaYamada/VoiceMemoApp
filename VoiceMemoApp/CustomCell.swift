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
    func handleSpeedButton()
    func handleEditButton()
}


class CustomCell: UITableViewCell, AVAudioPlayerDelegate {
    private var delegate: CustomCellDelegate?
    private var dataSource: AudioData?
    
    var audioPlayer: AVAudioPlayer!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playSlider: UISlider!
    @IBOutlet weak var audioDurationLabel: UILabel!
    @IBOutlet weak var audioDurationProgressLabel: UILabel!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var expandView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        playButton.isExclusiveTouch = true
    }
    
    func setUp(delegate: CustomCellDelegate, dataSource: AudioData) {
        self.delegate = delegate
        self.dataSource = dataSource
        
        audioPlayerDif()
        audioPlayer.delegate = self
        
        titleLabel.text = dataSource.titile
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: dataSource.date)
        dateLabel.text = dateString
        expandView.isHidden = dataSource.isClosed
        audioDurationProgressLabel.text = "00:00"
        playSlider.setThumbImage(UIImage(named: "Thumb"), for: .normal)
        
        let sliderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(slideCount(_:)), userInfo: nil, repeats: true)
        let durationTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timeCount(_:)), userInfo: nil, repeats: true)
        
        if dataSource.isClosed == true {
            playButton.setImage(UIImage(named: "playing"), for: .normal)
            editButton.isEnabled = true
        }
    }
    
    func getURL() -> URL {
        //録音データの保存先URLの先頭部分。 このURL+AudioDataのidで識別する。
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = path[0]
        return url
    }
    
    func audioPlayerDif() {
        let url = getURL().appendingPathComponent("\(dataSource!.id).m4a")
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            
            //録音の時間関係に必要なAudioFileとsampleRateを取得
            let audioFile = try AVAudioFile(forReading: url)
            let sampleRate = audioFile.fileFormat.sampleRate
            //分・秒を取得
            let duration: Double = floor(Double(audioFile.length) / sampleRate)
            let min: Double = floor(duration / 60)
            let sec: Double = duration - (min * 60)
            //audioDataの再生時間をlabelに表示
            audioDurationLabel.text = "\(Int(min)):\(Int(sec))"
            //sliderのmaxを再生時間に設定
            playSlider.maximumValue = Float(audioPlayer.duration)
        } catch {
            print("error")
        }
    }

    @IBAction func handlePlayButton(_ sender: Any) {
        if audioPlayer.isPlaying == true {
            audioPlayer.pause()
            playButton.setImage(UIImage(named: "playing"), for: .normal)
            
            editButton.isEnabled = true
        } else {
            audioPlayer.enableRate = true
            audioPlayer.play()
            playButton.setImage(UIImage(named: "stop"), for: .normal)
            
            editButton.isEnabled = false
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(named: "playing"), for: .normal)
        editButton.isEnabled = true
    }
    
    @IBAction func playSliderController(_ sender: Any) {
        audioPlayer.currentTime = TimeInterval(playSlider.value)
    }
    
    @objc func slideCount(_ timer: Timer!) {
        playSlider.value = Float(audioPlayer.currentTime)
    }
    
    @objc func timeCount(_ timer: Timer!) {
        let min = floor(audioPlayer.currentTime / 60)
        let sec = audioPlayer.currentTime - (min * 60)
        if sec < 10 {
            audioDurationProgressLabel.text = "0\(Int(min)):0\(Int(sec))"
        } else if sec >= 10 && min < 10 {
            audioDurationProgressLabel.text = "0\(Int(min)):\(Int(sec))"
        } else {
            audioDurationProgressLabel.text = "\(Int(min)):\(Int(sec))"
        }
    }
    @IBAction func handleSpeedButton(_ sender: Any) {
        switch audioPlayer.rate {
        case 1.0:
            self.audioPlayer.rate = 1.5
            speedButton.setTitle("1.5倍速", for: .normal)
            print("DEBUG: \(audioPlayer.rate)")
        case 1.5:
            self.audioPlayer.rate = 2.0
            speedButton.setTitle("2.0倍速", for: .normal)
            print("DEBUG: \(audioPlayer.rate)")
        default:
            self.audioPlayer.rate = 1.0
            speedButton.setTitle("1.0倍速", for: .normal)
            print("DEBUG: \(audioPlayer.rate)")
        }
    }
    
    @IBAction func handleEditButton(_ sender: Any) {
        delegate?.handleEditButton()
    }
}

