//
//  LSRWTakingSkillViewController.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/20/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

//import ObjectMapper
class LSRWTakingSkillViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var NextBtn: UIButton!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    
    var skillId : String!
    let rowId = "TakeReadingSkillTableViewCell"
    var studentId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NextBtn.layer.cornerRadius = 10
        let userDefaults = UserDefaults.standard
        tv.register(UINib(nibName: CellConfingName.TakeReadingSkillTableViewCell, bundle: nil), forCellReuseIdentifier: rowId)
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    @IBAction func backAct() {
        dismiss(animated: true)
    }
    
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        let vc = SubmitLsrwViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.skillId = skillId
        present(vc, animated:   true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowId, for: indexPath) as! TakeReadingSkillTableViewCell
        
        
        cell.attachmentLbl.text = ": Image"
        cell.typeLbl.text = ": Text"
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(ViewAttachment))
        cell.viewAttac.addGestureRecognizer(viewTap)
        
        return cell
    }
    
    @objc func ViewAttachment(){
        let vc  = PreviewLsrwViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func AttachmentRedirect(ges : AttachGesture) {
        let vc = PreviewLsrwViewController(nibName: nil, bundle: nil)
        vc.attactText = ges.attachment
        vc.attactType = ges.getType
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


class AttachGesture : UITapGestureRecognizer {
    var getType : String!
    var attachment : String!
}
