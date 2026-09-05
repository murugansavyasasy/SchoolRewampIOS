//
//  concernListVc.swift
//  School Chimes
//
//  Created by apple on 24/08/26.
//

import UIKit

class concernListVc: UIViewController, DeleteConcerndata {
    func AknowledgeConcernData(index: Int, Aknowledgediscreption: String,Is_viewAknowledgemeny : Bool) {
        
        if Is_viewAknowledgemeny{
            
            AknowledgeDetailsInfo(mark: filteredConcerns[index])
        }else{
            
            alert.showAlertCancel(
                title: "Concern",
                message: "Are you sure you want to aknowledge this concern?",
                actionLbl1: "OK",
                actionLbl2: "Cancel",
                on: self,
                onOk: { [weak self] in
                    
                    guard let self = self else { return }
                    
                    postaknowleged(concernId: filteredConcerns[index].id, studentId: filteredConcerns[index].studentId, discreption: Aknowledgediscreption)
                },
                onNo: {
                    print("Cancelled")
                }
            )
        }
        
       
    }
    
    func addactionconcerndata(index: Int,Is_viewAction : Bool) {
        if Is_viewAction {
            
            ActionDetailsInfo(mark: filteredConcerns[index])
            
        }else{
            
            let vc = addConcernVc()
            vc.loginAsType = 1
            vc.selectedConcernListId = filteredConcerns[index].id
            vc.selectedStudentID = filteredConcerns[index].studentId
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
       
      
    }
    
    
    
    func deleteConcernData(index: Int) {
        alert.showAlertCancel(
            title: "Concern Deletion",
            message: "Are you sure you want to delete?",
            actionLbl1: "OK",
            actionLbl2: "Cancel",
            on: self,
            onOk: { [weak self] in
                
                guard let self = self else { return }
                
                deleteConcern(at: filteredConcerns[index].id)
            },
            onNo: {
                print("Cancelled")
            }
        )
    }
    
    @IBOutlet weak var toolBarLbl: UILabel!
    @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var tabelview: UITableView!
    private var allConcerns: [Concern] = []
    private var filteredConcerns: [Concern] = []
    private var searchQuery: String = ""
    private var activeFilter: ConcernStatus? = nil // nil = "All"
    private var  alert = CustomAlert()
    var loginAsType : Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        getConcernList()
      
        if loginAsType == 2{
            toolbarHeight.constant = 0
        }
    }
    

