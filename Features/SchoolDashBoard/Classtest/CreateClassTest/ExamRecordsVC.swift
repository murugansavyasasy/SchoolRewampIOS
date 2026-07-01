//
//  ExamRecordsVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 01/07/26.
//

import UIKit

class ExamRecordsVC: UIViewController {

    @IBOutlet weak var tv: UITableView!
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var class_test_details: [StaffClassTest]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        tv.register(UINib(nibName: "ReviewSubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewSubjectTableViewCell")
        
        tv.delegate = self
        tv.dataSource = self
    }
    
    
    func get_exam_records_api() {
        
        APIService.shared.makeApi(
            url: ServiceUrl.exam_class_test_details,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? "",
            isBaseUrl: true
        ) { [weak self] (result: Result<StaffClassTestResponse, Error>) in
            
            DispatchQueue.main.async {[weak self] in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        class_test_details = success.data
                        tv.reloadData()
                    }
                    
                case .failure(let failure):
                    print("")
                }
            }
        }
    }



    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
}

extension ExamRecordsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tv.dequeueReusableCell(withIdentifier: "ReviewSubjectTableViewCell", for: indexPath) as! ReviewSubjectTableViewCell
        
        return cell
    }
}
