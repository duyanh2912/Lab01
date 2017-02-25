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
    
    var repeatOption: Variable<MusicRepeatOption> = Variable(.all)
    var shuffleOption: Variable<MusicShuffleOption> = Variable(.off)
    
    var currentTime: Variable<Double> = Variable(0)
    var duration: Variable<Double> = Variable(0)
    
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
        let timer = Observable<Int>.interval(0.5, scheduler: ConcurrentDispatchQueueScheduler.init(qos: .userInteractive)).share()
        
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
            .unwrap()
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] song in
                self.playingBar.configWith(song: song)
                self.configControllCenter(song: song)
                if self.playingBar.superview == nil {
                    self.window.addSubview(self.playingBar)
                }
                
                self.currentTime.value = 0
                self.duration.value = 0
                self.progressBar.progress = 0
                
                self.player.replaceCurrentItem(with: nil)
                self.player.pause()
                self.isPlaying.value = true
            })
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .flatMapLatest { song in
                Song.getBestAlikeSong(to: song)
            }
            .filter {
                if $0 == 0 {
                    let toast = MDToast(text: "Song not found", duration: 1)
                    toast.show()
                }
                return $0 != 0
            }
            .flatMapLatest {
                return Song.getLink(songId: $0)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] link in
                self.play(link: link)
            })
            .addDisposableTo(disposeBag)
    }
    
    func seekTo(_ time: Double) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: 44100))
        infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
    }
    
    func configControlCenter() {
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
    
    func pause() {
        self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime.value
        self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
        self.paused.value = true
        self.player.pause()
    }
    
    func play() {
        self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime.value
        self.infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
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
    }
    
    func previousSong() {
        var index = self.songs.value.index(where: { $0 == self.selectedSong.value })!
        if index <= 0 {
            index = self.songs.value.count - 1
        } else {
            index -= 1
        }
        self.selectedSong.value = self.songs.value[index]
    }
    
    private func play(link: String) {
        let url = link
        let playerItem = AVPlayerItem( url: URL(string: url)! )
        player.replaceCurrentItem(with: playerItem)
        play()
        if let duration = player.currentItem?.asset.duration {
            infoCenter.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration.seconds
            self.duration.value = duration.seconds
        }
        
        NotificationCenter.default
            .rx
            .notification(NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            .subscribe(onNext: { [unowned self] _ in
                self.didFinishPlaying()
            })
            .addDisposableTo(disposeBag)
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
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
        let infoCenter = MPNowPlayingInfoCenter.default()
        var newInfo = Dictionary<String, Any>()
        
        newInfo[MPMediaItemPropertyTitle] = song.title
        newInfo[MPMediaItemPropertyArtist] = song.artist
        
        newInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        newInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 170, height: 170)) { _ in
            return song.image ?? UIImage()
        }
        infoCenter.nowPlayingInfo = newInfo
    }
}
