//
//  PopupVC.swift
//  VsSchoolChimes
//
//  Created by admin on 26/02/25.
//

import UIKit
protocol SelectedId:AnyObject{
    func selectId(id:String?,edit:Bool?)
}
class PopupVC: UIViewController {
    var selectedIndex:Int?
    @IBOutlet weak var editStack: UIStackView!
    @IBOutlet weak var deleteStack: UIStackView!
    @IBOutlet weak var cancelStack: UIStackView!
    @IBOutlet weak var reopenStack: UIStackView!
    @IBOutlet weak var replyStack: UIStackView!
    @IBOutlet weak var BlockStack: UIStackView!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var BlockBtn: UIButton!
    
    
    var ptm:Bool = false
    var Chat:Bool = false
    var delegate: SelectedId?
    var edit:Bool?
    var delete:Bool?
    var selectedId:String?
    var reply_Btn_title = ""
    var Block_Btn_title = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if ptm{
//            editStack.isHidden = true
//            deleteStack.isHidden = true
//            if let delete = delete{
//                cancelStack.isHidden = !delete
//            }
//            if let edit = edit{
//                reopenStack.isHidden = !edit
//            }
//        }else{
//            cancelStack.isHidden = true
//            reopenStack.isHidden = true
//            if let delete = delete{
//                deleteStack.isHidden = !delete
//            }
//            if let edit = edit{
//                editStack.isHidden = !edit
//            }
//        }
        
        if #available(iOS 17.4, *) {
               view.backgroundColor = .clear
               self.popoverPresentationController?.backgroundColor = .white
           }
        
        if ptm{
            editStack.isHidden = true
            deleteStack.isHidden = true
            BlockStack.isHidden = true
            replyStack.isHidden = true
            cancelStack.isHidden = !(delete ?? false)
            reopenStack.isHidden = !(edit ?? false)
        }else if Chat{
            editStack.isHidden = true
            deleteStack.isHidden = true
            cancelStack.isHidden = true
            reopenStack.isHidden = true
            replyStack.isHidden = false
            BlockStack.isHidden = false
            replyBtn.setTitle(reply_Btn_title, for: .normal)
            BlockBtn.setTitle(Block_Btn_title, for: .normal)
        }else{
            reopenStack.isHidden = true
            cancelStack.isHidden = true
            replyStack.isHidden = true
            BlockStack.isHidden = true
            editStack.isHidden = !(edit ?? false)
            deleteStack.isHidden = !(delete ?? false)
        }
        
//        editStack.isHidden   = ptm ? true             : !(edit ?? false)
//        deleteStack.isHidden = ptm ? true             : !(delete ?? false)
//        cancelStack.isHidden = ptm ? !(delete ?? false) : true
//        reopenStack.isHidden = ptm ? !(edit ?? false)   : true

    }
    init(edit: Bool = false, delete: Bool = false, selectedId: String?) {
        self.edit = edit
        self.delete = delete
        self.selectedId = selectedId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBAction func cancelBtn(_ sender: UIButton) {
        delegate?.selectId(id: selectedId ?? "", edit: false)
        dismiss(animated: true)
    }
    @IBAction func reOpenBtn(_ sender: UIButton) {
        delegate?.selectId(id: selectedId ?? "", edit: true)
        dismiss(animated: true)
    }
    @IBAction func deleteBtn(_ sender: UIButton) {
        print("DELETE CLICKED")
        delegate?.selectId(id: selectedId ?? "", edit: false)
        dismiss(animated: true)
    }
    @IBAction func editBtn(_ sender: UIButton) {
        print("EDIT CLICKED")
        delegate?.selectId(id: selectedId ?? "", edit: true)
        dismiss(animated: true)
    }
    
    @IBAction func replyBtn(_ sender: UIButton) {
        
        delegate?.selectId(id: selectedId, edit: true)
        dismiss(animated: true)
    }
    
    @IBAction func blockAct(_ sender: UIButton) {
        delegate?.selectId(id: selectedId ?? "", edit: false)
        dismiss(animated: true)
    }
    
}
