//
//  PlayQuizVc.swift
//  VsSchoolChimes
//
//  Created by Admin on 17/01/25.
//

import UIKit

class PlayQuizVc: UIViewController {
    
    @IBOutlet weak var progressQuizStac: UIStackView!
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var noRecordStack: UIStackView!
    @IBOutlet weak var noImagefoundImg: UIImageView!
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var pageControls: UIPageControl!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var PreviousBtn: UIButton!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var BaseView: UIView!
    @IBOutlet weak var ButtonStackview: UIStackView!
    @IBOutlet weak var QuestionLbl: UILabel!
    @IBOutlet weak var QuestionView: UIView!
    @IBOutlet weak var QuestionCountLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button4: UIButton!
    @IBOutlet weak var NextBtn: UIButton!
    
    var answeredOptions: [String: Int] = [:]
    var currentQuestionIndex = 0
    var buttons: [UIButton] = []
    var selectedOptionIndex: Int? = nil
    var selectedOptions: [Int?] = []
    var correctOption: [Int] = []
    var correctAnswers = ""
    var getQuestiondataDetails : [QuizQuestionDataDetails] = []
    var getQuestiondata : [QuizQuestionData] = []
    var filePath: [FilePath]?
    var childDetails = UserDefaultFileManager.get_child_Details()
    var selectedQuizId : String?
    var alert = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()
        Get_QuizQuestion()
        fullView.layer.cornerRadius = 10
        buttons = [Button1,Button2,Button3,Button4]
        cv.register(UINib(nibName: CellConfingName.MsgVoiceCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.MsgVoiceCvCell)
        
        applyCustomFontToButtons()
        
        let name = childDetails?.name ?? ""
        let stadard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        backBtn.configureAsBackButton(firstLine: name, secondLine: stadard)
        NameLbl.text = MenuStringFile.selectedMenuName
        StyleAndTranslate()
    }
    
    //To Set Font to the Option Buttons
    func applyCustomFontToButtons() {
        guard let customFont = UIFont(name: "Poppins-Medium", size: 14) else {
            print("Error: Custom font not found")
            return
        }
        for button in buttons {
            button.titleLabel?.font = customFont
            button.setTitleColor(.black, for: .normal)
            // Explicitly set the font for all states
            for state: UIControl.State in [.normal, .highlighted, .selected, .disabled] {
                let title = button.title(for: state) ?? "" // Fallback to empty string if nil
                button.setAttributedTitle(
                    NSAttributedString(
                        string: title,
                        attributes: [.font: customFont]
                    ),
                    for: state
                )
            }
        }
    }
    
    
    func Get_QuizQuestion() {
        APIService.shared
            .makeApi(url: ServiceUrl.quiz_get_questions, parameters: [QuizKeys.id : selectedQuizId ?? "" ], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") { [weak self] (
                result: Result<QuizQuestionSuc,
                Error>
            ) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let successResponse):
                        if successResponse.status == true{
                            self.getQuestiondata = successResponse.data ?? []
                            
                            self.getQuestiondataDetails = successResponse.data?.first?.question_details ?? []
                            self.selectedOptions = Array(
                                repeating: nil,
                                count: self.getQuestiondataDetails.count
                            )
                            self.progressQuizStac.isHidden = false
                            self.contentStack.isHidden = false
                            self.noRecordStack.isHidden = true
                            self.loadQuestion()
                            self.setDefaultProgressState()
                        }else{
                            self.progressQuizStac.isHidden = true
                            self.contentStack.isHidden = true
                            self.noRecordStack.isHidden = false
                            self.noDataFoundLbl.text = successResponse.message ?? ""
                        }
                        
                    case .failure(let error):
                        print("Error fetching notices: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    func StyleAndTranslate() {
        //MARK: UI Changes
        NextBtn.layer.cornerRadius = 10
        PreviousBtn.layer.cornerRadius = 10
        PreviousBtn.backgroundColor = .lightGray
        QuestionView.layer.cornerRadius = 10
        Button1.layer.cornerRadius = 15
        Button2.layer.cornerRadius = 15
        Button3.layer.cornerRadius = 15
        Button4.layer.cornerRadius = 15
        //MARK: Font Style
        QuestionLbl.setFont(style: .title, size: FontSize.TitleSize)
        NextBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        PreviousBtn.setTitleFont(style: .body, size: FontSize.BodySize)
    }
    
