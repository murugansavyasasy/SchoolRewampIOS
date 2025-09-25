//
//  ExameMarVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit

class ExameMarVC: UIViewController {

    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var examList: [ExamItem]?
    var FilteredExamList: [ExamItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        searchBar.isHidden = true
        searchBar.placeholder = CommonStringFile.Search
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        NoDataLbl.setFont(style: .title, size: FontSize.TitleSize)
        cv.register(UINib(nibName: CellConfingName.ExamMarkCV, bundle: nil),forCellWithReuseIdentifier: CellConfingName.ExamMarkCV)
        cv.dataSource = self
        cv.delegate = self
        examListApi()
    }
    
    func examListApi() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<ExamListResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self?.hideActivityLoader() }
                switch result {
                case .success(let response):
                    
                    self?.examList = response.data
                    self?.FilteredExamList = response.data
                    self?.cv.reloadData()
                    self?.NoDataImage.isHidden = response.status ?? false
                    self?.NoDataLbl.isHidden = response.status ?? false
                    self?.NoDataLbl.text = response.message
                    
                case .failure(let error):
                    print("API Error:", error)
                    
                    self?.NoDataImage.isHidden = false
                    self?.NoDataLbl.isHidden = false
                    self?.NoDataLbl.text = error.localizedDescription
                }
            }
        }
    }
    
    func markListApi(exam_id: String) {
        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_get_progress_card,
            parameters: ["exam_id": exam_id],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        self.view_ProgressCard(url: success.data?.first ?? "")
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self) {
                        }
                    }
                    
                case .failure(let error):
                    print("API Error:", error)
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                }
            }
        }
    }
    
    func View_Marks_Action(index:Int){
        
        guard let examID = FilteredExamList?[index].id else { return }
        let vc = MarkListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.ExamTitle = FilteredExamList?[index].name
        vc.examId = examID
        present(vc, animated: false)
    }
    
    func view_ProgressCard(url: String) {
        let vc = ImageShowVc(nibName: nil, bundle: nil)
        
        if let fileURL = URL(string: url) {
            let fileType = fileURL.pathExtension.lowercased() // e.g. "pdf", "jpg", "png"
            vc.fileURL = [FilePath(url: url, type: fileType)]
        } else {
            vc.fileURL = [FilePath(url: url, type: "pdf")]
        }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }


}


// MARK: - CollectionView
extension ExameMarVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return FilteredExamList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: CellConfingName.ExamMarkCV, for: indexPath) as! ExamMarkCV
        
        let exam = FilteredExamList?[indexPath.row]
        
        cell.ExamLbl.text = exam?.name
        
        cell.onViewMark = { [weak self] in
            self?.View_Marks_Action(index: indexPath.row)
        }

        cell.OnViewProgress = { [weak self] in
            self?.markListApi(exam_id: exam?.id ?? "")
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = cv.frame.width / 2
        return CGSize(width: width, height: 160)
    }
}

extension ExameMarVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.lowercased()
        
        if query.isEmpty {
            FilteredExamList = examList
        } else {
            FilteredExamList = examList?.filter { examItem in
                examItem.name?.lowercased().contains(query) ?? false
            }
        }
        
        NoDataLbl.text = CommonStringFile.No_data_found
        NoDataLbl.isHidden = !(FilteredExamList?.isEmpty ?? false)
        NoDataImage.isHidden = !(FilteredExamList?.isEmpty ?? false)
        cv.reloadData()
    }
}


