//
//  CreateViewAssignmentTabViewVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 04/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class CreateViewAssignmentTabViewVC: UIViewController {
    
    @IBOutlet weak var segmentControl   : UISegmentedControl!
    @IBOutlet weak var containerView    : UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private lazy var createViewController: CreateAssignmentVC = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "CreateAssignmentVC") as! CreateAssignmentVC
        
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    
    private lazy var assignmentViewController: StaffViewAssignmentVC = {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "StaffViewAssignmentVC") as! StaffViewAssignmentVC
        
        
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var schollViewController: AssignmentSchoolSelectionVC = {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "AssignmentSchoolSelectionVC") as! AssignmentSchoolSelectionVC
        viewController.ViewFrom = "view"
        
        
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    static func viewController() -> CreateViewAssignmentTabViewVC {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateViewAssignmentTabViewVC") as! CreateViewAssignmentTabViewVC
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        updateView()
    }
    
    // MARK:- Button Action
    @IBAction func actionBack(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        
        
        addChild(viewController)
        
        
        containerView.addSubview(viewController.view)
        
        
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        viewController.didMove(toParent: self)
    }
    
    
    private func remove(asChildViewController viewController: UIViewController) {
        
        viewController.willMove(toParent: nil)
        
        
        viewController.view.removeFromSuperview()
        
        
        viewController.removeFromParent()
    }
    
    private func updateView() {
        let isPrincipal = appDelegate.isPrincipal as NSString
        print("isPrincipalCreate",isPrincipal)
        print("isPrincipalisEqualCreate",isPrincipal .isEqual(to: "true"))
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        if segmentControl.selectedSegmentIndex == 0 {
            
            if(isPrincipal .isEqual(to: "true")){
                remove(asChildViewController: schollViewController)
                add(asChildViewController: createViewController)
            }else{
                remove(asChildViewController: assignmentViewController)
                add(asChildViewController: createViewController)
            }
            
        } else {
            
            
            if(isPrincipal .isEqual(to: "true")){
                remove(asChildViewController: createViewController)
                add(asChildViewController: schollViewController)
            }else{
                remove(asChildViewController: createViewController)
                add(asChildViewController: assignmentViewController)
            }
            
        }
    }
    
    func setupView() {
        updateView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callSelectedLanguage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }
            } catch {
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        segmentControl.setTitle(LangDict["create"] as? String, forSegmentAt: 0)
        segmentControl.setTitle(LangDict["view"] as? String, forSegmentAt: 1)
        
    }
}
