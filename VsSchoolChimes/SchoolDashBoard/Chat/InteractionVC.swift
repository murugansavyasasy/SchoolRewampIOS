//
//  InteractionVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/01/25.
//

import UIKit

class InteractionVC: UIViewController {
    @IBOutlet weak var NameStandardStackView: UIStackView!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var CV: UICollectionView!
    var passvalue = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        backBtn.applyBackButton()
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        HeaderLbl.setFont(style: .header, size: 17)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        let nib = UINib(nibName: CellConfingName.ChatCvcell, bundle: nil)
        CV.register(nib, forCellWithReuseIdentifier: CellConfingName.ChatCvcell)
        
        CV.delegate = self
        CV.dataSource = self
        CV.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        if passvalue == 1{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            backBtn.setTitle("Interact With Staff", for: .normal)
            NameStandardStackView.isHidden = false
        }
        else if passvalue == 2{
            backBtn.setTitle("Interact With Student", for: .normal)
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            NameStandardStackView.isHidden = true
        }
    }
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

extension InteractionVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CV.dequeueReusableCell(withReuseIdentifier: CellConfingName.ChatCvcell, for: indexPath)as! ChatCvcell
        let interactTap = UITapGestureRecognizer(target: self, action: #selector(OpenChat))
        cell.InteractBtn.addGestureRecognizer(interactTap)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CV.frame.width / 2.2
           return CGSize(width: width, height: 180)
       }

       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 2 // No spacing between items
       }

       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 10 // No spacing between rows
       }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.bounds.width, height: UICollectionViewFlowLayout.automaticSize.height)
//    }

    

    @objc func OpenChat(){
        let vc = ChatVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
       // vc.getValue = getValue
        present(vc, animated: true)
    }
}
