//
//  PopupVC.swift
//  VsSchoolChimes
//
//  Created by admin on 26/02/25.
//

import UIKit
protocol SelectedId{
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
        editStack.isHidden = ptm
        deleteStack.isHidden = ptm
        cancelStack.isHidden = !ptm
        reopenStack.isHidden = !ptm
        if let delete = delete{
            deleteStack.isHidden = !delete
        }
        if let edit = edit{
            editStack.isHidden = !edit
        }
        
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
