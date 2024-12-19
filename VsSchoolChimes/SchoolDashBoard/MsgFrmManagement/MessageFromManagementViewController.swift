//
//  MessageFromManagementViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/17/24.
//

import UIKit

@available(iOS 14.0, *)
class MessageFromManagementViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tv: UITableView!
    
    let MenuRedirect = MenuRedirectHandler.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.register(UINib(nibName: CellConfingName.MessageFromManagementTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.MessageFromManagementTableViewCell)
        tv.dataSource = self
        tv.delegate = self
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGesture)
        
    }
    
    @IBAction func backVc() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.MessageFromManagementTableViewCell, for: indexPath)as! MessageFromManagementTableViewCell
        
        let voiceTapGest = UITapGestureRecognizer(target: self, action: #selector(voiceTap))
        cell.voiceView.addGestureRecognizer(voiceTapGest)
        
        let textTapGest = UITapGestureRecognizer(target: self, action: #selector(textTap))
        cell.textView.addGestureRecognizer(textTapGest)
        
        let pdfTapGest = UITapGestureRecognizer(target: self, action: #selector(pdfTap))
        cell.pdfView.addGestureRecognizer(pdfTapGest)
        
        let imgTapGest = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        cell.imgView.addGestureRecognizer(imgTapGest)
        
        let videoTapGest = UITapGestureRecognizer(target: self, action: #selector(videoTap))
        cell.videoView.addGestureRecognizer(videoTapGest)
        return cell
    }
    
    @IBAction func voiceTap() {
        MenuRedirect.receiverCommunicationNavigate(from: self)
    }
    
    @IBAction func textTap() {
        MenuRedirect.receiverCommunicationNavigate(from: self)
    }
    
    @IBAction func imageTap() {
        MenuRedirect.receiverImgPdfNavigate(from: self)
    }
    
    @IBAction func pdfTap() {
        MenuRedirect.receiverImgPdfNavigate(from: self)
    }
    
    @IBAction func videoTap() {
        MenuRedirect.receiverVideoNavigate(from: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
