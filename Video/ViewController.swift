//
//  ViewController.swift
//  Video
//
//  Created by Auriga on 27/09/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var PauseButton: UIButton!
    @IBOutlet weak var VideoTime: UILabel!
    @IBOutlet weak var VideoCurrentTime: UILabel!
    @IBOutlet weak var VideoSlider: UISlider!
    
    var playerLayer = AVPlayerLayer()
    var player : AVPlayer?
    var indicator = UIActivityIndicatorView()
    var isplaying = false
    var seconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo()
        activityIndicator()
        indicator.startAnimating()
        VideoView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(fastfarword))
        tap.numberOfTapsRequired = 2
        VideoView.addGestureRecognizer(tap)
    }
    
    @objc func fastfarword(touch: UITapGestureRecognizer) {
        let touchPoint = touch.location(in: self.view)
        var value = seconds - 5
        if touchPoint.x > VideoTime.center.x / 2 {
            value = seconds + 5
        }
        if value < 0 { value = 0 }
        let seektime = CMTime(value: Int64(value), timescale: 1)
        player?.seek(to: seektime, toleranceBefore: seektime, toleranceAfter: seektime, completionHandler: { (seek) in })
    }
    
    func playVideo() {
        let videoURL = URL(string: "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.mp4")
        player = AVPlayer(url: videoURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = VideoView.bounds
        playerLayer.videoGravity = .resizeAspect
        VideoView.layer.addSublayer(playerLayer)
        player!.play()
        player!.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { (progressTime) in
            self.seconds = Int(CMTimeGetSeconds(progressTime))
            let secondsString = String(format: "%02d", Int(self.seconds % 60))
            let minutesString = String(format: "%02d", Int(self.seconds / 60))
            self.VideoCurrentTime.text = "\(minutesString):\(secondsString)"
            
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.VideoSlider.value = Float(CMTimeGetSeconds(progressTime) / durationSeconds)
            }
        })
    }
    
    @IBAction func VideoSlidTap(_ sender: Any) {
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(VideoSlider.value) * totalSeconds
            let seektime = CMTime(value: Int64(value) , timescale: 1)
            player?.seek(to: seektime, toleranceBefore: seektime, toleranceAfter: seektime, completionHandler: { (seek) in })
        }
    }
    
    @IBAction func PauseTapped(_ sender: Any) {
        if isplaying {
            player?.pause()
            PauseButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player?.play()
            PauseButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        isplaying = !isplaying
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        if keyPath == "currentItem.loadedTimeRanges" {
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
            PauseButton.isHidden = false
            VideoSlider.isHidden = false
            VideoTime.isHidden = false
            VideoCurrentTime.isHidden = false
            isplaying = true
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                VideoTime.text = "\(minutesText):\(secondsText)"
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        playerLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}

