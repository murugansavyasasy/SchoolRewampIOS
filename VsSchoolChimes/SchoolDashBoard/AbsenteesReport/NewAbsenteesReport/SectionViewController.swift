
import UIKit

class SectionViewController: UIViewController, sectionCellDelegate {
    
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var Searchbar: UISearchBar!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var EmptyView: UIView!
    var ClickID = 0
    var sectionId : String?
    var SelectedDate : String?
    var section_wiseData: [SectionWise]?
    var absentStudentData: [AbsentisReportStudent]?
    var searchStudentData: [AbsentisReportStudent]?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: staffDetails?.school_name ?? "")
        Searchbar.searchTextField.addDoneButton()
        Searchbar.delegate = self
        
        NodataLbl.isHidden = true
        NoDataImage.isHidden = true
        EmptyView.isHidden = true
        
        cv.register(UINib(nibName: CellConfingName.SectionCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.SectionCollectionViewCell)
       
        let rowNib = UINib(nibName: CellConfingName.SectionTvTableViewCell, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: CellConfingName.SectionTvTableViewCell)
        
        cv.dataSource = self
        cv.delegate = self
        tv.delegate = self
        tv.dataSource = self
        
        if let sectionId = section_wiseData?.first?.section_id, let date = SelectedDate {
            AbsentStudent(sectionId:sectionId,date:date)
        }
    }
    
    @IBAction func BackAct(){
        dismiss(animated: true)
    }
    
    func AbsentStudent(sectionId:String,date:String) {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        let param = [AbsenteesReportStringFile.absent_on: date,AbsenteesReportStringFile.section_id: sectionId]
        APIService.shared.makeApi(
            url: ServiceUrl.stud_attd_api_attendance_get_absentees_students_by_date,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token:staffDetails?.access_token ?? "") { [self] (result: Result<AbsentisReportStudentResponse, Error>) in
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self.hideActivityLoader()
                    }
                    
                    switch result {
                        
                    case .success(let successMessage):
                       
                            DispatchQueue.main.async { [self] in
                                
                                absentStudentData = successMessage.data
                                searchStudentData = successMessage.data
                                NodataLbl.isHidden = !successMessage.data.isEmpty
                                NoDataImage.isHidden = !successMessage.data.isEmpty
                                EmptyView.isHidden = !successMessage.data.isEmpty
                                NodataLbl.text = successMessage.message
                                tv.reloadData()
                            }
                     
                    case .failure(let error):
                        print(error.localizedDescription)
                        if self.absentStudentData?.count == 0{
                            self.tv.isHidden = true
                        }
                        
                    }
                }
            }
    }
    
    
}

extension SectionViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section_wiseData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellConfingName.SectionCollectionViewCell ,
            for: indexPath) as? SectionCollectionViewCell else{
            
            return UICollectionViewCell()
        }
        
        cell.sectionNameLbl.text = section_wiseData?[indexPath.item].section_name
        cell.absentcountLbl.text = section_wiseData?[indexPath.item].total_absentees
        
        if ClickID == indexPath.item {
            cell.sectionClick.backgroundColor = .gradient1
            cell.sectionNameLbl.textColor = .black
            cell.absentcountLbl.textColor = .black
        }
        else{
            cell.sectionClick.backgroundColor = .systemGray6
            cell.sectionNameLbl.textColor = .gray
            cell.absentcountLbl.textColor = .gray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickID = indexPath.row
       
        if let sectionId = section_wiseData?[indexPath.item].section_id, let date = SelectedDate {
            AbsentStudent(sectionId:sectionId,date:date)
        }
        
        cv.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 157, height: 58)
    }
}

extension SectionViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchStudentData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.SectionTvTableViewCell,
            for: indexPath) as? SectionTvTableViewCell else{
            return UITableViewCell()
        }
        
        let absentdata = searchStudentData?[indexPath.row]
        
        cell.nameLbl.text = absentdata?.student_name
        cell.SectionLbl.isHidden = true
        cell.AddmisionLbl.text = "Admission No: " + (absentdata?.admission_no ?? "")
        cell.phonenumber = absentdata?.primary_mobile
        cell.RollNoLbl.text = "Roll No: " + (absentdata?.roll_no ?? "")
        cell.MobileNoBtn.setTitle(absentdata?.primary_mobile, for: .normal)
        cell.profileImageView.sd_setImage(with: URL(string: absentdata?.photo_path ?? ""), placeholderImage: ImageName.Default_profile)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func didTapPhoneNo(phoneNo:String) {
        if let url = URL(string: "tel://\(phoneNo.replacingOccurrences(of: " ", with: ""))"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension SectionViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            
            searchStudentData = absentStudentData
        }else {
            
            searchStudentData = absentStudentData?.filter{absent in
                
                (absent.admission_no?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (absent.student_name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (absent.roll_no?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (absent.primary_mobile?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        NodataLbl.isHidden = !(searchStudentData?.isEmpty ?? false)
        NoDataImage.isHidden = !(searchStudentData?.isEmpty ?? false)
        EmptyView.isHidden = !(searchStudentData?.isEmpty ?? false)
        NodataLbl.text = "No Data Found"
        tv.reloadData()
    }
}

