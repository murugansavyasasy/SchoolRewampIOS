//
//  ImagePdfVC.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit

class ImagePdfVC: UIViewController {

    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        CellRegistre()
    }


    
    func CellRegistre(){
        tv.register(UINib(nibName: CellConfingName.ImagePdfTv, bundle: nil), forCellReuseIdentifier: CellConfingName.ImagePdfTv) //
    }
   

}

extension ImagePdfVC : UITableViewDelegate,UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ImagePdfTv, for: indexPath) as! ImagePdfTv
        
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    
    
    
}
