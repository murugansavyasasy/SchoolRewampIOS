//
//  FullPopupVC.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 30/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation

class FullPopupVC: UIViewController ,UINavigationControllerDelegate {
    var player: AVAudioPlayer?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MusicPlayer.shared.startBackgroundMusic()
        appDelegate.isPopupOpened = 1
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cloaseVCAction(_ sender: Any) {
        appDelegate.isPopupOpened = 0
        MusicPlayer.shared.stopBackgroundMusic()
        self.dismiss(animated: true, completion: nil)
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "TEST_MESSAGE", withExtension: "wav") else { return }
        
        do {
            print("url\(url)")
            if #available(iOS 11.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, policy: .default, options: .defaultToSpeaker)
            } else {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            }
            try AVAudioSession.sharedInstance().setActive(true)
            
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 1
            player.play()
            
        }
        catch let error {
            print("error\(error)")
            print(error.localizedDescription)
        }
    }
    
    
}
