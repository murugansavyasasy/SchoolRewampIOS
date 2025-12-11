//
//  LanguageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 08/11/24.
//

import UIKit
protocol BaktoHome{
    func backtohome(type:String)
}
@available(iOS 14.0, *)
class LanguageVc: UIViewController {
    
    @IBOutlet weak var SelectLangLabel: UILabel!
    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var baseview: UIView!
    
    var Items = [
        language(language: "Tamil", languageCode: "ta-IN", selected: false),
        language(language: "English", languageCode: "en", selected: false),
        language(language: "Hindi", languageCode: "hi", selected: false),
        language(language: "Thai", languageCode: "th", selected: false),
        language(language: "Arabic", languageCode: "ar", selected: false)]
    
    var Language = ["தமிழ்", "English","हिंदी", "ไทย", "العربية"]
    var Buttontext = ["உறுதிப்படுத்தவும்","Confirm","पुष्टि करें", "ยืนยัน", "تأكيد"]
    var index:Int?
    var languageCode = "en"
    var delegate:BaktoHome?
    var selectedLanguage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        SelectLangLabel.setFont(style: .title, size: FontSize.TitleSize)
        if UserDefaults.standard.object(forKey: "index") != nil {
            index = UserDefaults.standard.integer(forKey: "index")
        }else {
            index = 1
        }
        
        Items[index ?? 1].selected = true
        baseview.layer.cornerRadius = Colornames.CORadius15
        ConfirmBtn.layer.cornerRadius = Colornames.CORadius10
        ConfirmBtn.backgroundColor = .lightGray
        ConfirmBtn.setTitle(Buttontext[index ?? 1], for: .normal) // Use setTitle(_:for:) here
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
            userDefault.synchronize()
            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name("LANGUAGE_CHANGED"), object: nil)
            MenuTapbar.shared = MenuTapbar()
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
        let homeVC = TapBarVC(nibName: "TapBarVC", bundle: nil)
        homeVC.login_astype = value
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
            ConfirmBtn.setTitle(Buttontext[index ?? 1], for: .normal)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  75
    }
    
    func adjustTableViewHeight() {
        let totalHeight = CGFloat(Items.count) * 75.0
        tableViewHeightConstraint.constant = totalHeight
        self.baseview.layoutIfNeeded()
    }
}

struct language{
    let language:String
    let languageCode:String
    var selected:Bool
}