    @IBAction func backBtnAct(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    
    private func setupTableView() {
        tabelview.dataSource = self
        tabelview.delegate = self
        tabelview.backgroundColor = UIColor(red: 243/255, green: 244/255, blue: 246/255, alpha: 1.0)
        // Register Cell XIB
        let cellNib = UINib(nibName: "ConcernTableViewCell", bundle: nil)
        tabelview.register(cellNib, forCellReuseIdentifier: "ConcernTableViewCell")
        // Automatic heights
        tabelview.rowHeight = UITableView.automaticDimension
        tabelview.estimatedRowHeight = 450
        // No separator lines (using card borders instead)
        tabelview.separatorStyle = .none
        // Add content padding
        tabelview.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
    }
    
    private func ActionDetailsInfo(mark: Concern) {
       
        let actionTaken_by = mark.actionTakenBy
        let action_taken_on = mark.actionTakenOn
        let description = mark.actionTaken
      
        let message = """
        • ACTION TAKEN BY: \(actionTaken_by)
        • ACTION TAKEN ON: \(action_taken_on)
        • DETAILS: \(description) 
        """
        
        let alert = UIAlertController(
            title: "• Action Taken Details",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func AknowledgeDetailsInfo(mark: Concern) {
        
        let ACKNOWLEDGED_by = mark.acknowledgedBy
        let ACKNOWLEDGED_on = mark.acknowledgedOn
        let acknowledgement = mark.acknowledgement
      
        let message = """
        • ACKNOWLEDGED BY: \(ACKNOWLEDGED_by)
        • ACKNOWLEDGED  ON: \(ACKNOWLEDGED_on)
        • REMARKS : \(acknowledgement) 
        """
        
        let alert = UIAlertController(
            title: "• Acknowledgement Details",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
   
    func postaknowleged(concernId:String,studentId:String,discreption:String){
        APIService.shared.makeApi(
            url: ServiceUrl.admin_api_parent_concern_action_taken,
            parameters: ["concern_id":concernId,"student_id":studentId,"action_taken":discreption,"action": "acknowledge"],
            type: ApitTypeSringFile.POST,
            token: loginAsType == 2 ? UserDefaultFileManager.get_child_Details()?.access_token ?? "" : UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<ConcernResponse, Error>) in
            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if response.status{
                        CustomAlert.showAlertWithOkAction(title:AlertstringFile.Success , message: response.message, on: self, okAction: {
                            
                            self.getConcernList()
                        })
                    }else{
                        
                        self.alert.showAlert(title: AlertstringFile.Oops, message: response.message, on: self)
                    }
                case .failure(let error):
                    self.alert.showAlert(title: AlertstringFile.Oops, message: error.localizedDescription, on: self)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getConcernList(){
        APIService.shared.makeApi(
            url: ServiceUrl.admin_api_parent_concern_get_concerns,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: loginAsType == 2 ? UserDefaultFileManager.get_child_Details()?.access_token ?? "" : UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<ConcernResponse, Error>) in
            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if response.status{
                        self.filteredConcerns = response.data
                        self.tabelview.reloadData()
                    }else{
                        
                        self.filteredConcerns = []
                        self.tabelview.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteConcern(at id: String) {
        
        APIService.shared.makeApi(
            url: ServiceUrl.admin_api_parent_concern_delete,
            parameters: ["id": id],
            type: ApitTypeSringFile.PUT,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<CommonApiSuc, Error>) in
            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if response.status ?? false{
                        self.getConcernList()
                    }else{
                        
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}

extension concernListVc : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredConcerns.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ConcernTableViewCell",
            for: indexPath
        ) as! ConcernTableViewCell

        let concern = filteredConcerns[indexPath.row]

        // முதலில் properties set செய்யவும்
        cell.viewController = self
        cell.deleteDelegate = self
        cell.loginasTye = loginAsType

        cell.removeButton.tag = indexPath.row
        cell.acknowledgeButton.tag = indexPath.row
        cell.actionTakenButton.tag = indexPath.row

        // பிறகு configure செய்யவும்
        cell.configure(with: concern)

        loadFiles(into: cell, files: concern.filePath)
        actionTakenFile(into: cell, files: concern.actionFilePath)

        cell.noActionAttachmentsLabel.isHidden =
            !concern.actionFilePath.isEmpty

        cell.noParentAttachmentsLabel.isHidden =
            !concern.filePath.isEmpty

        return cell
    }
    
    func loadFiles(into cell: ConcernTableViewCell, files: [FilePath]) {
        [cell.img1, cell.img2, cell.img3].forEach { $0?.isHidden = true }
        cell.imgCountBtn.isHidden = true
        
        for (index, item) in files.enumerated() {
            guard index < 3 else { break }
            
            guard let urlString = item.url , let url = URL(string: urlString) else { continue }
            
            let imageViews = [cell.img1, cell.img2, cell.img3]
            guard index < imageViews.count, let imageView = imageViews[index] else { continue }
            
            imageView.isHidden = false
            
            if item.type?.lowercased() != "image" {
                let iconName = getFileIconName(for: url)
                imageView.image = UIImage(named: iconName)
            } else {
                imageView.kf.setImage(with: url)
            }
        }
        
        if files.count > 3 {
            let extraCount = files.count - 3
            if let button = cell.imgCountBtn {
                button.setTitle("+\(extraCount)", for: .normal)
                cell.imgCountBtn.isHidden = false
            }
        }
    }

    func actionTakenFile(into cell: ConcernTableViewCell, files: [FilePath]) {
        [cell.actionImg1, cell.actionImg2, cell.actionImg3].forEach { $0?.isHidden = true }
        cell.actionImgCoutBtn.isHidden = true
        
        for (index, item) in files.enumerated() {
            guard index < 3 else { break }
            
            guard let urlString = item.url , let url = URL(string: urlString) else { continue }
            
            let imageViews = [cell.actionImg1, cell.actionImg2, cell.actionImg3]
            guard index < imageViews.count, let imageView = imageViews[index] else { continue }
            
            imageView.isHidden = false
            
            if item.type?.lowercased() != "image" {
                let iconName = getFileIconName(for: url)
                imageView.image = UIImage(named: iconName)
            } else {
                imageView.kf.setImage(with: url)
            }
        }
        
        if files.count > 3 {
            let extraCount = files.count - 3
            if let button = cell.actionImgCoutBtn {
                button.setTitle("+\(extraCount)", for: .normal)
                cell.actionImgCoutBtn.isHidden = false
            }
        }
    }
}
