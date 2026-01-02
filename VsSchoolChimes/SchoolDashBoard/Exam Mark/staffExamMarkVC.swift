//
//  staffExamMarkVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class staffExamMarkVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var academicYearBtn: UIButton!
    @IBOutlet weak var selectYourClassLbl: UILabel!
    @IBOutlet weak var chooseClassLbl: UILabel!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    
    var AcadimicYears: [AcadimicYearData] = []
    var AcademicDropdown = DropDown()
    var classList: [ClassDisplayItem] = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectYourClassLbl.setFont(style: .title, size: FontSize.TitleSize)
        chooseClassLbl.setFont(style: .body, size: FontSize.BodySize)
        noDataLbl.setFont(style: .body, size: FontSize.TitleSize)
        academicYearBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        noDataImage.isHidden = true
        noDataLbl.isHidden = true

        tv.register(UINib(nibName: CellConfingName.Exam_ClassListTV, bundle: nil), forCellReuseIdentifier: CellConfingName.Exam_ClassListTV)
        
        tv.delegate = self
        tv.dataSource = self
        
        if localData.accidamic_year_data?.data?.isEmpty == false {
            getacadmicYr()
        }
    }
    
    func getacadmicYr() {
        AcadimicYears = localData.accidamic_year_data?.data ?? []
        let currentYear = AcadimicYears.first(where: { $0.current_academic_year == true })
        academicYearBtn.setTitle(currentYear?.year, for: .normal)
        Get_standardSection_Api(academicId: currentYear?.id ?? 0)
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
                    
                    classList.removeAll()
                    let standardData =  success.data ?? []
                    
                    for standard in standardData{
                        for section in standard.sections ?? [] {
                            
                            let displayName = "Standard \(standard.name ?? "") - Section \(section.name ?? "")"
                            classList.append(ClassDisplayItem(displayName: displayName, standardId: standard.id ?? "", sectionId: section.id ?? ""))
                        }
                    }
                    
                    noDataImage.isHidden = !classList.isEmpty
                    noDataLbl.isHidden = !classList.isEmpty
                    noDataLbl.text = success.message ?? ""
                    tv.reloadData()
                    
                    
                case .failure(let failure):
                    classList.removeAll()
                    noDataImage.isHidden = false
                    noDataLbl.isHidden = false
                    noDataLbl.text = failure.localizedDescription
                    tv.reloadData()
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
        
        let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.Exam_ClassListTV, for: indexPath) as! Exam_ClassListTV
        
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
