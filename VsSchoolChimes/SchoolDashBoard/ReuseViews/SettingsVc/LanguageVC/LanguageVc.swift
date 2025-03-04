//
//  LanguageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 08/11/24.
//

import UIKit
protocol BaktoHome{
    func backtohome()
}
@available(iOS 14.0, *)
class LanguageVc: UIViewController {
    
    @IBOutlet weak var SelectLangLabel: UILabel!
    
    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    var languageCode = "en"
    var delegate:BaktoHome?
    @IBOutlet weak var baseview: UIView!
    var selectedLanguage: String?
    
    var Items = [
        language(language: "Tamil", selected: false),
        language(language: "English", selected: false),
        language(language: "Hindi", selected: false),
        language(language: "Thai", selected: false),
        language(language: "Arabic", selected: false)]

    
    var Language = ["தமிழ்", "English","हिंदी", "ไทย", "العربية"]
    var Buttontext = ["உறுதிப்படுத்தவும்","Confirm","पुष्टि करें", "ยืนยัน", "تأكيد"]
    var index:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("LanguageVc")
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        SelectLangLabel.setFont(style: .title, size: FontSize.TitleSize)
        
        index = UserDefaults.standard.integer(forKey: "index")
        Items[index ?? 1].selected = true
        
//        let defaults = UserDefaults.standard
//        
//        languageCode = defaults.string(forKey:DefaultsKeys.Language)!
        baseview.layer.cornerRadius = Colornames.CORadius15
        
        ConfirmBtn.layer.cornerRadius = Colornames.CORadius10
        ConfirmBtn.backgroundColor = .lightGray
        
        
        ConfirmBtn.setTitle(Buttontext[index ?? 0], for: .normal) // Use setTitle(_:for:) here
        ConfirmBtn.titleLabel?.textAlignment = .center
        ConfirmBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        ConfirmBtn.setTitleFont(style: .body, size: 14)
        tv.dataSource = self
        tv.delegate = self
        tv.reloadData()
        
        tv.isScrollEnabled = false
        
        
        let nib = UINib(nibName: CellConfingName.LangTvCellTableViewCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:  CellConfingName.LangTvCellTableViewCell)
        
        adjustTableViewHeight()
        
    }
    
    
    @IBAction func backClick(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
    @IBAction func ConfirmClick(_ sender: Any) {
        if ConfirmBtn.backgroundColor == .button{
            UserDefaults.standard.set(index, forKey: "index")
            let userDefault = UserDefaults.standard
            userDefault.set(languageCode, forKey: DefaultsKeys.Language)
            
            print("languageCode",languageCode)
            TranslationManager.shared.setLanguage(languageCode)
            
            // Apply the language immediately
            userDefault.synchronize()
            let value = UserDefaults.standard.integer(forKey: "passvalue")
            
            LanguageManager.shared.setLanguage(languageCode)
            //
            //                // Reload UI
            //        reloadApplication(value: value)
//            delegate?.backtohome()
//            dismiss(animated: true)
            //        let vc = TapBarVC(nibName: nil, bundle: nil)
            //        vc.passedValue = value
            //        vc.languageCode = languageCode
            //        vc.modalPresentationStyle = .fullScreen
            //        present(vc, animated: true)
            // Reload the entire application
//            let isRTL = (languageCode == "ar")  // Replace with your language-checking logic
//                UIView.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
            
                       guard let window = UIApplication.shared.keyWindow else { return }
                       let storyboard = UIStoryboard(name: "SplashStoryboard", bundle: nil)
                       let initialViewController = storyboard.instantiateInitialViewController()
                       window.rootViewController = initialViewController
                       window.makeKeyAndVisible()

                       // Optional: Add a transition animation
                       UIView.transition(with: window,
                                         duration: 0.3,
                                         options: .transitionCrossDissolve,
                                         animations: nil,
                                         completion: nil)
        }
    }
    
    // Reload the application to apply the new language
    func reloadApplication(value : Int) {
    
        
        let window = UIApplication.shared.windows.first

        // Instantiate the ViewController from the XIB file
        let homeVC = TapBarVC(nibName: "TapBarVC", bundle: nil)
        homeVC.passedValue = value
        // Set the new rootViewController to the window
        window?.rootViewController = homeVC
        window?.makeKeyAndVisible()
    }
    
  
        }
        
 
