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
    @IBOutlet weak var ButtonStackview: UIStackView!
    
    @IBOutlet weak var UpcomingBtn: UIButton!
    
    @IBOutlet weak var CompletedBtn: UIButton!
    
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
    var correctAnswers = ""
    var incorrectAnswers = ""
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        CorrectAnswerLbl.text = "Correct Answers : " + " \(correctAnswers) / \(questions.count)"
        IncorrectAnswerLbl.text = "Incorrect Answers : " + " \(questions.count - (Int(correctAnswers) ?? 0)) / \(questions.count)"
        ButtonStackview.layer.cornerRadius = 20
        UpcomingBtn.layer.cornerRadius = 20
        CompletedBtn.layer.cornerRadius = 20
        
        configureButton(UpcomingBtn, gradientColors: [UIColor.blue,UIColor.green],opacity: 0.8,lightenFactor: 0.6)
        //gradientcolours(button: UpcomingBtn, colours: [Colornames.gradientgreen.cgColor,Colornames.gradientBlue.cgColor])
        
        UpcomingBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        CompletedBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        BackBtn.setTitleFont(style: .body, size: 20)
        CompletedBtn.tintColor = .lightGray
        IncorrectAnswerLbl.setFont(style: .body, size: FontSize.BodySize)
        CorrectAnswerLbl.setFont(style: .body, size: FontSize.BodySize)
        IncorrectAnswerLbl.isHidden = true
        CorrectAnswerLbl.isHidden = true
        
        let nib = UINib(nibName: CellConfingName.QuizTVcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.QuizTVcell)
        
        let nib2 = UINib(nibName: CellConfingName.CompletedTVcell, bundle: nil)
        tv.register(nib2, forCellReuseIdentifier: CellConfingName.CompletedTVcell)
        
        let nib3 = UINib(nibName: CellConfingName.QuizListTvCell, bundle: nil)
        tv.register(nib3, forCellReuseIdentifier: CellConfingName.QuizListTvCell)
        
        tv.delegate = self
        tv.dataSource = self

    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
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
        // Apply gradient
//        button.applyGradient(
//            colors: adjustedColors,
//            startPoint: CGPoint(x: 1, y: 0.5),
//            endPoint: CGPoint(x: 0, y: 0.5)
//        )
    }
    
    @IBAction func UpcomingAct(_ sender: Any) {
       // gradientcolours(button: UpcomingBtn, colours: [Colornames.gradientgreen.cgColor,Colornames.gradientBlue.cgColor])
        configureButton(UpcomingBtn, gradientColors: [UIColor.blue,UIColor.green],opacity: 0.8,lightenFactor: 0.6)
        UpcomingBtn.tintColor = .black
        CompletedBtn.tintColor = .lightGray
        
        gradientcolours(button: CompletedBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        
        IncorrectAnswerLbl.isHidden = true
        CorrectAnswerLbl.isHidden = true
        id = 0
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
    
    
    @IBAction func CompletedAct(_ sender: Any) {
        
        //gradientcolours(button: CompletedBtn, colours: [Colornames.gradientgreen.cgColor,Colornames.gradientBlue.cgColor])
        configureButton(CompletedBtn, gradientColors: [UIColor.blue,UIColor.green],opacity: 0.8,lightenFactor: 0.6)
        UpcomingBtn.tintColor = .lightGray
        CompletedBtn.tintColor = .black
        
        gradientcolours(button: UpcomingBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        
        IncorrectAnswerLbl.isHidden = false
        CorrectAnswerLbl.isHidden = false
        id = 1
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
    
    @available(iOS 14.0, *)
    @IBAction func BackAct(_ sender: Any) {
//        let vc = HomePageVc(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        dismiss(animated: true)
    }
}

extension QuizVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if id == 1 {
            return questions.count
        }else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if id == 1 {
//            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.CompletedTVcell, for: indexPath) as! CompletedTVcell
//            
//            cell.QuestionLbl.text = questions[indexPath.row].text
//            for (i, button) in cell.buttons.enumerated() {
//                // Use `i` for the index and `button` for the element
//                button.setTitle(questions[indexPath.row].options[i], for: .normal)
//            }
//            if selectedOption[indexPath.row] != questions[indexPath.row].correctOptionIndex{
//                cell.buttons[selectedOption[indexPath.row]].backgroundColor = .systemRed
//            }
//            cell.buttons[questions[indexPath.row].correctOptionIndex].backgroundColor = .systemGreen
//
////            let button = cell.buttons[correctoption[indexPath.row]]
////            button.backgroundColor = .systemGreen
////            if selectedOption[indexPath.row] != correctoption[indexPath.row]{
////                let button2 = cell.buttons[selectedOption[indexPath.row]]
////                button2.backgroundColor = .systemRed
////            }
//            return cell
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.CompletedTVcell, for: indexPath) as! CompletedTVcell

            // Set the question text
            cell.QuestionLbl.text = String(indexPath.row+1) + ". " + questions[indexPath.row].text

            // Reset button colors to a default state (e.g., .clear or another default color)
            for button in cell.buttons {
                button.backgroundColor = .clear
                button.setTitleColor(.systemBlue, for: .normal)
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.systemBlue.cgColor
            }

            // Configure the button titles
            for (i, button) in cell.buttons.enumerated() {
                button.setTitle(questions[indexPath.row].options[i], for: .normal)
            }

            // Highlight the selected and correct options
            if selectedOption[indexPath.row] != questions[indexPath.row].correctOptionIndex {
                cell.buttons[selectedOption[indexPath.row]].backgroundColor = .systemRed // Incorrect selection
                cell.buttons[selectedOption[indexPath.row]].setTitleColor(.white, for: .normal)
                cell.buttons[selectedOption[indexPath.row]].layer.borderColor = UIColor.systemRed.cgColor
            }
            cell.buttons[questions[indexPath.row].correctOptionIndex].backgroundColor = .systemGreen // Correct answer
            cell.buttons[questions[indexPath.row].correctOptionIndex].setTitleColor(.white, for: .normal)
            cell.buttons[questions[indexPath.row].correctOptionIndex].layer.borderColor = UIColor.systemGreen.cgColor
            return cell

        }else{
//            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.QuizTVcell, for: indexPath) as! QuizTVcell
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.QuizListTvCell, for: indexPath) as! QuizListTvCell
            let colour = colours[indexPath.row % colours.count]
            let colour2 = UIColor(named:colour)?.adjustedColor(brightnessFactor: 1.7, saturationFactor: 0.4)
            cell.CellView.backgroundColor = colour2
            let tap = UITapGestureRecognizer(target: self, action: #selector(StartQuiz))
            //cell.StartBtn.addGestureRecognizer(tap)
            cell.PlayBtn.addGestureRecognizer(tap)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func StartQuiz(){
        
        let vc = PlayQuizVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
