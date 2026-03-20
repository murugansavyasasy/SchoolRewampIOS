//
//  MesstimeTabelVC.swift
//  School Chimes
//
//  Created by apple on 05/03/26.
//

import UIKit

class MesstimeTabelVC: UIViewController {

    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var DinnerView: UIView!
    @IBOutlet weak var BreakView: UIView!
    @IBOutlet weak var Lunch: UIView!
    @IBOutlet weak var breakFirstView: UIView!
    @IBOutlet weak var tabelview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async { [self] in
            tabelview.register(UINib(nibName: "MessTimeTabelTvCell", bundle: nil), forCellReuseIdentifier: "MessTimeTabelTvCell")
            tabelview.dataSource = self
            tabelview.delegate = self
            viewCornerradius(view:DinnerView )
            viewCornerradius(view:BreakView )
            viewCornerradius(view:Lunch )
            viewCornerradius(view:breakFirstView)
            fullview.layer.cornerRadius = 10
        }
        
    }

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
func viewCornerradius(view:UIView)
    {
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
    }


}
extension MesstimeTabelVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessTimeTabelTvCell", for: indexPath) as? MessTimeTabelTvCell else {
            return UITableViewCell()
        }
    return cell
    }
    
}