    func loadQuestion() {
        let currentQuestion = getQuestiondataDetails[currentQuestionIndex]
        let currentNo = "\(currentQuestionIndex + 1)"
        QuestionLbl.text = currentNo + ") " + (currentQuestion.question ?? "")
        filePath = currentQuestion.file_path
        cv.isHidden = currentQuestion.file_path?.count == 0
        pageControls.isHidden = currentQuestion.file_path?.count == 1 || currentQuestion.file_path?.count == 0
        pageControls.numberOfPages = currentQuestion.file_path?.count ?? 0
        pageControls.currentPage = 0
        
        cv.delegate = self
        cv.dataSource = self
        cv.reloadData()
        
        let questionId = currentQuestion.id ?? ""
        // If no answer saved yet, save default (0)
        if answeredOptions[questionId] == nil {
            answeredOptions[questionId] = 0
        }
        for (index, button) in buttons.enumerated() {
            button.setTitle(currentQuestion.options?[index], for: .normal)
            button.tag = index // Set button tag to match option index
            resetButtonStyle(button)
            // Highlight the previously selected option, if any
            if let selectedOption = selectedOptions[currentQuestionIndex], selectedOption == index {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
                button.tintColor = .white
            }
        }
        
        applyCustomFontToButtons()
        
        let current = "\(currentQuestionIndex + 1)"
        let total = "\(getQuestiondataDetails.count)"
        let fullText = "\(current) / \(total)"
        let attributedString = NSMutableAttributedString(string: fullText)
        // current number range
        if let range = fullText.range(of: current) {
            let nsRange = NSRange(range, in: fullText)
            attributedString
                .addAttribute(
                    .foregroundColor,
                    value: UIColor.primery,
                    range: nsRange)}
    }
    
    @IBAction func NextAct(_ sender: Any) {
        if currentQuestionIndex < getQuestiondataDetails.count - 1 {
            currentQuestionIndex += 1
            loadQuestion()
            PreviousBtn.backgroundColor = .systemIndigo
            if currentQuestionIndex == getQuestiondataDetails.count - 1 {
                NextBtn.backgroundColor = .systemGreen
                NextBtn.setTitle(AlertstringFile.Submit, for: .normal)
            }
            
        } else if currentQuestionIndex == getQuestiondataDetails.count - 1 {
            let zeroCount = answeredOptions.values.filter { $0 == 0 }.count
            if zeroCount > 0 {
                showAlert(message: " Are you sure you want to submit the quiz? because you not answered \(zeroCount) questions!")
            } else {
                showAlert(message: AlertstringFile.Are_you_sure_want_to_submit)
            }
        }
    }
    
    func updateProgressUI() {
        let total = getQuestiondataDetails.count
        let answeredCount = answeredOptions.values.filter { $0 != 0 }.count
        // Progress bar update
        progressBar.progress = Float(answeredCount) / Float(total)
        // Question count label update
        let current = "\(answeredCount)"
        let fullText = "\(answeredCount) / \(total)"
        let attributed = NSMutableAttributedString(string: fullText)
        if let range = fullText.range(of: current) {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttribute(.foregroundColor,
                                    value: UIColor.primery,
                                    range: nsRange)}
        QuestionCountLbl.attributedText = attributed
    }
    
