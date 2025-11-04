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
    
    var targetCvdata: [targetInfoData] = []
    var standarSenction: [String] = []
    
    var targetId: String?
    var targetType: String?
    var isStaffAndStudent: Bool = false
    
    private let staffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        targetCv.register(UINib(nibName: "TargetCvCell", bundle: nil),
                          forCellWithReuseIdentifier: "TargetCvCell")
        targetCv.delegate = self
        targetCv.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        targetCv.collectionViewLayout = layout
    }
    
    func configure(targetType: String, id: String) {
        self.targetType = targetType
        self.targetId = id
        getTargetReport(targetIdOrType: id, targetType: targetType)
    }
}

extension PreviewTargetTVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isStaffAndStudent ? standarSenction.count : targetCvdata.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TargetCvCell",
                                                            for: indexPath) as? TargetCvCell else {
            return UICollectionViewCell()
        }
        
        if isStaffAndStudent {
            cell.nameLbl.text = standarSenction[indexPath.row]
        } else {
            cell.nameLbl.text = targetCvdata[indexPath.row].name ?? ""
        }
        
        return cell
    }
}

extension PreviewTargetTVC {
    
    func getTargetReport(targetIdOrType: String, targetType: String) {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_target_details,
            parameters: ["id": targetIdOrType, "target_type": targetType],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<targetSuc, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    guard res.status == true, let firstData = res.data?.first else { return }
                    
                    self.yourTargetLbl.text = firstData.type
                    self.isStaffAndStudent = true // default
                    
                    switch firstData.type {
                    case "Message sent to STANDARD":
                        self.yourTargetImageView.image = UIImage(systemName: "graduationcap.fill")
                        self.standarSenction = firstData.name?.first?.standard ?? []
                        
                    case "Message sent to SCHOOL":
                        self.yourTargetImageView.image = UIImage(systemName: "building.2.fill")
                        self.standarSenction = firstData.name?.first?.institute ?? []
                        
                    case "Message sent to GROUP":
                        self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                        self.standarSenction = firstData.name?.first?.group ?? []
                        
                    case "Message sent to SECTION":
                        self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                        self.standarSenction = firstData.name?.first?.section ?? []
                        
                    case "Message sent to STUDENTS":
                        self.isStaffAndStudent = false
                        self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                        self.targetCvdata = firstData.name ?? []
                        
                    case "Message sent to STAFF":
                        self.isStaffAndStudent = false
                        self.yourTargetImageView.image = UIImage(systemName: "person.2.fill")
                        self.targetCvdata = firstData.name ?? []
                        
                    default:
                        break
                    }
                    
                    self.reloadCollectionViewHeight()
                    
                case .failure(let err):
                    print("Target API Error:", err.localizedDescription)
                }
            }
        }
    }
    
    private func reloadCollectionViewHeight() {
        targetCv.reloadData()
        targetCv.layoutIfNeeded()
        
        DispatchQueue.main.async {
            self.targetCvHeight.constant = self.targetCv.collectionViewLayout.collectionViewContentSize.height
        }
    }
}
