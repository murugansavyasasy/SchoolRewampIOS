//
//  PreviewTargetTVC.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 14/10/25.
//

import UIKit

class PreviewTargetTVC: UITableViewCell {
    
    @IBOutlet weak var yourTargetLbl: UILabel!
    @IBOutlet weak var yourTargetImageView: UIImageView!
    @IBOutlet weak var targetCvHeight: NSLayoutConstraint!
    @IBOutlet weak var targetCv: UICollectionView!
    var targetCvdata : [targetInfoData] = []
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var targetId : String?
    var TargetType : String?
    var isStandardSection : Bool = false
    var standarSenction : [String] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        targetCv.register(UINib(nibName: "TargetCvCell", bundle: nil), forCellWithReuseIdentifier: "TargetCvCell")
        targetCv.delegate = self
        targetCv.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        targetCv.collectionViewLayout = layout
    }
    func confic(TargetType:String,id:String){
        self.TargetType = TargetType
        self.targetId = id
       
            getTargetReport(targetIdOrType: targetId ?? "", TargetType: TargetType)
        
    }
}
extension PreviewTargetTVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isStandardSection{
            return standarSenction.count
        }else{
            return targetCvdata.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TargetCvCell", for: indexPath) as? TargetCvCell else {
            return UICollectionViewCell()
        }

        
        if yourTargetLbl.text == "Sent To Standard" {
            cell.nameLbl.text = "🎓 " + (
                targetCvdata[indexPath.row].standard ?? ""
            )
                   }else if yourTargetLbl.text == "Sent To School" {
                       cell.nameLbl.text = "🏫 " + (
                        targetCvdata[indexPath.row].institudeName ?? ""
                       )
                   }
        else if yourTargetLbl.text == "Sent To Groups"{
            
            cell.nameLbl.text = "🏫 " + (
                targetCvdata[indexPath.row].groupName ?? ""
            )
        }
        else if yourTargetLbl.text == "Sent To Staff" || yourTargetLbl.text == "Sent To Students"  {
            
            cell.nameLbl.text = "👤 " + (
                targetCvdata[indexPath.row].name ?? ""
            )
        }
        else if yourTargetLbl.text == "Sent To Standard/Section"{
            cell.nameLbl.text = "👤 " + standarSenction[indexPath.row]
                   }
        
        
        return  cell
    }
    
    
    func getTargetReport(targetIdOrType : String,TargetType:String) {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_target_details,
            parameters: ["id": targetIdOrType, "target_type":TargetType ],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<targetSuc, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.status == true{
                        self.targetCvdata = res.data?.first?.name ?? []
                        self.isStandardSection = false
                        if res.data?.first?.type == "STANDARD"{
                            self.yourTargetImageView.image = UIImage(systemName: "graduationcap.fill")
                            self.yourTargetLbl.text = "Sent To Standard"
                        }else if  res.data?.first?.type == "SCHOOL"{
                            self.yourTargetLbl.text = "Sent To School"
                            
                        } else if  res.data?.first?.type == "GROUP"{
                            self.yourTargetLbl.text = "Sent To Group"
                            self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                        }else if  res.data?.first?.type == "STUDENT"{
                            self.yourTargetLbl.text = "Sent To Students"
                            self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                        }else if  res.data?.first?.type == "SECTION"{
                            self.yourTargetLbl.text = "Sent To Standard/Section"
                            self.isStandardSection = true
                            self.standarSenction = res.data?.first?.name?.first?.std_sec ?? []
                            self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                        }else if  res.data?.first?.type == "STAFF"{
                            self.yourTargetLbl.text = "Sent To Staff"
                            self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                        }
                        self.reloadss()
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
    }
    
//    
//    func getSpeficTargetReport(targetIdOrType : String,TargetType:String) {
//        APIService.shared.makeApi(
//            url: ServiceUrl.comm_api_assignment_target_details,
//            parameters: ["id": targetIdOrType, "target_type":TargetType ],
//            type: ApitTypeSringFile.GET,
//            token: staffDetails?.access_token ?? ""
//        ) { [weak self] (result: Result<targetSucResp, Error>) in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let res):
//                    if res.status == true{
//                        self.speficTargetData = res.data ?? []
//                        self.yourTargetLbl.text  = "Studet"
//                        self.yourTargetImageView.image = UIImage(systemName: "graduationcap.fill")
//                        self.reloadss()
//                    }
//                case .failure(let err):
//                    print(err.localizedDescription)
//                    
//                }
//            }
//        }
//    }
    func reloadss(){
        targetCv.reloadData()
        targetCv.layoutIfNeeded()
        DispatchQueue.main.async {
            self.targetCvHeight.constant = self.targetCv.collectionViewLayout.collectionViewContentSize.height
        }
    }
}
