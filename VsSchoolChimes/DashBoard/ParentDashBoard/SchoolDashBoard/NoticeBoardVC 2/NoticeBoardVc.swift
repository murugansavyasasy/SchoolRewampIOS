//
//  NoticeBoardVc.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit

class NoticeBoardVc: UIViewController {
    
    @IBOutlet weak var plusImgview: UIImageView!
    
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableview.delegate = self
        tableview.dataSource = self
        
        let nib = UINib(nibName:"NoticeBoardTvcellTableViewCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: "NoticeBoardTvcellTableViewCell")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Plusclick))
        plusImgview.addGestureRecognizer(tap)
        plusImgview.isUserInteractionEnabled = true
        
    }
    
    @IBAction func Plusclick(_ sender : Any){
        let vc = SenderNoticeBoardVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    @IBAction func BackBtnAct(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension NoticeBoardVc : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardTvcellTableViewCell", for: indexPath) as! NoticeBoardTvcellTableViewCell
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
