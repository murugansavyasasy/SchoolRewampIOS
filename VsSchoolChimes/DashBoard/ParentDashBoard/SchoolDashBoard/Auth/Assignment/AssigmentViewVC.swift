//
//  BookopenViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit

class AssigmentViewVC: UIViewController {

 var indexno = 0
    @IBOutlet weak var viewAssigmentTable: UITableView!
    var delegate : DidSelectDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        register()
    }
    func register(){
//        viewAssigmentTable.register(UINib(nibName: "ImageTVC", bundle: nil), forHeaderFooterViewReuseIdentifier: "ImageTVC")
        viewAssigmentTable.register(UINib(nibName: CellConfingName.ImageTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.ImageTVC)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(row: indexno, section: 0)
        
        // Ensure the cell is visible
        if let cell = viewAssigmentTable.cellForRow(at: indexPath) as? ImageTVC {

            cell.imageCollecctView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        }
    }


    @IBAction func back(_ sender: UIButton) {
        delegate?.select(index: 0, value: "",Img:[""],Pdf:"",text:"",type:"")
    }
}
extension AssigmentViewVC:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewAssigmentTable.dequeueReusableCell(withIdentifier: CellConfingName.ImageTVC, for: indexPath) as! ImageTVC
    
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
