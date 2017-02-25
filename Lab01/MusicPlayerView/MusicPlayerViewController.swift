//
//  MusicPlayerViewController.swift
//  Lab01
//
//  Created by Duy Anh on 2/24/17.
//  Copyright © 2017 Duy Anh. All rights reserved.
//

import AVFoundation
import UIKit
import RxSwift
import RxCocoa
import RxGesture
import Utils

class MusicPlayerViewController: UIViewController {
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var optionButton: UIButton!
    
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    var repeatOption: Variable<MusicRepeatOption> = Variable(.none)
    var shuffleOption: Variable<MusicShuffleOption> = Variable(.off)
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var controllContainerView: UIView!
    
    typealias cellClass = SongListTableViewCell
    var dataSource: MusicPlayerTableViewDataSource!
    var currentSong: Variable<Song?> = Variable(nil)
    var disposeBag = DisposeBag()
    var sliding: Bool = false
    
    static var instance: MusicPlayerViewController = generate()
    
    static func generate() -> MusicPlayerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let musicPlayer = storyboard.instantiateViewController(withIdentifier: "MusicPlayer")
        return musicPlayer as! MusicPlayerViewController
    }
    
    override func viewDidLoad() {
        configDataSource()
        configRepeatOption()
        configShuffleOption()
        configHideButton()
        configOptionButton()
        configPlayPauseButton()
        configNextPreviousButton()
        configTimeLabel()
        configProgressSlider()
        configImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
        AudioController.instance.playingBar.isHidden = false
    }
    
    func configImageView() {
        songImageView.contentMode = .scaleAspectFit
        songImageView.rx
            .gesture(RxGestureTypeOption.swipeDown)
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .addDisposableTo(disposeBag)
    }
    
    func configProgressSlider() {
        progressSlider.setThumbImage(#imageLiteral(resourceName: "img-slider-thumb"), for: .normal)
        AudioController.instance.currentTime
            .asObservable()
            .filter { [unowned self] _ in !self.sliding }
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .map { currentTime -> Double in
                return currentTime / AudioController.instance.duration.value }
            .map { time -> Double in
                if time.isNaN { return 0 }
                return time
            }
            .map { percent -> Float in
                return Float(percent)
            }
            .map { 100*$0 }
            .observeOn(MainScheduler.instance)
            .filter { [unowned self] _ in !self.sliding }
            .bindTo(progressSlider.rx.value)
            .addDisposableTo(disposeBag)
        
        let slideObservable = progressSlider.rx
            .value
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .share()
            .filter { [unowned self] _ in self.sliding }
            .map { value in Double(value/100) * AudioController.instance.duration.value }
        slideObservable
            .map { [unowned self] in self.convert(time: $0) }
            .observeOn(MainScheduler.instance)
            .bindTo(currentTimeLabel.rx.text)
            .addDisposableTo(disposeBag)
        slideObservable
            .map { AudioController.instance.duration.value - $0 }
            .map { [unowned self] time -> String in
                return "-\(self.convert(time: time))"
            }
            .observeOn(MainScheduler.instance)
            .bindTo(remainingTimeLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        progressSlider.rx
            .controlEvent(.touchDown)
            .subscribe(onNext: { [unowned self] _ in self.sliding = true })
            .addDisposableTo(disposeBag)
        
        Observable.of(progressSlider.rx.controlEvent(.touchUpInside),
                      progressSlider.rx.controlEvent(.touchUpOutside))
            .merge()
            .subscribe(onNext: { [unowned self] _ in
                self.sliding = false
                let time = Double(self.progressSlider.value/100) * AudioController.instance.duration.value
                AudioController.instance.seekTo(time)
                AudioController.instance.currentTime.value = time
                }
            )
            .addDisposableTo(disposeBag)
    }
    
    func configTimeLabel() {
        AudioController.instance.currentTime
            .asObservable()
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .filter { [unowned self] _ in !self.sliding }
            .share()
            .map { [unowned self] in return self.convert(time: $0) }
            .observeOn(MainScheduler.instance)
            .bindTo(currentTimeLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        AudioController.instance.currentTime
            .asObservable()
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInteractive))
            .filter { [unowned self] _ in !self.sliding }
            .map { AudioController.instance.duration.value - $0 }
            .map { [unowned self] in self.convert(time: $0) }
            .map { return "-\($0)" }
            .observeOn(MainScheduler.instance)
            .bindTo(remainingTimeLabel.rx.text)
            .addDisposableTo(disposeBag)
    }
    
    func convert(time: Double) -> String {
        if time.isNaN { return "0:00" }
        let time = Int(time)
        let minutes = time / 60
        let seconds = time - minutes * 60
        let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(minutes):" + secondsString
    }
    
    func configNextPreviousButton() {
        nextButton.rx.tap
            .subscribe(onNext: { _ in
                AudioController.instance.nextSong()
            })
            .addDisposableTo(disposeBag)
        previousButton.rx.tap
            .subscribe(onNext: { _ in
                AudioController.instance.previousSong()
            })
            .addDisposableTo(disposeBag)
    }
    
    func configPlayPauseButton() {
        AudioController.instance.paused
            .asObservable()
            .subscribe(onNext: { [unowned self] paused in
                if paused {
                    self.pauseButton.setImage(#imageLiteral(resourceName: "img-player-play"), for: .normal)
                } else {
                    self.pauseButton.setImage(#imageLiteral(resourceName: "img-player-pause"), for: .normal)
                }
            })
            .addDisposableTo(disposeBag)
        
        pauseButton.rx.tap
            .subscribe(onNext: { _ in
                switch AudioController.instance.paused.value {
                case true: AudioController.instance.play()
                case false: AudioController.instance.pause()
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func configOptionButton() {
        optionButton.tintColor = .white
    }
    
    func configHideButton() {
        hideButton.tintColor = .white
        hideButton.rx
            .tap
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
                AudioController.instance.playingBar.isHidden = false
            })
            .addDisposableTo(disposeBag)
    }
    
    func configShuffleOption() {
        AudioController.instance.shuffleOption
            .asObservable()
            .bindTo(shuffleOption)
            .addDisposableTo(disposeBag)
        
        shuffleOption.asObservable()
            .bindNext { [unowned self] in
                switch $0 {
                case .on: self.shuffleButton.setImage(#imageLiteral(resourceName: "img-player-shuffle"), for: .normal)
                case .off: self.shuffleButton.setImage(#imageLiteral(resourceName: "img-player-shuffle-off"), for: .normal)
                }
            }
            .addDisposableTo(disposeBag)
        
        shuffleButton.rx.tap
            .subscribe(onNext: { _ in
                let shuffleOption = AudioController.instance.shuffleOption
                switch shuffleOption.value {
                case .on: shuffleOption.value = .off
                case .off: shuffleOption.value = .on
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func configRepeatOption() {
        AudioController.instance.repeatOption
            .asObservable()
            .bindTo(repeatOption)
            .addDisposableTo(disposeBag)
        
        repeatOption.asObservable()
            .bindNext { [unowned self] in
                switch $0 {
                case .none: self.repeatButton.setImage(#imageLiteral(resourceName: "img-player-repeat-none"), for: .normal)
                case .all: self.repeatButton.setImage(#imageLiteral(resourceName: "img-player-repeat"), for: .normal)
                case .one: self.repeatButton.setImage(#imageLiteral(resourceName: "img-player-repeat-1"), for: .normal)
                }
            }
            .addDisposableTo(disposeBag)
        
        repeatButton.rx.tap
            .subscribe(onNext: { _ in
                let repeatOption = AudioController.instance.repeatOption
                switch repeatOption.value {
                case .none: repeatOption.value = .one
                case .one: repeatOption.value = .all
                case .all: repeatOption.value = .none
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func configDataSource() {
        cellClass.registerFor(tableView: tableView)
        dataSource = MusicPlayerTableViewDataSource(tableView: tableView)
        dataSource.config()
        
        dataSource.selectedSong
            .asObservable()
            .bindTo(currentSong)
            .addDisposableTo(disposeBag)
        
        currentSong.asObservable()
            .unwrap()
            .subscribe(onNext: { [unowned self] song in
                self.songImageView.sd_setImage(with: URL(string: song.imageLink), placeholderImage: #imageLiteral(resourceName: "img-player-placeholder"))
                self.currentTimeLabel.text = "0:00"
                self.remainingTimeLabel.text = "-0:00"
            })
            .addDisposableTo(disposeBag)
    }
    
    deinit {
        print("Deinit-MusicPlayerViewController")
    }
}
