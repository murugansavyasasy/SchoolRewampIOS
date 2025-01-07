//
//  TermsAndCondVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 27/11/24.
//

import UIKit
import WebKit

//"https://schoolchimes.com/vs_web/terms_conditions/"
class TermsAndCondVC: UIViewController {

    @IBOutlet weak var HeadingLabel: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var Pdfview: WKWebView!
    var passValue = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        if passValue == 1{
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            outerView.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }else{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            outerView.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }
        HeadingLabel.text = CommonStringFile.TermsandConditions.translated()
        HeadingLabel.setFont(style: .header, size: FontSize.HeaderSize)

        if let pdfURL = URL(string: "https://schoolchimes.com/vs_web/terms_conditions/") {
              let request = URLRequest(url: pdfURL)
             Pdfview.load(request)
            
          }
    }
    
        @IBAction func BackAct(_ sender: Any) {
            
            dismiss(animated: true)
        }
    
    
        }
