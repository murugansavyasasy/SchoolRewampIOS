//
//  HomeWorkPdfImageShomViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 08/11/23.
//  Copyright © 2023 Gayathri. All rights reserved.
//

import UIKit
import WebKit


class HomeWorkPdfImageShomViewController: UIViewController {

    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var web_view: WKWebView!
    
    var webUrl : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("webUrl",webUrl)
        let url = URL (string: webUrl)
               let requestObj = URLRequest(url: url!)
        web_view.load(requestObj)

        
        let backGes = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGes)
        
        // Do any additional setup after loading the view.
    }


    
    @IBAction func backVc() {
        
        
        dismiss(animated: true)
        
    }
    

}
