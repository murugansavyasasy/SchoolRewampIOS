//
//  CountryVc.swift
//  VsSchoolChimes
//
//  Created by admin on 25/10/24.
//

import UIKit

@available(iOS 14.0, *)
class CountryVc: UIViewController {

    @IBOutlet weak var IndiaImg: UIImageView!
    @IBOutlet weak var ThailandImg: UIImageView!
    @IBOutlet weak var UsaImg: UIImageView!
    @IBOutlet weak var IndonasiaImg: UIImageView!
    @IBOutlet weak var UgandaImg: UIImageView!
    @IBOutlet weak var CanadaImg: UIImageView!
    @IBOutlet weak var canadaLabel: UILabel!
    @IBOutlet weak var IndonasiaLabel: UILabel!
    @IBOutlet weak var ThaiLabel: UILabel!
    @IBOutlet weak var IndiaLbl: UILabel!
    
    @IBOutlet weak var UsaLbl: UILabel!
    
    @IBOutlet weak var UgandaLbl: UILabel!
    @IBOutlet weak var CountrynameLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var TermsLabel: UILabel!
    @IBOutlet weak var ClickArrowImg: UIImageView!
    @IBOutlet weak var fullview: UIView!
    
    
    @IBOutlet weak var checkBoxView: CheckBox!
    @IBOutlet weak var Canada: UIView!
    @IBOutlet weak var Indonasia: UIView!
    @IBOutlet weak var Uganda: UIView!
    @IBOutlet weak var Usa: UIView!
    @IBOutlet weak var thailand: UIView!
    @IBOutlet weak var india: UIView!
   
    var CountryCheck = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StyleAndTranslater()

      
        checkBoxView.isChecked = false
        fullview.backgroundColor = Colornames.countryClr
        view.backgroundColor = Colornames.countryClr
        ClickArrowImg.layer.cornerRadius = ClickArrowImg.frame.width/2
        ClickArrowImg.clipsToBounds = true
        india.layer.cornerRadius = india.frame.width/2
        Usa.layer.cornerRadius = Usa.frame.width/2
        Uganda.layer.cornerRadius = Indonasia.frame.width/2
        
        thailand.transform = CGAffineTransform(rotationAngle: .pi / 4) // Rotate 45 degrees
        ThaiLabel.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        ThailandImg.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        thailand.layer.cornerRadius = 20
        
        Indonasia.transform = CGAffineTransform(rotationAngle: .pi / 4) // Rotate 45 degrees
        IndonasiaLabel.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        IndonasiaImg.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        Indonasia.layer.cornerRadius = 20
        
        Canada.transform = CGAffineTransform(rotationAngle: .pi / 4) // Rotate 45 degrees
        canadaLabel.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        CanadaImg.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        Canada.layer.cornerRadius = 20
       
        let tap  = UITapGestureRecognizer(target: self, action:#selector(GotToNextVc))
        ClickArrowImg.isUserInteractionEnabled = true
        ClickArrowImg.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(GotoTermsVc))
        TermsLabel.addGestureRecognizer(tap1)
        TermsLabel.isUserInteractionEnabled = true
        
    }
    
    func StyleAndTranslater(){
        
        //MARK: Label font
//        canadaLabel.setFont(style: .body, size: FontSize.BodySize)
//        IndonasiaLabel.setFont(style: .body, size: FontSize.BodySize)
//        ThaiLabel.setFont(style: .body, size: FontSize.BodySize)
        CountrynameLbl.setFont(style: .body, size: FontSize.BodySize)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        TermsLabel.setFont(style: .title, size: FontSize.TitleSize)

        IndiaLbl.setFont(style: .body, size: FontSize.BodySize)
        ThaiLabel.setFont(style: .body, size: FontSize.BodySize)
        UsaLbl.setFont(style: .body, size: FontSize.BodySize)
        IndonasiaLabel.setFont(style: .body, size: FontSize.BodySize)
        UgandaLbl.setFont(style: .body, size: FontSize.BodySize)
        canadaLabel.setFont(style: .body, size: FontSize.BodySize)
        //MARK: Button font
//        Canada.setTitleFont(style: .body, size: FontSize.BodySize)
//        Singapore.setTitleFont(style: .body, size: FontSize.BodySize)
//        China.setTitleFont(style: .body, size: FontSize.BodySize)
//        Usa.setTitleFont(style: .body, size: FontSize.BodySize)
//        thailand.setTitleFont(style: .body, size: FontSize.BodySize)
//        indiabutton.setTitleFont(style: .body, size: FontSize.BodySize)
////        configureButton(
//            ,
//            imageName: UIImage(named: ""),
//            gradientColors:[UIColor.yellow,UIColor.red],lightenFactor: 0.8, opacity: 0.4// 40% lighter
//        )
//        if let image = UIImage(named: "india1") {
//            configureButton(
//                indiabutton,
//                imageName: image,
//                cornerRadius: 15
//            )
//        }
//        if let image = UIImage(named: "thailand") {
//            configureButton(
//                thailand,
//                imageName: image,
//                cornerRadius: 15
//            )
//        }
//        if let image = UIImage(named: "USA") {
//            configureButton(
//                Usa,
//                imageName: image,
//                cornerRadius: 15
//            )
//        }
//        if let image = UIImage(named: "indonesia") {
//            configureButton(
//                China,
//                imageName: image,
//                cornerRadius: 15
//            )
//        }
//        if let image = UIImage(named: "uganda") {
//            configureButton(
//                Singapore,
//                imageName: image,
//                cornerRadius: 15
//            )
//        }
//        if let image = UIImage(named: "canada") {
//            configureButton(
//                Canada,
//                imageName: image,
//                cornerRadius: 15
//            )
//        }
        
    }
    func configureButton(
        _ button: UIButton,
        imageName: UIImage?,
        cornerRadius: CGFloat = 10
    ) {
        // Set corner radius
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true

        // Set only the image
        if let image = imageName {
            button.setImage(image, for: .normal)
            button.contentHorizontalAlignment = .fill
            button.contentVerticalAlignment = .fill
            button.imageView?.contentMode = .scaleAspectFill // Ensure the image scales to fit the button
        }
    }


    @IBAction  func GotoTermsVc(){
        
        let vc = TermsAndCondVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    
    }
    
    @IBAction  func GotToNextVc(){
        
        if checkBoxView.isChecked == true {
                        
            
            var term : String = "1"
            
            let userDefault = UserDefaults.standard
            userDefault.set(term, forKey: DefaultsKeys.countryId)

            let vc = LoginVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        }else{
            view.makeToast(AlertstringFile.Terms_And_Conditions)
        }
    }
   

}
