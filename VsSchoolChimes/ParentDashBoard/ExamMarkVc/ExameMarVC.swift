//
//  ExameMarVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit

class ExameMarVC: UIViewController {

    @IBOutlet weak var cv: UICollectionView!
    var exameList: [ExamItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CellRegister()
        cv.dataSource = self
        cv.delegate = self
        examListApi()
    }

    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5), endPoint: CGPoint(x: 0, y: 0.5))
    }

    func examListApi() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<ExamListResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self?.hideLottieProgressLoader() }
                switch result {
                case .success(let response):
//                    if response.status{
                        self?.exameList = response.data
                        self?.cv.reloadData()
//                    }else{
//                        not
//                    }
                   
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }


    func CellRegister() {
        cv.register(UINib(nibName: CellConfingName.ExamMarkCV, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ExamMarkCV)
    }

    @objc func ViewMarks(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let index = view.tag

        guard let examID = exameList?[index].id else { return }
        let vc = MarkListVC()
        vc.modalPresentationStyle = .fullScreen
        vc.ExamTitle = exameList?[index].name
        vc.examId = examID
        present(vc, animated: false)
       
    }
    
    func View_Marks_Action(index:Int){
        
        guard let examID = exameList?[index].id else { return }
        let vc = MarkListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.ExamTitle = exameList?[index].name
        vc.examId = examID
        present(vc, animated: false)
    }
    
    func View_progress_Act(index:Int){
        
        guard let examID = exameList?[index].id else { return }
        let vc = ViewProgressVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.examId = examID
        vc.backBtnTitle = exameList?[index].name ?? ""
        present(vc, animated: false)
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
    
    func view_ProgressCard(url:String){
        let vc = ImageShowVc(nibName: nil, bundle: nil)
        vc.pdfUrl = url
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func ViewProgress(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let index = view.tag

        guard let examID = exameList?[index].id else { return }
        let vc = ViewProgressVC()
        vc.modalPresentationStyle = .fullScreen
        vc.examId = examID
        vc.backBtnTitle = exameList?[index].name ?? ""
        present(vc, animated: false)
       
    }

}


// MARK: - CollectionView
extension ExameMarVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exameList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: CellConfingName.ExamMarkCV, for: indexPath) as! ExamMarkCV
        
        let exam = exameList?[indexPath.row]
        
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
        let width = cv.frame.width / 2.2
        return CGSize(width: width, height: 160)
    }
}

