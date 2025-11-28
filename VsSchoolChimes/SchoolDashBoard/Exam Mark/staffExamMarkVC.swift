//
//  staffExamMarkVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class staffExamMarkVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var academicYearBtn: UIButton!
    
    var AcadimicYears: [AcadimicYearData] = []
    var AcademicDropdown = DropDown()
    var classList: [ClassDisplayItem] = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.register(UINib(nibName: "Exam_ClassListTV", bundle: nil), forCellReuseIdentifier: "Exam_ClassListTV")
        
        tv.delegate = self
        tv.dataSource = self
        
        if localData.accidamic_year_data?.data?.isEmpty == false {
            getacadmicYr()
        }
    }
    
    func getacadmicYr() {
        AcadimicYears = localData.accidamic_year_data?.data ?? []
        academicYearBtn.setTitle(AcadimicYears.last?.year, for: .normal)
        Get_standardSection_Api(academicId: AcadimicYears.last?.id ?? 0)
    }
    
    @IBAction func academicYearDrop_action(_ sender: UIButton) {
        
        AcademicDropdown.anchorView = academicYearBtn
        AcademicDropdown.dataSource = AcadimicYears.compactMap{$0.year}
        AcademicDropdown.bottomOffset = CGPoint(x: 0, y: academicYearBtn.bounds.height)
        AcademicDropdown.show()
        AcademicDropdown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            academicYearBtn.setTitle(item, for: .normal)
            Get_standardSection_Api(academicId: AcadimicYears[index].id ?? 0)
        }
    }
    
    func Get_standardSection_Api(academicId : Int){
        
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [COMMON_PARAMETER.academic_year_id: academicId], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<GetStandardsSuc , Error>) in
            
            DispatchQueue.main.sync { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        
                        classList.removeAll()
                        let standardData =  success.data ?? []
                        
                        for standard in standardData{
                            for section in standard.sections ?? [] {
                                
                                let displayName = "Grade \(standard.name ?? "") - Section \(section.name ?? "")"
                                classList.append(ClassDisplayItem(displayName: displayName, standardId: standard.id ?? "", sectionId: section.id ?? ""))
                            }
                        }
                        
                        tv.reloadData()
                       
                        
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                    }
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self) {
                        self.dismiss(animated: true)
                    }
                }
            }
            
        }
    }

    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "Exam_ClassListTV", for: indexPath) as! Exam_ClassListTV
        
        let standard = classList[indexPath.row]
        cell.classNameLbl.text = standard.displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc  = ExamListVC()
        vc.standard = classList[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}
