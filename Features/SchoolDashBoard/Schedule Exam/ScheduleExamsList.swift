//
//  ScheduleExamsList.swift
//  VsSchoolChimes
//
//  Created by admin on 17/12/24.
//

import UIKit

class ScheduleExamsList: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var examListTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.applyGradient(
//            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
//            startPoint: CGPoint(x: 1, y: 0.5),
//            endPoint: CGPoint(x: 0, y: 0.5)
//        )
        examListTable.register(UINib(nibName: CellConfingName.ExamsListTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ExamsListTVCell)
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = examListTable.dequeueReusableCell(withIdentifier: CellConfingName.ExamsListTVCell, for: indexPath) as! ExamsListTVCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
