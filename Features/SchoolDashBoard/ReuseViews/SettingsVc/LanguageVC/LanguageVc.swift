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
        language(language: "Tamil", languageCode: "ta-IN", selected: false, DisplayName: "தமிழ்",ButtonText: "உறுதிப்படுத்தவும்"),
        language(language: "English", languageCode: "en", selected: false, DisplayName: "English",ButtonText: "Confirm"),
        language(language: "Hindi", languageCode: "hi", selected: false, DisplayName: "हिंदी",ButtonText: "पुष्टि करें"),
        language(language: "Thai", languageCode: "th", selected: false, DisplayName: "ไทย",ButtonText: "ยืนยัน"),
        language(language: "Arabic", languageCode: "ar", selected: false, DisplayName: "العربية",ButtonText: "تأكيد")
    ]
    
    var index:Int?
    var languageCode = "en"
    var delegate:BaktoHome?
    var isLanguageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        SelectLangLabel.setFont(style: .title, size: FontSize.TitleSize)
        
        if let savedLanguageCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) {
            index = Items.firstIndex(where: {$0.languageCode == savedLanguageCode})
        }else {
            index = Items.firstIndex(where: {$0.languageCode == "en"})
        }
        
        Items[index ?? 0].selected = true
        baseview.layer.cornerRadius = Colornames.CORadius15
        ConfirmBtn.layer.cornerRadius = Colornames.CORadius10
        ConfirmBtn.backgroundColor = .lightGray
        ConfirmBtn.setTitle(Items[index ?? 0].ButtonText, for: .normal) // Use setTitle(_:for:) here
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
        
        if isLanguageSelected{
            let userDefault = UserDefaults.standard
            userDefault.set(languageCode, forKey: DefaultsKeys.Language)
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
            ConfirmBtn.setTitle(Items[index ?? 0].ButtonText, for: .normal)
            cell.RadioImage.image = ImageName.checkedTick
            cell.LangIconImg.tintColor = .systemOrange
        }else{
            cell.RadioImage.image = ImageName.CheckCircle
            cell.LangIconImg.tintColor = .lightGray
        }
        
        cell.LangLbl.text = Items[indexPath.row].language
        cell.OriginalLangLbl.text = Items[indexPath.row].DisplayName
        cell.LangIconImg.image = UIImage(named: Items[indexPath.row].language)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isLanguageSelected = true
        index = indexPath.row
        languageCode = Items[indexPath.row].languageCode
        ConfirmBtn.backgroundColor = .backGroundClr
        tv.reloadData()
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
    let DisplayName:String
    let ButtonText: String
}

