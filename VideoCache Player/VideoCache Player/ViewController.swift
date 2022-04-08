//
//  ViewController.swift
//  VideoCache Player
//
//  Created by DREAMWORLD on 08/04/22.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var PlayPauseBTN: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var viewSlider: UISlider!
    var player: AVPlayer?
    var videoString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
    var videoURL : URL?
    var isPlayed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //play pause button setup
        PlayPauseBTN.layer.cornerRadius = 8
        view.bringSubviewToFront(PlayPauseBTN)
        
        //set slider initial value
        self.viewSlider.value = 0
        
        CacheManager.shared.getFileWith(stringUrl: videoString) { success, path, message in
            DispatchQueue.main.async {
                if success{
                    self.videoURL = path
                    self.addPlayerToView(self.videoContainerView)
                }else{
                    self.alert(msg: message)
                }
            }

        }
        
       
    }

    //MARK: - Play Replay Button Action
    @IBAction func PlayReplyButtonAction(_ sender: UIButton) {
        self.player?.seek(to: .zero)
        self.play()
    }
    
    //MARK: -  Play Pause Button Action
    @IBAction func PlayPauseButton(_ sender: UIButton) {
        if isPlayed{
            pause()
        }else{
            play()
        }
    }
    
    //MARK: - Slider Value Changed
    @IBAction func SliderValueChanged(_ sender: UISlider) {
        let senderValue : Double = Double(sender.value)
        let totalTime = Double(self.player?.currentItem?.duration.seconds ?? 0)
        let currentTime = senderValue * totalTime
        let targetTime:CMTime = CMTimeMake(value: Int64(currentTime), timescale: 1)
        
        player!.seek(to: targetTime)
        if player!.rate == 0
        {
            player?.play()
        }
    }
    
    fileprivate func addPlayerToView(_ view: UIView) {
        player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = videoContainerView.bounds
        videoContainerView.layer.addSublayer(playerLayer)
        play()
        
        player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main, using: { time in
            
            let totalDuration: String = secondsToHoursMinutesSeconds(Int(self.player?.currentItem?.duration.seconds ?? 0))
            self.totalTimeLabel.text = totalDuration
            
            let duration: String = secondsToHoursMinutesSeconds(Int(time.seconds))
            self.timeLabel.text = duration
            
            let total = Float(self.player?.currentItem?.duration.seconds ?? 0)
            let current = Float(time.seconds)
            let curVal = current / total
            self.viewSlider.value = curVal
        })
       }
    
    //player play function
    func play(){
        isPlayed = true
        player?.play()
        PlayPauseBTN.setImage(UIImage.init(systemName: "pause.fill"), for: .normal)
    }
    
    //player pause function
    func pause(){
        isPlayed = false
        player?.pause()
        PlayPauseBTN.setImage(UIImage.init(systemName: "play.fill"), for: .normal)
    }
    
    func alert(msg:String){
        let alert = UIAlertController(title: "Video Cache Player", message: msg, preferredStyle: .alert)
        let ohkAction = UIAlertAction(title: "OK", style: .default) { _Arg in
            //
        }
        alert.addAction(ohkAction)
        self.present(alert, animated: true, completion: nil)
    }
}

func secondsToHoursMinutesSeconds(_ seconds: Int) -> String {
    //Hour format
    var hour = "\(seconds / 3600)"
    if !(hour.count > 1){
        hour = "0\(hour)"
    }
    
    //Minutes format
    var minute = "\((seconds % 3600) / 60)"
    if !(minute.count > 1){
        minute = "0\(minute)"
    }
    
    //Seconds format
    var second = "\((seconds % 3600) % 60)"
    if !(second.count > 1){
        second = "0\(second)"
    }
    return "\(hour):\(minute):\(second)"
}
