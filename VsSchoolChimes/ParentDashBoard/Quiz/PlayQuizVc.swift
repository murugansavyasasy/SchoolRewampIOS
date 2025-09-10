//
//  PlayQuizVc.swift
//  VsSchoolChimes
//
//  Created by Admin on 17/01/25.
//

import UIKit

class PlayQuizVc: UIViewController {
    
    @IBOutlet weak var pageControls: UIPageControl!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var PreviousBtn: UIButton!
    @IBOutlet weak var sectionLbl: UILabel!
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
    @IBOutlet weak var CompletedView: UIView!
    @IBOutlet weak var ContinueBtn: UIButton!
    @IBOutlet weak var CompletedImg: UIImageView!
    @IBOutlet weak var CompletedLbl: UILabel!
    @IBOutlet weak var CompTotalQuestionDefLbl: UILabel!
    @IBOutlet weak var CompTotalQuestionNoLbl: UILabel!
    @IBOutlet weak var CompCorretAnsDefLbl: UILabel!
    @IBOutlet weak var CompCorrectAnsCountLbl: UILabel!
    @IBOutlet weak var CompInccorectCountLbl: UILabel!
    @IBOutlet weak var CompInCorretAnsDefLbl: UILabel!
    @IBOutlet weak var CompTotalMarkDefLbl: UILabel!
    @IBOutlet weak var CompTotalmarkLbl: UILabel!
    var answeredOptions: [String: Int] = [:]
    var currentQuestionIndex = 0
    var buttons: [UIButton] = []
    var selectedOptionIndex: Int? = nil
    var selectedOptions: [Int?] = []
    let gifImages = UIImage.gifImageWithName("Successful")
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
        CompletedView.isHidden = true
        fullView.layer.cornerRadius = 10
        buttons = [Button1,Button2,Button3,Button4]
        
        cv.register(UINib(nibName: "MsgVoiceCvCell", bundle: nil), forCellWithReuseIdentifier: "MsgVoiceCvCell")
      
        applyCustomFontToButtons()
       
//        if getQuestiondataDetails.count != 0 {
//            loadQuestion()
//        }
//        
        
        
        StyleAndTranslate()
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
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
            .makeApi(url: ServiceUrl.quiz_get_questions, parameters: ["id" : selectedQuizId ?? "" ], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") { [weak self] (
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
                        self.loadQuestion()
                    }else{
                        
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
        CompletedView.layer.cornerRadius = 10
        ContinueBtn.layer.cornerRadius = 10
        CompletedImg.image = gifImages
        Button1.layer.cornerRadius = 15
        Button2.layer.cornerRadius = 15
        Button3.layer.cornerRadius = 15
        Button4.layer.cornerRadius = 15
        
        //MARK: Font Style
        NameLbl.setFont(style: .body, size: 12)
        sectionLbl.setFont(style: .body, size: 12)
        backBtn.setTitleFont(style: .body, size: 20)
        NameLbl.setFont(style: .title, size: FontSize.TitleSize)
        sectionLbl.setFont(style: .title, size: FontSize.TitleSize)
        QuestionLbl.setFont(style: .title, size: FontSize.TitleSize)
//        QuestionCountLbl.setFont(style: .title, size: FontSize.TitleSize)
        NextBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        PreviousBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        CompletedLbl.setFont(style: .header, size: FontSize.HeaderSize)
        CompTotalmarkLbl.setFont(style: .title, size: FontSize.TitleSize)
        CompTotalMarkDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        CompTotalQuestionDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        CompTotalQuestionNoLbl.setFont(style: .title, size: FontSize.TitleSize)
        CompCorretAnsDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        CompCorrectAnsCountLbl.setFont(style: .title, size: FontSize.TitleSize)
        CompInCorretAnsDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        CompInccorectCountLbl.setFont(style: .title, size: FontSize.TitleSize)
        ContinueBtn.setTitleFont(style: .body, size: FontSize.BodySize)
    }
    
