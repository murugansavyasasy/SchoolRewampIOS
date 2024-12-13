//
//  MusicPlayer.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MACLAP on 30/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import Foundation
import AVFoundation
class MusicPlayer {
    static let shared = MusicPlayer()
    var audioPlayer: AVAudioPlayer?
    
    func startBackgroundMusic() {
        if let bundle = Bundle.main.path(forResource: "TEST_MESSAGE", ofType: "wav") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                guard let audioPlayer = audioPlayer else { return }
                //audioPlayer.numberOfLoops = -1
                audioPlayer.prepareToPlay()
                audioPlayer.volume = 1
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
    
    func stopBackgroundMusic() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.stop()
    }
}