@available(iOS 14.0, *)
extension LanguageVc : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LangTvCellTableViewCell , for: indexPath) as! LangTvCellTableViewCell
        
        if index == indexPath.row{
            ConfirmBtn.setTitle(Buttontext[index ?? 0], for: .normal)
            ConfirmBtn.titleLabel?.textAlignment = .center
            ConfirmBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.RadioImage.image = ImageName.checkedTick
            cell.LangIconImg.tintColor = .systemOrange
        }else{
            cell.RadioImage.image = ImageName.CheckCircle
            cell.LangIconImg.tintColor = .lightGray
        }
        if Items[indexPath.row].selected == true{
            selectedLanguage = Items[indexPath.row].language
        }
        
        
        cell.LangLbl.text = Items[indexPath.row].language
        cell.OriginalLangLbl.text = Language[indexPath.row]
        cell.LangIconImg.image = UIImage(named: Items[indexPath.row].language)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the previously selected cell
        if let previousIndex = index, let previousCell = tableView.cellForRow(at: IndexPath(row: previousIndex, section: 0)) as? LangTvCellTableViewCell {
            previousCell.RadioImage.image = ImageName.CheckCircle // Change to unchecked image
            Items[previousIndex].selected = false
            previousCell.LangIconImg.tintColor = .lightGray
        }

        // Select the new cell
        if let cell = tableView.cellForRow(at: indexPath) as? LangTvCellTableViewCell {
            cell.RadioImage.image = ImageName.checkedTick
            cell.LangIconImg.tintColor = .systemOrange
            ConfirmBtn.setTitle(Buttontext[indexPath.row], for: .normal)
            ConfirmBtn.titleLabel?.textAlignment = .center
            ConfirmBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        }

        // Update selection
        selectedLanguage = Items[indexPath.row].language
        Items[indexPath.row].selected = true
        index = indexPath.row

        // Change Confirm Button color
        ConfirmBtn.backgroundColor = UIColor.button

        // Save language code
        let userDefault = UserDefaults.standard

        switch selectedLanguage {
            case "Tamil":
                languageCode = "ta-IN"
            case "Thai":
                languageCode = "th"
            case "Hindi":
                languageCode = "hi"
            case "English":
                languageCode = "en"
            case "Arabic":
                languageCode = "ar"
            default:
                break
        }
    }

    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.rectForRow(at: indexPath) as? LangTvCellTableViewCell{
//            cell.RadioImage.image = ImageName.checkedTick
//        }
//        ConfirmBtn.backgroundColor = UIColor.button
//        
//        selectedLanguage = Items[indexPath.row].language
//        Items[indexPath.row].selected = true
//        index = indexPath.row
//        
//        let userDefault = UserDefaults.standard
//        
//        if selectedLanguage == "Tamil" {
//            languageCode = "ta-IN"
//        } else if selectedLanguage == "Thai" {
//            languageCode = "th"
//        } else if selectedLanguage == "Hindi" {
//            languageCode = "hi"
//        } else if selectedLanguage == "English" {
//            languageCode = "en"
//        } else if selectedLanguage == "Arabic" {
//            languageCode = "ar"
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  75
    }
    
    func adjustTableViewHeight() {
        // Calculate the total height based on rows and row height
        let totalHeight = CGFloat(Items.count) * 75.0 // 60.0 is example row height; replace
        tableViewHeightConstraint.constant = totalHeight
        self.baseview.layoutIfNeeded()
    }
}




struct language{
    let language:String
    var selected:Bool
}