    func loadQuestion() {
        let currentQuestion = getQuestiondataDetails[currentQuestionIndex]
        
        QuestionLbl.text = currentQuestion.question
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
        
        // Apply the custom font to the buttons again when loading a new question
        applyCustomFontToButtons()
        
        // Update progress bar and question count
        progressBar.progress = Float(currentQuestionIndex + 1) / Float(getQuestiondataDetails.count)
//        QuestionCountLbl.text = "\(currentQuestionIndex + 1) / \(getQuestiondata.first?.total_questions ?? 0)"
        
        
        let current = "\(currentQuestionIndex + 1)"
        let total = "\(getQuestiondata.first?.total_questions ?? 0)"
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

        QuestionCountLbl.attributedText = attributedString

    }
    
    @IBAction func NextAct(_ sender: Any) {
        
//        print("NextActNextAct",answeredOptions)
        if currentQuestionIndex < getQuestiondataDetails.count - 1 {
            currentQuestionIndex += 1
            loadQuestion()
            PreviousBtn.backgroundColor = .systemIndigo
            if currentQuestionIndex == getQuestiondataDetails.count - 1 {
                NextBtn.backgroundColor = .systemGreen
                NextBtn.setTitle("Submit", for: .normal)
            }
            
        } else if currentQuestionIndex == getQuestiondataDetails.count - 1 {
            
            
            print("answeredOptionsansweredOptions",answeredOptions)
          
            
            let zeroCount = answeredOptions.values.filter { $0 == 0 }.count
            
           
            if zeroCount > 0 {
                print("Number of zeros: \(zeroCount)")
                showAlert(message: "Are you sure want to submit ?")
                
            } else {
                print("No zeros found")
                
                showAlert(message: " Are you sure you want to submit the quiz? because you not answered \(zeroCount) questions!")
            }
            
            

        }
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
            .makeApi(url: ServiceUrl.quiz_submit, parameters: ["id" : selectedQuizId ?? "","answers" : answeredOptions ], type: ApitTypeSringFile.POST, token: childDetails?.access_token ?? "") { [weak self] (
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
            NextBtn.setTitle("Next", for: .normal)
            NextBtn.backgroundColor = .systemIndigo
            loadQuestion()
        }
        if currentQuestionIndex != 0{
            PreviousBtn.backgroundColor = .systemIndigo
        }else{
            PreviousBtn.backgroundColor = .lightGray
        }
    }
    
    @IBAction func optionSelected(_ sender: UIButton) {
        
        // Update selected option for the current question
        selectedOptions[currentQuestionIndex] = sender.tag
//        print("sender.tag", sender.tag)
//        for i in selectedOptions {
//        print("SelectedOptions", i)
//        }
        
        let currentQuestion = getQuestiondataDetails[currentQuestionIndex]
           let questionId = currentQuestion.id ?? ""

           // Save the selected option index (button.tag)
           answeredOptions[questionId] = sender.tag + 1
        
        // Reset all button styles
        for button in buttons {
            resetButtonStyle(button)
        }
        
        // Highlight the selected button
        sender.backgroundColor = .systemBlue
        sender.tintColor = .white
        sender.setTitleColor(.white, for: .normal)
    }
    
    
    func resetButtonStyle(_ button: UIButton) {
        button.backgroundColor = .clear
        button.setTitleColor(.systemBlue, for: .normal)
        button.tintColor = .systemBlue
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        // button.setTitleFont(style: .body, size: FontSize.BodySize)
    }
    
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func ContinueAct(_ sender: Any) {
        var correctOption: [Int] = []
        for question in getQuestiondataDetails {
            correctOption.append(question.correctOptionIndex ?? 0)
        }
        
//        let vc = QuizVC(nibName: nil, bundle: nil)
//        vc.correctoption = correctOption
//        vc.questions = getQuestiondataDetails
//        for i in selectedOptions {
//            vc.selectedOption.append(i ?? 0)
//        }
//        vc.correctAnswers = correctAnswers
//        //vc.selectedOption = selectedOptions
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
    }
    
    //    var questions: [Question] = [
    //        Question(
    //            text: "In which year did the American Civil War begin, and what was its primary cause?",
    //            options: [
    //                "1860; Disputes over territorial expansion.",
    //                "1861; Issues related to slavery and states' rights.",
    //                "1865; Industrialization conflicts between the North and South.",
    //                "1862; Economic rivalry between different regions."
    //            ],
    //            correctOptionIndex: 1
    //        ),
    //        Question(
    //            text: "Who is considered the father of modern physics, and what groundbreaking theory did he develop in 1905?",
    //            options: [
    //                "Isaac Newton; Theory of Gravity.",
    //                "Albert Einstein; Theory of Special Relativity.",
    //                "Niels Bohr; Quantum Theory.",
    //                "Galileo Galilei; Heliocentric Theory."
    //            ],
    //            correctOptionIndex: 1
    //        ),
    //        Question(
    //            text: "What is the process called by which plants convert sunlight into energy, and what are its key components?",
    //            options: [
    //                "Osmosis; Water and cell walls.",
    //                "Respiration; Oxygen and carbon dioxide.",
    //                "Photosynthesis; Sunlight, water, and carbon dioxide.",
    //                "Fermentation; Sugars and bacteria."
    //            ],
    //            correctOptionIndex: 2
    //        ),
    //        Question(
    //            text: "What is the largest organ in the human body, and what are its primary functions?",
    //            options: [
    //                "The liver; Filtering toxins and aiding digestion.",
    //                "The skin; Protection, regulation, and sensation.",
    //                "The heart; Pumping blood throughout the body.",
    //                "The lungs; Facilitating oxygen exchange."
    //            ],
    //            correctOptionIndex: 1
    //        ),
    //        Question(
    //            text: "Which famous English writer is known for works like 'Hamlet,' 'Macbeth,' and 'Romeo and Juliet,' and in which era did he write?",
    //            options: [
    //                "Charles Dickens; Victorian Era.",
    //                "William Shakespeare; Elizabethan Era.",
    //                "Jane Austen; Regency Era.",
    //                "J.K. Rowling; Contemporary Era."
    //            ],
    //            correctOptionIndex: 1
    //        ),
    //        Question(
    //            text: "What is the phenomenon called when a species evolves over time due to natural selection, and who proposed this theory?",
    //            options: [
    //                "Adaptation; Gregor Mendel.",
    //                "Evolution; Charles Darwin.",
    //                "Mutation; James Watson.",
    //                "Speciation; Alfred Wallace."
    //            ],
    //            correctOptionIndex: 1
    //        ),
    //        Question(
    //            text: "Which global organization was established in 1945 to promote peace and security, and where is its headquarters located?",
    //            options: [
    //                "The United Nations; New York City, USA.",
    //                "The League of Nations; Geneva, Switzerland.",
    //                "NATO; Brussels, Belgium.",
    //                "The World Trade Organization; Paris, France."
    //            ],
    //            correctOptionIndex: 0
    //        ),
    //        Question(
    //            text: "What is the primary function of DNA in living organisms, and what is its structural shape?",
    //            options: [
    //                "To store genetic information; Double helix.",
    //                "To provide energy for cells; Spiral staircase.",
    //                "To protect cells from damage; Single strand.",
    //                "To synthesize proteins; Triple helix."
    //            ],
    //            correctOptionIndex: 0
    //        ),
    //        Question(
    //            text: "What is the Great Barrier Reef, where is it located, and why is it significant?",
    //            options: [
    //                "A mountain range; Australia; Known for its height and wildlife.",
    //                "A coral reef system; Australia; The world's largest and rich in biodiversity.",
    //                "A desert; Africa; Famous for its sand dunes and unique ecosystem.",
    //                "A rainforest; South America; Renowned for its dense canopy and species diversity."
    //            ],
    //            correctOptionIndex: 1
    //        ),
    //        Question(
    //            text: "What is the theory of plate tectonics, and what phenomena does it explain?",
    //            options: [
    //                "The idea that Earth's plates are static; It explains mountain formation.",
    //                "The hypothesis that Earth's crust moves due to tidal forces; It explains volcanic eruptions.",
    //                "The scientific theory that Earth's lithosphere is divided into moving plates; It explains earthquakes, volcanic activity, and continental drift.",
    //                "The belief that Earth's core drives all geological changes; It explains erosion and sedimentation."
    //            ],
    //            correctOptionIndex: 2
    //        )
    //    ]
    
    
}


extension PlayQuizVc : UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filePath?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MsgVoiceCvCell", for: indexPath) as? MsgVoiceCvCell else {
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
