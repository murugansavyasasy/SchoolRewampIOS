//
//  staffExamMarkVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class staffExamMarkVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.register(UINib(nibName: "Exam_ClassListTV", bundle: nil), forCellReuseIdentifier: "Exam_ClassListTV")
        
        tv.delegate = self
        tv.dataSource = self
    }

    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "Exam_ClassListTV", for: indexPath) as! Exam_ClassListTV
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc  = ExamListVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}
