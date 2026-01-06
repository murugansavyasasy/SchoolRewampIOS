//
//  CommonPagenationVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 12/11/25.
//

import UIKit

class CommonPagenationVc: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var VoiceMessageView: UIView!
    @IBOutlet weak var ScheduleMessageView: UIView!
    @IBOutlet weak var TextMessageView: UIView!
    @IBOutlet weak var voiceIconBtn: UIButton!
    @IBOutlet weak var ScheduleIconBtn: UIButton!
    @IBOutlet weak var TextIconBtn: UIButton!
    @IBOutlet weak var VoiceMessageLbl: UILabel!
    @IBOutlet weak var scheduleMessageLbl: UILabel!
    @IBOutlet weak var TextMessageLbl: UILabel!
    
    lazy var voiceMessageVC: VoiceMessagesVC = {
        let vc = VoiceMessagesVC()
        return vc
    }()

    lazy var ScheduleVC: ScheduleCallVC = {
        let vc = ScheduleCallVC()
        return vc
    }()
    
    lazy var textMessageVC: TextMessageVC = {
        let vc = TextMessageVC()
        return vc
    }()
    
    private var currentChildVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetupUI()
        loadInitialChild()
    }
    
    func SetupUI(){
        
        VoiceMessageView.layer.cornerRadius = 8
        ScheduleMessageView.layer.cornerRadius = 8
        TextMessageView.layer.cornerRadius = 8
        
        voiceIconBtn.layer.cornerRadius = voiceIconBtn.frame.width / 2
        ScheduleIconBtn.layer.cornerRadius = ScheduleIconBtn.frame.width / 2
        TextIconBtn.layer.cornerRadius = TextIconBtn.frame.width / 2
        
        VoiceMessageView.backgroundColor = .topBackgroundCLr1
        voiceIconBtn.tintColor = .white
        VoiceMessageLbl.textColor = .white
    }
    
    func loadInitialChild() {
        currentChildVC = voiceMessageVC
        addChild(voiceMessageVC)
        voiceMessageVC.view.frame = containerView.bounds
        containerView.addSubview(voiceMessageVC.view)
        voiceMessageVC.didMove(toParent: self)
    }
    
    func switchToChild(_ newVC: UIViewController) {
        guard newVC !== currentChildVC else { return }

        let oldVC = currentChildVC
        currentChildVC = newVC

        oldVC?.willMove(toParent: nil)
        addChild(newVC)

        newVC.view.frame = containerView.bounds

        // Smooth transition
        transition(
            from: oldVC!,
            to: newVC,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        ) { _ in
            oldVC?.removeFromParent()
            newVC.didMove(toParent: self)
        }
    }
    
    @IBAction func voiceMessageAct(_ sender: UIButton) {
        updateSelection(
            selectedView: VoiceMessageView,
            selectedBtn: voiceIconBtn,
            selectedLbl: VoiceMessageLbl
        )
        switchToChild(voiceMessageVC)
    }

    @IBAction func SheduleMessageAct(_ sender: UIButton) {
        updateSelection(
            selectedView: ScheduleMessageView,
            selectedBtn: ScheduleIconBtn,
            selectedLbl: scheduleMessageLbl
        )
        switchToChild(ScheduleVC)
    }

    @IBAction func TextMessageAct(_ sender: UIButton) {
        updateSelection(
            selectedView: TextMessageView,
            selectedBtn: TextIconBtn,
            selectedLbl: TextMessageLbl
        )
        switchToChild(textMessageVC)
    }

    
    func updateSelection(selectedView: UIView, selectedBtn: UIButton, selectedLbl: UILabel) {
        
        let allViews = [VoiceMessageView, ScheduleMessageView, TextMessageView]
        let allBtns = [voiceIconBtn, ScheduleIconBtn, TextIconBtn]
        let allLbls = [VoiceMessageLbl, scheduleMessageLbl, TextMessageLbl]
        
        // Reset all
        allViews.forEach { $0?.backgroundColor = .white }
        allBtns.forEach { $0?.tintColor = .black }
        allLbls.forEach { $0?.textColor = .black }
        
        // Apply selected
        selectedView.backgroundColor = .topBackgroundCLr1
        selectedBtn.tintColor = .white
        selectedLbl.textColor = .white
    }
    
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}
