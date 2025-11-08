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
    @IBOutlet weak var IncorrectAnswerLbl: UILabel!
    @IBOutlet weak var CorrectAnswerLbl: UILabel!
    @IBOutlet weak var upcomingBtn: UIButton!
    @IBOutlet weak var CompletedBtn: UIButton!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var studentNameLbl: UILabel!
    
    
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
                   
                        self.get_QuizDetails = successResponse.data ?? []
                        let isempty = self.get_QuizDetails.isEmpty
                        self.tv.reloadData()
                        self.NoDataImage.isHidden = !isempty
                        self.NoDataLbl.isHidden = !isempty
                        self.NoDataLbl.text = successResponse.message ?? ""
                    
                    
                case .failure(let error):
                    print("Error fetching notices: \(error.localizedDescription)")
                    self.NoDataImage.isHidden = false
                    self.NoDataLbl.isHidden = false
                    self.NoDataLbl.text = error.localizedDescription
                }
            }
        }
    }
 
    func StyleAndTranslate(){
        
        //MARK: UI Changes
        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        addUnderline(to: upcomingBtn, unselectedButton: CompletedBtn)
        //MARK: Font Style
        NameLbl.setFont(style: .header, size: FontSize.HeaderSize)
      
        IncorrectAnswerLbl.setFont(style: .body, size: FontSize.BodySize)
        CorrectAnswerLbl.setFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Translate
        
        let name = childDetails?.name ?? ""
        let standard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        studentNameLbl.configureAsBackTitle(firstLine: name, secondLine: standard)
        NameLbl.text = MenuStringFile.selectedMenuName
        
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
    
    func addUnderline(to selectedButton: UIButton, unselectedButton: UIButton) {
        // Remove underline from both buttons
        [selectedButton, unselectedButton].forEach { button in
            button.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            button.tintColor = .black
        }
        
        // Add underline to the selected button
        selectedButton.tintColor = .systemBlue
        let underline = UIView()
        underline.tag = 999
        underline.backgroundColor = .systemBlue
        underline.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.addSubview(underline)
        
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor)
        ])
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
        addUnderline(to: upcomingBtn, unselectedButton: CompletedBtn)
        IncorrectAnswerLbl.isHidden = true
        CorrectAnswerLbl.isHidden = true
        stausType = "1"
        Get_Quiz()
        
    }
    
    
    @IBAction func CompletedAct(_ sender: Any) {
        addUnderline(to: CompletedBtn, unselectedButton: upcomingBtn)
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
        cell.LevelLbl.text = String(get_QuizDetails[indexPath.row].level ?? 0)
        cell.MaxmarkLbl.text = String(get_QuizDetails[indexPath.row].max_mark ?? 0)
        cell.NoOfQuestionLbl.text = String(get_QuizDetails[indexPath.row].no_of_questions ?? 0)
        cell.createdDateLbl.text = "Created on " + formattedDateStatus(from: get_QuizDetails[indexPath.row].created_on ?? "", isTimeNeeded: true)
        cell.PostByLbl.text = "Posted By: " + (
            get_QuizDetails[indexPath.row].SentBy ?? ""
        )
        let imgae = stausType == "1" ? UIImage(systemName: "play.fill") : UIImage(systemName: "arrowshape.right.fill")
        cell.playBtn.setImage(imgae, for: .normal)
        let title = stausType == "1" ? "Play Now" : ""
        cell.playBtn.setTitle(title, for: .normal)
        cell.playBtnWidth.constant = stausType == "1" ? 138 : 40
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
            vc.subjet_name = self.get_QuizDetails[indexPath.row].subject ?? ""
            vc.completed_date = self
                .get_QuizDetails[indexPath.row].submitted_on ?? ""
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
