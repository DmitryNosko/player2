//
//  AudioPlayerViewController.swift
//  AVPlayer
//
//  Created by Dzmitry Noska on 10/31/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController {
    
    var player: AVPlayer!
    var audioURL: String = ""
    var podcstPlayerImage: UIImage!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var podcastImage: UIImageView!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalLenghtLabel: UILabel!
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .gray)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
//    func downloadFileFromURL(url: String)  {
//
//        if let audioUrl = URL(string: url) {
//
//            // then lets create your document folder url
//            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//            // lets create your destination file url
//            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
//            print(destinationUrl)
//
//            // to check if it exists before downloading it
//            if FileManager.default.fileExists(atPath: destinationUrl.path) {
//                print("The file already exists at path")
//                //player.play()
//            } else {
//
//                // you can use NSURLSession.sharedSession to download the data asynchronously
//                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
//                    guard let location = location, error == nil else { return }
//                    do {
//                        // after downloading your file you need to move it to your destination url
//                        try FileManager.default.moveItem(at: location, to: destinationUrl)
//
//                        //self.play(url: destinationUrl)
//                        print("File moved to documents folder")
//                    } catch let error as NSError {
//                        print(error.localizedDescription)
//                    }
//                }).resume()
//            }
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        podcastImage.image = podcstPlayerImage
        podcastImage.layer.cornerRadius = 30
        podcastImage.clipsToBounds = true
        
        setUpPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPlaying()
    }
    
    //MARK: - Player
    
    func startPlaying() {
        player.play()
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            
            let time = CMTime()
            let seconds = CMTimeGetSeconds(progressTime)
            let totalSeconds = time.durationTexForTime(time: progressTime)
            self.currentTimeLabel.text = "\(totalSeconds)"
            
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.videoSlider.value = Float(seconds / durationSeconds)
            }
        })
    }
    
    var counter = 0
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicator.stopAnimating()
            
            if let duration = player?.currentItem?.duration {
                let time = CMTime()
                let totalSeconds = time.durationTexForTime(time: duration)
                totalLenghtLabel.text = "\(totalSeconds)"
            }
        }
    }
    
    func setUpPlayer() {
        let url = URL(string: audioURL)!
        player = AVPlayer(url: url)
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playback)
        } catch {
            
        }
    }
    
    var isPlaying = false
    
    @IBAction func playAction(_ sender: UIButton) {
        sender.pulsate()
        player.play()
    }

    @IBAction func restartAction(_ sender: UIButton) {
        sender.pulsate()
        if ((player.error == nil)) {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }

    @IBAction func pauseAction(_ sender: UIButton) {
        sender.pulsate()
        player?.pause()
    }

    @IBAction func closePlayerAction(_ sender: UIButton) {
        sender.pulsate()
        player.pause()
        dismiss(animated: true) {
        }
    }
    
    @IBAction func handleSliderChanged(_ sender: Any) {
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(videoSlider.value) * totalSeconds
            
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
            })
        }
    }
}
