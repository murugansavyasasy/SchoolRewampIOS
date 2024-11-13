//
//  LanguageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 08/11/24.
//

import UIKit

class LanguageVc: UIViewController {
   

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    var languageCode = "en"
   
    @IBOutlet weak var baseview: UIView!
    var selectedLanguage: String?
    
    var Items = [language(language: "English", selected: false),
                 language(language: "Tamil", selected: false),
                 language(language: "Hindi", selected: false),
                 language(language: "Thai", selected: false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let index = UserDefaults.standard.integer(forKey: "index")
        Items[index].selected = true
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        baseview.layer.cornerRadius = 15
        if #available(iOS 14.0, *) {
            tv.dataSource = self
            tv.delegate = self
        } else {
            // Fallback on earlier versions
        }
       
        tv.reloadData()
//        let defaults = UserDefaults.standard
//        languageCode = defaults.string(forKey: DefaultsKeys.Language)!
//        print("languageCodelanguageCode",languageCode)
        let nib = UINib(nibName: CellConfingName.LangTvCellTableViewCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:  CellConfingName.LangTvCellTableViewCell)
    }


    @IBAction func backClick(_ sender: Any) {
        
        dismiss(animated: true)
    }
    

}

    
@available(iOS 14.0, *)
extension LanguageVc : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LangTvCellTableViewCell , for: indexPath) as! LangTvCellTableViewCell
        if Items[indexPath.row].selected == true{
            selectedLanguage = Items[indexPath.row].language
        }
        
        cell.LangLbl.text = Items[indexPath.row].language
        cell.RadioImage.image = Items[indexPath.row].selected == true ? UIImage(named: "checked_Tick"): UIImage(named: "CheckCircle")
        return cell
    }

    
            
            
            
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(indexPath.row, forKey: "index")

        selectedLanguage = Items[indexPath.row].language
        
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
                // Save the selected language code to UserDefaults
                userDefault.set(languageCode, forKey: DefaultsKeys.Language)
                
                print("languageCode",DefaultsKeys.Language)
                // Apply the language immediately
                userDefault.synchronize()
                
                // Reload table view to update checkbox images
                tv.reloadData()
                // Present the next view controller
                let vc = TapBarVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
    }
            
            func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                
                return  60
            }
            
        }
        
    
struct language{
    let language:String
    var selected:Bool
}

