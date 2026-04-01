//
//  BirthDayWishVC.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 10/11/25.
//

import UIKit

class BirthDayWishVC: UIViewController {

    @IBOutlet weak var dateLbl: UILabel!
    private var confettiLayer: CAEmitterLayer?
    private var isAnimating = true
    @IBOutlet weak var nameLbl: UILabel!
    private let confetti1: ConfettiView = .top
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var childView: UIView!
    var nameLbl_text:String = ""
    var birth_day : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        parentView.layer.cornerRadius = 10
        childView.layer.cornerRadius = 10
        profileView.layer.cornerRadius = 15
        profileImgView.layer.cornerRadius = profileImgView.frame.height/2
        profileImgView.layer.borderWidth = 7
        profileImgView.layer.borderColor = UIColor.primery.cgColor
        nameLbl.text = nameLbl_text
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd,MMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let currentDate = formatter.string(from: Date())
        dateLbl.text = currentDate
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.confeeti()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
           view.addGestureRecognizer(tap)
        
    }
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    @IBAction func celebrateBtn(_ sender: UIButton) {
        isAnimating = true
        confeeti()
    }

    func confeeti(){
        if isAnimating {
            self.isAnimating = false
            if let window = UIApplication.shared.windows.first {
                confetti1.translatesAutoresizingMaskIntoConstraints = false
                window.addSubview(confetti1)
                
                NSLayoutConstraint.activate([
                    confetti1.topAnchor.constraint(equalTo: window.topAnchor),
                    confetti1.rightAnchor.constraint(equalTo: window.rightAnchor),
                    confetti1.leftAnchor.constraint(equalTo: window.leftAnchor),
                    confetti1.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                ])
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                    let impactEngine = UIImpactFeedbackGenerator(style: .heavy)
                    impactEngine.impactOccurred()
                    //                confetti.emit()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                        let impactEngine = UIImpactFeedbackGenerator(style: .heavy)
                        impactEngine.impactOccurred()
                        self.confetti1.emit()
                    }
                }
            }
        }
    }
   

}
