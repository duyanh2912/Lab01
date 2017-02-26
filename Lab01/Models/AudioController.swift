//
//  AudioController.swift
//  Lab01
//
//  Created by Duy Anh on 2/23/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import AVFoundation
import MediaPlayer
import SDWebImage
import AlamofireImage
import RxSwift
import RxGesture
import MaterialControls

class AudioController {
    static var instance = AudioController()
    
    // This is for determining if playingBar is showing or not
    var isPlaying: Variable<Bool> = Variable(false)
    
    // This is actual play/pause
    var paused: Variable<Bool> = Variable(true)
    
    // Cool down for next/previous songs
    var isCoolingDown = false
    var coolDownDuration: Double = 0.2
    
    // Repeat and shuffle options
    var repeatOption: Variable<MusicRepeatOption> = Variable(.all)
    var shuffleOption: Variable<MusicShuffleOption> = Variable(.off)
    
    // Song information
    var currentDownloadLink: String? = nil
    var currentTime: Variable<Double> = Variable(0)
    var duration: Variable<Double> = Variable(0)
    
    // Playback info
    var localNowPlayingInfo: [String:Any] = [:]
    
    var selectedSong: Variable<Song?> = Variable(nil)
    var songs: Variable<[Song]> = Variable([])
    
    var player = AVPlayer()
    var disposeBag = DisposeBag()
    
    let playingBar = SongListTableViewCell.fromNib
    let progressBar = UIProgressView(progressViewStyle: .bar)
    
    let window = AppDelegate.instance.window!
    let infoCenter = MPNowPlayingInfoCenter.default()
    
    func play(song: Song) {
        selectedSong.value = song
    }
    
    init() {
        bindSongToPlay()
        bindTime()
        configPlayingBar()
        configControlCenter()
        configReachability()
        infoCenter.nowPlayingInfo = [:]
    }
    
