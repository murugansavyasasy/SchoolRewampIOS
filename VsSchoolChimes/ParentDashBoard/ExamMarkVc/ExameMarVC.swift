//
//  ExameMarVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit

class ExameMarVC: UIViewController {

    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var cv: UICollectionView!
    var exameList: [ExamItem]?
    override func viewDidLoad() {
        super.viewDidLoad()

        StyleAndTranslate()
        SearchBar.addDoneButton()
        CellRegister()
        SearchBar.applyRightTxt()

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

  
    func StyleAndTranslate() {
        SearchBar.placeholder = CommonStringFile.Search.translated()
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
        vc.examId = examID
        present(vc, animated: false)
       
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
        cell.ExamLbl.text = exameList?[indexPath.row].name

        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewMarks(_:)))
        cell.ViewMarkBtnview.tag = indexPath.row
        cell.ViewMarkBtnview.addGestureRecognizer(tap)
        cell.ViewMarkBtnview.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(ViewProgress(_:)))
        cell.ViewProgress.tag = indexPath.row
        cell.ViewProgress.addGestureRecognizer(tap1)
        cell.ViewProgress.isUserInteractionEnabled = true

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = cv.frame.width / 2.2
        return CGSize(width: width, height: 160)
    }
}

// MARK: - SearchBar
extension ExameMarVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        SearchBar.resignFirstResponder()
    }
}
