//
//  CountryVc.swift
//  VsSchoolChimes
//
//  Created by admin on 25/10/24.
//

import UIKit
import DropDown
import Kingfisher

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
    
    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var UsaLbl: UILabel!
    
    @IBOutlet weak var flagImg: UIImageView!
    @IBOutlet weak var countyNameBtn: UIButton!
    @IBOutlet weak var UgandaLbl: UILabel!
    @IBOutlet weak var CountryList: UIView!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var TermsLabel: UILabel!
    @IBOutlet weak var ClickArrowImg: UIImageView!
    @IBOutlet weak var fullview: UIView!
    
    
    //    @IBOutlet weak var checkBoxView: CheckBox!
    @IBOutlet weak var Canada: UIView!
    @IBOutlet weak var Indonasia: UIView!
    @IBOutlet weak var Uganda: UIView!
    @IBOutlet weak var Usa: UIView!
    @IBOutlet weak var thailand: UIView!
    @IBOutlet weak var india: UIView!
    let dropDown = DropDown()
    var CountryCheck = 0
    var images = [UIImage]()
    var dropDownList = [String]()
    var CountryListRespons : [CountryData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        get_CountryListApi()
        StyleAndTranslater()
        
        
        //        checkBoxView.isChecked = false
        fullview.backgroundColor = Colornames.countryClr
        view.backgroundColor = Colornames.countryClr
        ClickArrowImg.layer.cornerRadius = ClickArrowImg.frame.width/2
        flagImg.layer.cornerRadius = flagImg.frame.width/2
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
        
        //        CountrynameLbl.setFont(style: .body, size: FontSize.BodySize)
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
    @IBAction func checkBox(_ sender: UIButton) {
        checkBoxBtn.isSelected.toggle()
        let image = checkBoxBtn.isSelected ? UIImage(named: "checked_Tick"):UIImage(named: "CheckCircle")

        checkBoxBtn.setImage(image, for: .normal)
    }
    
    @IBAction func selectCountry(_ sender: UIButton) {
        dropDown.anchorView = CountryList
        dropDown.dataSource = dropDownList
        dropDown.imageURLs = images
        dropDown.show()
        dropDown.bottomOffset = CGPoint(x: 0, y: CountryList.bounds.height)
        dropDownBtn.setImage( UIImage(systemName: "chevron.up"), for: .normal)
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            flagImg.image = images[index]
            countyNameBtn.setTitle(item, for: .normal)
            dropDownBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
        dropDown.cancelAction = { [weak self] in
            self?.dropDownBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
        
    }
    func get_CountryListApi() {
        APIService.shared.makeApi(url: ServiceUrl.country_list, parameters: [:], type: ApitTypeSringFile.GET, token: "") { [self] (result: Result<CountryListSuccess, Error>) in
            switch result {
            case .success(let successMessage):
                print("get_meeting_detailsApi", result)
                print("successMessage", result)
                
                if successMessage.status == true {
                    DispatchQueue.main.async { [self] in
                        CountryListRespons = successMessage.data
                        dropDownList.removeAll()
                        images.removeAll()
                        
                        for i in 0..<(CountryListRespons?.count ?? 0) {
                            if let countryName = CountryListRespons?[i].country_name,
                               let flagURL = CountryListRespons?[i].flag_url {  // Fixed missing comma and variable name
                               
                                loadImage(from: flagURL) { image in
                                    if let img = image {
                                        images.append(img)  // Append loaded image to array
                                    } else {
                                        if let placeholder = UIImage(named: "placeholder") {
                                            images.append(placeholder)  // Fallback image
                                        }
                                    }
                                    dropDownList.append(countryName)  // Ensuring the order is maintained
                                }
                            }
                        }

                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil) // Invalid URL
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image) // Return the image
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil) // Failed to load
                }
            }
        }
    }
    
    
    @IBAction  func GotoTermsVc(){
        
        let vc = TermsAndCondVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    @IBAction  func GotToNextVc(){
        if checkBoxBtn.isSelected{
            let vc = LoginVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    
}
