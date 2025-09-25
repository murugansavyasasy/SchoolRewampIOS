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
    var ptm:Bool = false
    var delegate: SelectedId?
    var edit:Bool?
    var delete:Bool?
    var selectedId:String?
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
        editStack.isHidden   = ptm ? true             : !(edit ?? false)
        deleteStack.isHidden = ptm ? true             : !(delete ?? false)
        cancelStack.isHidden = ptm ? !(delete ?? false) : true
        reopenStack.isHidden = ptm ? !(edit ?? false)   : true

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
        delegate?.selectId(id: selectedId ?? "", edit: false)
        dismiss(animated: true)
    }
    @IBAction func editBtn(_ sender: UIButton) {
        delegate?.selectId(id: selectedId ?? "", edit: true)
        dismiss(animated: true)
    }
}
