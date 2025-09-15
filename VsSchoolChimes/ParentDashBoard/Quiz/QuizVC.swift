//
//  QuizVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 17/01/25.
//

import UIKit

class QuizVC: UIViewController {

    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
   
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var IncorrectAnswerLbl: UILabel!
    @IBOutlet weak var CorrectAnswerLbl: UILabel!
    
    //var colours = ["lesson1","lesson2","lesson3"]
    let colours = ["AttendenceColor","Color","lesson1","lesson3"]
    var id = 0
    var correctoption : [Int] = []
    var selectedOption : [Int] = []
    var questions : [Question] = []
    var get_QuizDetails : [QuizListData] = []
    var correctAnswers = ""
    var incorrectAnswers = ""
    var childDetails = UserDefaultFileManager.get_child_Details()
    let images = ["Quiz1", "Quiz2", "Quiz3"]
    var stausType   = "1"
    override func viewDidLoad() {
        
        super.viewDidLoad()
        BackBtn.applyBackButton()

        StyleAndTranslate()
       
        CorrectAnswerLbl.text = "Correct Answers : " + " \(correctAnswers) / \(questions.count)"
        IncorrectAnswerLbl.text = "Incorrect Answers : " + " \(questions.count - (Int(correctAnswers) ?? 0)) / \(questions.count)"
       
        IncorrectAnswerLbl.isHidden = true
        CorrectAnswerLbl.isHidden = true
        
        CellRegister()
        
        tv.delegate = self
        tv.dataSource = self
//        tv.reloadData()
        Get_Quiz()

    }
    
    
    func Get_Quiz() {
       
        APIService.shared
            .makeApi(url: ServiceUrl.quiz_exam_list, parameters: ["type" : "2","status_type" : stausType], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") { [weak self] (
                result: Result<QuizListSuc,
                Error>
            ) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let successResponse):
                   
                    if successResponse.status == true{
                        
                        self.get_QuizDetails = successResponse.data ?? []
                        self.tv.reloadData()
                    }else{
                        
                        
                    }
                    
                    
                case .failure(let error):
                    print("Error fetching notices: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func StyleAndTranslate(){
        
        //MARK: UI Changes
       
        
        //MARK: Font Style
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
      
        BackBtn.setTitleFont(style: .body, size: 20)
        IncorrectAnswerLbl.setFont(style: .body, size: FontSize.BodySize)
        CorrectAnswerLbl.setFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Translate
        
    }
    
    //MARK: Cell Registration
    func CellRegister(){
        let nib = UINib(nibName: CellConfingName.QuizTVcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.QuizTVcell)
        
        let nib2 = UINib(nibName: CellConfingName.CompletedTVcell, bundle: nil)
        tv.register(nib2, forCellReuseIdentifier: CellConfingName.CompletedTVcell)
        
        let nib3 = UINib(nibName: CellConfingName.QuizListTvCell, bundle: nil)
        tv.register(nib3, forCellReuseIdentifier: CellConfingName.QuizListTvCell)
    }
    
//    override func viewDidLayoutSubviews() {
//        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//    }
//    
    func gradientcolours(button : UIButton,colours : [CGColor]){
        
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        // Create and configure the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.layer.cornerRadius
        // Insert the gradient layer into the button's layer
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func configureButton(
        _ button: UIButton,
        gradientColors: [UIColor],
        opacity: CGFloat = 0.5, // Opacity for the gradient
        lightenFactor: CGFloat = 0.3 // Factor to lighten colors (0 = no change, 1 = full white)
    ) {
        
        // Adjust colors for lightening and opacity
        let adjustedColors = gradientColors.map { color in
            color.blendedWithWhite(factor: lightenFactor).withAlphaComponent(opacity).cgColor
        }
        
        gradientcolours(button: button, colours: adjustedColors)
    }
    
    @IBAction func UpcomingAct(_ sender: Any) {
       
        IncorrectAnswerLbl.isHidden = true
        CorrectAnswerLbl.isHidden = true
        stausType = "1"
        Get_Quiz()
        
    }
    
    
    @IBAction func CompletedAct(_ sender: Any) {
        
        
        stausType = "2"
        Get_Quiz()
        
    }
    
    @available(iOS 14.0, *)
    @IBAction func BackAct(_ sender: Any) {
//        let vc = SchoolDashboardVc(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        dismiss(animated: true)
    }
}

//MARK: Tableview Delegate Functions
extension QuizVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return get_QuizDetails.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.QuizListTvCell, for: indexPath) as? quizCellTv else {
                return UITableViewCell()
            }
            let quiz = get_QuizDetails[indexPath.row]
               let imageName = images[indexPath.row % images.count]
//            cell.DeafultimageView.image = UIImage(named: imageName)
            
        cell.titleLbl.text = get_QuizDetails[indexPath.row].title?.capitalized
        cell.discretiponsLbl.text = get_QuizDetails[indexPath.row].description?.capitalized
//            cell.exameDateLbl.text = "Create on 16,Oct 2025 04:24 PM"
            cell.subjectLbl.text = get_QuizDetails[indexPath.row].subject
//            cell.postedByLbl.text = ("Posted By:") + (
//                get_QuizDetails[indexPath.row].SentBy ?? ""
//            )
            return cell
//        }
    }
    
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        if stausType == "1"{
            
            let vc = PlayQuizVc(nibName: nil, bundle: nil)
            vc.selectedQuizId = self.get_QuizDetails[indexPath.row].quiz_id
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }else{
            
            let vc = QuizCompletedVc(nibName: nil, bundle: nil)
//            vc.selectedQuizId = self.get_QuizDetails[indexPath.row].quiz_id
            vc.selected_QuizId = self.get_QuizDetails[indexPath.row].quiz_id
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


extension UIColor {
    func adjustedColor(brightnessFactor: CGFloat = 1.3, saturationFactor: CGFloat = 0.8) -> UIColor? {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = min(brightness * brightnessFactor, 1.0) // Increase brightness
            let newSaturation = max(saturation * saturationFactor, 0.0) // Reduce saturation
            
            return UIColor(hue: hue, saturation: newSaturation, brightness: newBrightness, alpha: alpha)
        }
        return nil
    }
}