    func configReachability() {
        Status.reachable
            .asObservable()
            .subscribe(onNext: {
                self.playingBar.frame.origin.y = self.window.height - self.playingBar.height
                if !$0 {
                    self.playingBar.frame.origin.y -= Status.snackBar.height
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func bindTime() {
        let timer = Observable<Int>.interval(1, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .userInteractive)).share()
        
        timer.map { [unowned self] _ ->  Double in
            if self.player.currentTime().seconds.isNaN {
                return 0
            }
            return self.player.currentTime().seconds
            }
            .bindTo(currentTime)
            .addDisposableTo(disposeBag)
    }
    
    func bindSongToPlay() {
        selectedSong.asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .unwrap()
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] song in
                self.playingBar.configWith(song: song)
                self.configControllCenter(song: song)
                if self.playingBar.superview == nil {
                    self.window.addSubview(self.playingBar)
                }
                self.progressBar.progress = 0
            })
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .do(onNext: { [unowned self] song in
                self.currentTime.value = 0
                self.duration.value = 0
                
                self.player.replaceCurrentItem(with: nil)
                self.player.pause()
                self.isPlaying.value = true
            })
            .throttle(1, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .flatMapLatest { song in
                Song.getBestAlikeSong(to: song)
            }
            .observeOn(MainScheduler.instance)
            .filter {
                if $0 == 0 {
                    if UIApplication.shared.applicationState == .active {
                        let toast = MDToast(text: "Song not found", duration: 1)
                        toast.show()
                    }
                }
                return $0 != 0
            }
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .flatMapLatest {
                return Song.getLink(songId: $0)
            }
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .subscribe(onNext: { [unowned self] link in
                print("play")
                self.play(link: link)
            })
            .addDisposableTo(disposeBag)
    }
    
    func seekTo(_ time: Double) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: 44100))
        DispatchQueue.main.async { [unowned self] in
            self.localNowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
            self.infoCenter.nowPlayingInfo = self.localNowPlayingInfo
        }
    }
    
    func configControlCenter() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.play()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.nextSong()
            return MPRemoteCommandHandlerStatus.success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.previousSong()
            return MPRemoteCommandHandlerStatus.success
        }
    }
    
    func seekNext(time: Double) {
        seekTo(self.currentTime.value + time)
    }
    
    func seekBack(time: Double) {
        seekTo(self.currentTime.value - time)
    }
    
    func pause() {
        DispatchQueue.main.async { [unowned self] in
            self.localNowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime.value
            self.localNowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
            self.infoCenter.nowPlayingInfo = self.localNowPlayingInfo
        }
        self.paused.value = true
        self.player.pause()
    }
    
    func play() {
        DispatchQueue.main.async { [unowned self] in
            self.localNowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime.value
            self.localNowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            self.infoCenter.nowPlayingInfo = self.localNowPlayingInfo
        }
        self.paused.value = false
        self.player.play()
    }
    
    func configPlayingBar() {
        playingBar.frame.size.height = 50
        playingBar.frame.size.width = window.width
        playingBar.frame.origin = CGPoint(x: 0, y: window.height - playingBar.height)
        
        progressBar.frame = CGRect(x: 0, y: -progressBar.height, width: playingBar.width, height: progressBar.height)
        progressBar.progressTintColor = UIColor.init("#4990E2")
        progressBar.trackTintColor = UIColor.lightGray
        playingBar.addSubview(progressBar)
        
        currentTime.asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .map { return $0/self.duration.value }
            .map {
                return Float($0)
            }
            .map {
                if $0 == Float.nan {
                    return 0
                }
                return $0
            }
            .observeOn(MainScheduler.instance)
            .bindTo(progressBar.rx.progress)
            .addDisposableTo(disposeBag)
        
        playingBar.rx
            .gesture(.tap)
            .subscribe(onNext: { _ in
                self.window.rootViewController?.present(MusicPlayerViewController.instance, animated: true)
                self.playingBar.isHidden = true
            })
            .addDisposableTo(disposeBag)
    }
    
    func nextSong() {
        guard !isCoolingDown else { return }
        isCoolingDown = true
        switch shuffleOption.value {
        case .off:
            var index = self.songs.value.index(where: { $0 == self.selectedSong.value })!
            if index >= self.songs.value.count-1 {
                index = 0
            } else {
                index += 1
            }
            self.selectedSong.value = self.songs.value[index]
        case .on:
            self.selectedSong.value = self.songs.value.randomMember
        }
        Timer.scheduledTimer(withTimeInterval: coolDownDuration, repeats: false) { [weak self] _ in
            self?.isCoolingDown = false
        }
    }
    
    func previousSong() {
        guard !isCoolingDown else { return }
        isCoolingDown = true
        var index = self.songs.value.index(where: { $0 == self.selectedSong.value })!
        if index <= 0 {
            index = self.songs.value.count - 1
        } else {
            index -= 1
        }
        self.selectedSong.value = self.songs.value[index]
        Timer.scheduledTimer(withTimeInterval: coolDownDuration, repeats: false) { [weak self] _ in
            self?.isCoolingDown = false
        }
    }
    
    private func play(link: String) {
        let url = link
        let playerItem = AVPlayerItem( url: URL(string: url)! )
        player.replaceCurrentItem(with: playerItem)
        play()
        if let duration = player.currentItem?.asset.duration {
            DispatchQueue.main.async { [unowned self] in
                self.localNowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration.seconds
                self.infoCenter.nowPlayingInfo = self.localNowPlayingInfo
            }
            self.duration.value = duration.seconds
        }
        
        NotificationCenter.default
            .rx
            .notification(NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            .subscribe(onNext: { [unowned self] _ in
                self.didFinishPlaying()
            })
            .addDisposableTo(disposeBag)
    }
    
    private func didFinishPlaying() {
        switch self.repeatOption.value {
        case .all: self.nextSong()
        case .none: self.pause()
        case .one: self.player.seek(to: CMTime(seconds: 0, preferredTimescale: 44100)) { [unowned self] _ in
            self.play()
            }
        }
    }
    
    private func configControllCenter(song: Song) {
        DispatchQueue.main.async { [unowned self] in
            self.localNowPlayingInfo[MPMediaItemPropertyTitle] = song.title
            self.localNowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
            self.localNowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
            self.localNowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = 0
            self.localNowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 170, height: 170)) { _ in
                return song.image ?? UIImage()
            }
            self.infoCenter.nowPlayingInfo = self.localNowPlayingInfo
        }
    }
}
