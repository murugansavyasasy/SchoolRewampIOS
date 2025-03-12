//
//  PlayQuizVc.swift
//  VsSchoolChimes
//
//  Created by Admin on 17/01/25.
//

import UIKit

class PlayQuizVc: UIViewController {
    
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
    @IBOutlet weak var PreviousImgView: UIImageView!
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
    
    var questions: [Question] = [
        Question(text: "What is the capital of Germany?", options: ["Berlin", "Munich", "Frankfurt", "Hamburg"], correctOptionIndex: 0),
        Question(text: "What is the square root of 64?", options: ["6", "7", "8", "9"], correctOptionIndex: 2),
        Question(text: "Which planet is the largest in the Solar System?", options: ["Earth", "Mars", "Jupiter", "Saturn"], correctOptionIndex: 2),
        Question(text: "Who wrote 'Romeo and Juliet'?", options: ["Charles Dickens", "Mark Twain", "William Shakespeare", "Jane Austen"], correctOptionIndex: 2),
        Question(text: "Which is the smallest prime number?", options: ["0", "1", "2", "3"], correctOptionIndex: 2),
        Question(text: "What is the chemical symbol for water?", options: ["H2O", "CO2", "NaCl", "O2"], correctOptionIndex: 0),
        Question(text: "Which country is known as the Land of the Rising Sun?", options: ["India", "China", "Japan", "Thailand"], correctOptionIndex: 2),
        Question(text: "What is the fastest land animal?", options: ["Cheetah", "Lion", "Horse", "Leopard"], correctOptionIndex: 0),
        Question(text: "Which ocean is the largest by area?", options: ["Atlantic", "Indian", "Arctic", "Pacific"], correctOptionIndex: 3),
        Question(text: "Who discovered penicillin?", options: ["Marie Curie", "Alexander Fleming", "Isaac Newton", "Louis Pasteur"], correctOptionIndex: 1)
    ]
    
    var currentQuestionIndex = 0
    var buttons: [UIButton] = []
    var selectedOptionIndex: Int? = nil
    var selectedOptions: [Int?] = []
    let gifImages = UIImage.gifImageWithName("Successful")
    var correctOption: [Int] = []
    var correctAnswers = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CompletedView.isHidden = true
        
        buttons = [Button1,Button2,Button3,Button4]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(previousQuesAct))
        PreviousImgView.addGestureRecognizer(tap)
        PreviousImgView.isUserInteractionEnabled = true
        
        applyCustomFontToButtons()
        selectedOptions = Array(repeating: nil, count: questions.count)
        loadQuestion()
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
        QuestionCountLbl.setFont(style: .title, size: FontSize.TitleSize)
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
        let currentQuestion = questions[currentQuestionIndex]
        QuestionLbl.text = currentQuestion.text
        
        for (index, button) in buttons.enumerated() {
            button.setTitle(currentQuestion.options[index], for: .normal)
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
        progressBar.progress = Float(currentQuestionIndex + 1) / Float(questions.count)
        QuestionCountLbl.text = "\(currentQuestionIndex + 1) / \(questions.count)"
    }
    
    @IBAction func NextAct(_ sender: Any) {
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            loadQuestion()
            PreviousBtn.backgroundColor = .systemIndigo
            if currentQuestionIndex == questions.count - 1 {
                NextBtn.backgroundColor = .systemGreen
                NextBtn.setTitle("Submit", for: .normal)
            }
            
        } else if currentQuestionIndex == questions.count - 1 {
            
            // Calculate the score and show the result after the last question
            var score = 0
            
            for (index, question) in questions.enumerated() {
                if selectedOptions[index] == question.correctOptionIndex {
                    score += 1 // Increment score for correct answers
                }
            }
            
            CompCorrectAnsCountLbl.text = String (score)
            CompInccorectCountLbl.text = String (questions.count - score)
            CompTotalmarkLbl.text = " \(score) out of \(questions.count)"
            CompletedView.isHidden = false
            correctAnswers = String (score)
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
        print("sender.tag", sender.tag)
        for i in selectedOptions {
            print("SelectedOptions", i)
        }
        
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
        for question in questions {
            correctOption.append(question.correctOptionIndex)
        }
        
        let vc = QuizVC(nibName: nil, bundle: nil)
        vc.correctoption = correctOption
        vc.questions = questions
        for i in selectedOptions {
            vc.selectedOption.append(i ?? 0)
        }
        vc.correctAnswers = correctAnswers
        //vc.selectedOption = selectedOptions
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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

struct Question {
    let text: String
    let options: [String]
    let correctOptionIndex: Int
}
