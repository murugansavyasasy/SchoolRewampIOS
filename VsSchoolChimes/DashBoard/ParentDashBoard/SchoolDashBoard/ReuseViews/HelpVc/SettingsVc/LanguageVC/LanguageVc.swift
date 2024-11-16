//
//  LanguageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 08/11/24.
//

import UIKit

@available(iOS 14.0, *)
class LanguageVc: UIViewController {
   

    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    var languageCode = "en"
   
    @IBOutlet weak var baseview: UIView!
    var selectedLanguage: String?
    
    var Items = [language(language: "English", selected: false),
                 language(language: "Tamil", selected: false),
                 language(language: "Hindi", selected: false),
                 language(language: "Thai", selected: false)]
    
    var Language = ["English","தமிழ்","हिंदी","ไทย"]
  var  Buttontext = ["Confirm","உறுதிப்படுத்தவும்","पुष्टि करें","ยืนยัน"]
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
         index = UserDefaults.standard.integer(forKey: "index")
        Items[index].selected = true
        
        let defaults = UserDefaults.standard
        
        languageCode = defaults.string(forKey:DefaultsKeys.Language)!
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        baseview.layer.cornerRadius = 15
        
        ConfirmBtn.layer.cornerRadius = 10
        

        
           ConfirmBtn.setTitle(Buttontext[index], for: .normal) // Use setTitle(_:for:) here
           ConfirmBtn.titleLabel?.textAlignment = .center
           ConfirmBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
            tv.dataSource = self
            tv.delegate = self
            tv.reloadData()
        
       
        tv.isScrollEnabled = false
               
               // Reload data and adjust the table height
               
              
       

        let nib = UINib(nibName: CellConfingName.LangTvCellTableViewCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:  CellConfingName.LangTvCellTableViewCell)
        
        adjustTableViewHeight()
        
    }


    @IBAction func backClick(_ sender: Any) {
       
        dismiss(animated: true)
    }
    
    @IBAction func ConfirmClick(_ sender: Any) {
        UserDefaults.standard.set(index, forKey: "index")
        let userDefault = UserDefaults.standard
        userDefault.set(languageCode, forKey: DefaultsKeys.Language)
        
        print("languageCode",DefaultsKeys.Language)
        
       
        // Apply the language immediately
        userDefault.synchronize()
        
        // Reload table view to update checkbox images
        //tv.reloadData()
        // Present the next view controller
        let vc = TapBarVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
         
               ConfirmBtn.setTitle(Buttontext[index], for: .normal)
               ConfirmBtn.titleLabel?.textAlignment = .center
               ConfirmBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.RadioImage.image = UIImage(named: "checked_Tick")
            cell.LangIconImg.tintColor = .systemOrange
           
        }else{

            cell.RadioImage.image = UIImage(named: "CheckCircle")
            cell.LangIconImg.tintColor = .lightGray
        }
        
        
        if Items[indexPath.row].selected == true{
            selectedLanguage = Items[indexPath.row].language
        }
        
        
        cell.LangLbl.text = Items[indexPath.row].language
        cell.OriginalLangLbl.text = Language[indexPath.row]
        cell.LangIconImg.image = UIImage(named: Items[indexPath.row].language)
        
//        cell.RadioImage.image = Items[indexPath.row].selected == true ? UIImage(named: "checked_Tick"): UIImage(named: "CheckCircle")
//        
        
        return cell
    }

    
            
            
            
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        selectedLanguage = Items[indexPath.row].language
        Items[indexPath.row].selected = true
        index = indexPath.row
        
                let userDefault = UserDefaults.standard
                // Default language is English
                
                // Set the language code based on the selection
                if selectedLanguage == "Tamil" {
                    languageCode = "ta-IN"
                } else if selectedLanguage == "Thai" {
                    languageCode = "th"
                } else if selectedLanguage == "Hindi" {
                    languageCode = "hi"
                } else if selectedLanguage == "English" {
                    languageCode = "en"
                }
//        UserDefaults.standard.set(indexPath.row, forKey: "index")
//                // Save the selected language code to UserDefaults
//                userDefault.set(languageCode, forKey: DefaultsKeys.Language)
//                
//                print("languageCode",DefaultsKeys.Language)
//                // Apply the language immediately
//                userDefault.synchronize()
//                
//                // Reload table view to update checkbox images
                tv.reloadData()
//                // Present the next view controller
//                let vc = TapBarVC(nibName: nil, bundle: nil)
//                vc.modalPresentationStyle = .fullScreen
//                present(vc, animated: true)
    }
            
            func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                
                return  75
            }
            
    func adjustTableViewHeight() {
            // Calculate the total height based on rows and row height
        let totalHeight = CGFloat(Items.count) * 75.0 // 60.0 is example row height; replace with your own
            
            // Set the height constraint to the calculated height
            tableViewHeightConstraint.constant = totalHeight

            // Update the layout with the new constraint value
        self.baseview.layoutIfNeeded()
        }
        }


        
    
struct language{
    let language:String
    var selected:Bool
}