    func setDefaultProgressState() {
        let answeredCount = 0
        let total = getQuestiondataDetails.count
        // Set progress bar to zero
        progressBar.progress = 0.0
        
        let current = "\(answeredCount)"
        let totalText = "\(total)"
        let fullText = "\(current) / \(totalText)"
        let attributedString = NSMutableAttributedString(string: fullText)
        // Highlight the 0 in primery color
        if let range = fullText.range(of: current) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.primery,
                range: nsRange
            )
        }
        QuestionCountLbl.attributedText = attributedString
    }
    
    func showAlert(message: String) {
        alert.showAlertCancel(
            title:  AlertstringFile.Alert_title,
            message:  message ,
            actionLbl1: AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { [weak self] in
                self?.submitQuiz()
            },
            onNo: {
                print("User canceled.")
            }
        )
    }
    
    
    func submitQuiz() {
        APIService.shared
            .makeApi(url: ServiceUrl.quiz_submit, parameters: [QuizKeys.id : selectedQuizId ?? "","answers" : answeredOptions ], type: ApitTypeSringFile.POST, token: childDetails?.access_token ?? "") { [weak self] (
                result: Result<CommonApiSuc,
                Error>
            ) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let successResponse):
                        if successResponse.status == true {
                            
                        }else{
                            
                            
                        }
                    case .failure(let error):
                        print("Error fetching notices: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    @IBAction func previousQuesAct(){
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            NextBtn.setTitle(CommonStringFile.NEXT, for: .normal)
            NextBtn.backgroundColor = .systemIndigo
            loadQuestion()
        }
        if currentQuestionIndex != 0{
            PreviousBtn.backgroundColor = .systemIndigo
        }else{
            PreviousBtn.backgroundColor = .lightGray
        }
    }
    
    // In optionSelected(_:) update logic
    @IBAction func optionSelected(_ sender: UIButton) {
        let currentIndex = currentQuestionIndex
        // If user taps the same selected option → deselect it
        if selectedOptions[currentIndex] == sender.tag {
            // Remove selection
            selectedOptions[currentIndex] = nil
            let currentQuestion = getQuestiondataDetails[currentIndex]
            let questionId = currentQuestion.id ?? ""
            answeredOptions[questionId] = 0
            // Reset styles for all buttons
            for button in buttons {
                resetButtonStyle(button)
            }
            updateProgressUI()
            return
        }
        // Normal selection
        selectedOptions[currentIndex] = sender.tag
        let currentQuestion = getQuestiondataDetails[currentIndex]
        let questionId = currentQuestion.id ?? ""
        answeredOptions[questionId] = sender.tag + 1
        // Reset all styles
        for button in buttons {
            resetButtonStyle(button)
        }
        // Highlight selected button
        sender.backgroundColor = .systemBlue
        sender.tintColor = .white
        sender.setTitleColor(.white, for: .normal)
        
        updateProgressUI()
    }
    
    
    
    func resetButtonStyle(_ button: UIButton) {
        button.backgroundColor = .clear
        button.setTitleColor(.systemBlue, for: .normal)
        button.tintColor = .systemBlue
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func ContinueAct(_ sender: Any) {
        var correctOption: [Int] = []
        for question in getQuestiondataDetails {
            correctOption.append(question.correctOptionIndex ?? 0)
        }
    }
}


extension PlayQuizVc : UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filePath?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.MsgVoiceCvCell, for: indexPath) as? MsgVoiceCvCell else {
            return UICollectionViewCell()
        }
        if let url = URL(string: filePath?[indexPath.row].url ?? "") {
            let request = URLRequest(url: url)
            cell.webView.load(request)
        }
        
        let urlString = filePath?[indexPath.row].url ?? ""
        if let url = URL(string: urlString) {
            let ext = url.pathExtension.lowercased()
            if ["png", "jpg", "jpeg", "webp"].contains(ext) {
                let imageUrl = urlString
                let htmlString = """
                <html>
                <head>
                <style>
                body { margin:0; padding:0; background:#000; }
                img { max-width:100%; height:auto; display:block; margin:auto; }
                </style>
                </head>
                <body>
                <img src="\(imageUrl)">
                </body>
                </html>
                """
                cell.webView.isUserInteractionEnabled = false
                cell.webView.loadHTMLString(htmlString, baseURL: nil)
            } else {
                cell.webView.isUserInteractionEnabled = true
                cell.webView
                    .load(
                        URLRequest(
                            url: URL(string:filePath?[indexPath.row].url ?? "")!
                        )
                    )
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.layer.frame.width, height: 180)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControls.currentPage = Int(pageIndex)
    }
}

struct Question {
    let text: String
    let options: [String]
    let correctOptionIndex: Int
}
