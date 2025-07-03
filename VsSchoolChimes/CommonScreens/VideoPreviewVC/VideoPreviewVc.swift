//
//  VideoPreviewVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 30/06/25.
//

import UIKit
import WebKit
extension VideoPreviewVc: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Ensures popover on iPhone
    }
}
class VideoPreviewVc: UIViewController {

    var webView: WKWebView!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    var url: String?
    var titles: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        // Do any additional setup after loading the view.
        titleLbl.text = titles
        let config = WKWebViewConfiguration()
               config.allowsInlineMediaPlayback = true
               config.mediaTypesRequiringUserActionForPlayback = [] // autoplay if needed

               webView = WKWebView(frame: self.fullview.bounds, configuration: config)
               webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               fullview.addSubview(webView)

               // Load the Vimeo URL
               if let url = URL(string: url ?? "") {
                   webView.load(URLRequest(url: url))
               }
      
    }
    
    
    

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    

    @IBAction func popupView(_ sender: UIButton) {
        
        let popoverContentVC = shareAndDownloadVc(nibName: nil, bundle: nil)
        popoverContentVC.view.backgroundColor = .white
        popoverContentVC.dowloadUrl = url
        popoverContentVC.typeVideo = true
        popoverContentVC.preferredContentSize = CGSize(width: 150, height: 100)
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverController = popoverContentVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .up
            popoverController.delegate = self
        }
        
        // Present the popover
        self.present(popoverContentVC, animated: true, completion: nil)
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
