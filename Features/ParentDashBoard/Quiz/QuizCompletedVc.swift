import UIKit

class QuizCompletedVc: UIViewController {

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var menuNameLbl: UILabel!

    var get_QuizDetails: [myQuizDetails] = []
    var quiz_details: [MyQuizDetails]?
    var selected_QuizId: String?
    var childDetails = UserDefaultFileManager.get_child_Details()

    var correct_ans = ""
    var worng_ans = ""
    var not_ans = ""
    var subjet_name = ""
    var completed_date = ""
    var message = ""
    var selected_StudentId: String = ""
    var Selected_StudentName : String?
    var Selected_Sections: String?
    var Selected_Standards : String?
    var Token : String? // this token passed  from  QuizSubmissionVc  and also used in same page  childDetails?.access_token ??   because   this view contoller use both staff and student
    override func viewDidLoad() {
        super.viewDidLoad()

        if selected_StudentId == ""{
            let name = childDetails?.name ?? ""
            let standard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
            backBtn.configureAsBackButton(firstLine: name, secondLine: standard)
            Token = childDetails?.access_token ?? ""
        }else{
            let name = Selected_StudentName ?? ""
            let standard = (Selected_Standards ?? "") + " - " + (Selected_Sections ?? "")
            backBtn.configureAsBackButton(firstLine: name, secondLine: standard)
        }
       

        menuNameLbl.text = MenuStringFile.selectedMenuName + " Submission"

        tv.register(UINib(nibName: CellConfingName.QuizCompletedFirstTv, bundle: nil),
                    forCellReuseIdentifier: CellConfingName.QuizCompletedFirstTv)
        tv.register(UINib(nibName: "QuestionTVC", bundle: nil),
                    forCellReuseIdentifier: "QuestionTVC")
        tv.register(UINib(nibName: "OptionTVC", bundle: nil),
                    forCellReuseIdentifier: "OptionTVC")
        tv.register(UINib(nibName: "NodataTVC", bundle: nil),
                    forCellReuseIdentifier: "NodataTVC")

        tv.delegate = self
        tv.dataSource = self

        mySubmission()
    }

    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - TableView Delegate & DataSource
extension QuizCompletedVc: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let question = quiz_details else { return 1 }
        return quiz_details?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (quiz_details?[section].options?.count ?? 0)
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let question = quiz_details?[indexPath.section] else {
            return tableView.dequeueReusableCell(withIdentifier: "NodataTVC", for: indexPath)
        }

        // QUESTION CELL
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTVC",
                                                     for: indexPath) as! QuestionTVC
            cell.qstLbl.text = question.question
            let questionString = "Question".translated()
            let MarkString = "Mark".translated()
            cell.qstCountLbl.text = "\(questionString) \(indexPath.section + 1)"
            cell.markLbl.text = "\(MarkString) / \(question.mark ?? 0)"

            if let files = question.file_path, !files.isEmpty {
                cell.conficList(filePath: files)
                cell.imgView.isHidden = false
                cell.pageController.isHidden = false
                cell.pageController.numberOfPages = files.count
            } else {
                cell.imgView.isHidden = true
                cell.pageController.isHidden = true
            }
            return cell
        }

        // OPTION CELL
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionTVC",
                                                 for: indexPath) as! OptionTVC

        let optionIndex = indexPath.row - 1
        let option = question.options?[optionIndex]
        let chooseOption = optionLetter(for: optionIndex)

        let correctAnswer = question.correct_answer ?? ""
        let studentAnswer = question.student_answer ?? ""
        let optionText = option?.value ?? ""

        // DEFAULT (GRAY)
        cell.optionView.layer.borderColor = UIColor.systemGray4.cgColor
        cell.optionView.layer.borderWidth = 1
        cell.optionView.backgroundColor = .clear
        cell.optionBtn.setTitle(chooseOption, for: .normal)
        cell.optionBtn.setImage(nil, for: .normal)
        if studentAnswer == correctAnswer && optionText == studentAnswer {
            cell.optionBtn.setTitle("", for: .normal)
            cell.optionBtn.setImage(
                UIImage(systemName: "checkmark.circle.fill"),
                for: .normal
            )
            cell.optionView.layer.borderColor = UIColor.systemGreen.cgColor
            cell.optionView.layer.borderWidth = 2
            cell.optionView.backgroundColor =
                UIColor.systemGreen.withAlphaComponent(0.1)
            cell.optionBtn.tintColor = UIColor.systemGreen
        }else if studentAnswer != correctAnswer && optionText == correctAnswer {
            cell.optionBtn.setTitle("", for: .normal)
            cell.optionBtn.setImage(
                UIImage(systemName: "checkmark.circle.fill"),
                for: .normal
            )
            cell.optionView.layer.borderColor = UIColor.systemGreen.cgColor
            cell.optionView.layer.borderWidth = 2
            cell.optionView.backgroundColor =
                UIColor.systemGreen.withAlphaComponent(0.1)
            cell.optionBtn.tintColor = UIColor.systemGreen
        }
        else if studentAnswer != correctAnswer && optionText == studentAnswer {
            cell.optionView.layer.borderColor = UIColor.systemRed.cgColor
            cell.optionBtn.setTitle("", for: .normal)
            cell.optionBtn.tintColor = UIColor.systemRed
            cell.optionBtn.setImage(
                UIImage(systemName: "xmark.circle.fill"),
                for: .normal
            )
            cell.optionView.layer.borderWidth = 2
            cell.optionView.backgroundColor =
                UIColor.systemRed.withAlphaComponent(0.1)
            
        }

        if let imgStr = option?.image,
           let imgURL = URL(string: imgStr),
           !imgStr.isEmpty {
            cell.ansImg.isHidden = false
            cell.ansImg.kf.setImage(with: imgURL,
                                    placeholder: UIImage(named: "ImagePdf"))
        } else {
            cell.ansImg.isHidden = true
        }
        cell.ansLbl.text = option?.value
        return cell
    }

    // MARK: - HEADER (First section only)
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {

        guard section == 0 else { return nil }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.QuizCompletedFirstTv
        ) as! QuizCompletedFirstTv

        cell.subjectQuiz.text = subjet_name
        cell.completedAtLbl.text =
        "Completed at: ".translated() + formattedDateStatus(from: completed_date, isTimeNeeded: true)
        cell.wishesLbl.text = message

        let parts = correct_ans.split(separator: "/")
        if parts.count == 2,
           let correct = Double(parts[0]),
           let total = Double(parts[1]),
           total > 0 {
            cell.setProgress(to: (correct / total) * 100)
        } else {
            cell.setProgress(to: 0)
        }

        cell.crtBtn.setTitle("Correct Ans ".translated() + correct_ans, for: .normal)
        cell.wrongBtn.setTitle("Wrong Ans ".translated() + worng_ans, for: .normal)
        cell.notAnsBtn.setTitle("Not Ans ".translated() + not_ans, for: .normal)

        return cell.contentView
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? UITableView.automaticDimension : 0.01
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - API
extension QuizCompletedVc {

    func mySubmission() {
        APIService.shared
            .makeApi(url: ServiceUrl.my_submissions, parameters: [QuizKeys.id : selected_QuizId ?? "",QuizKeys.student_id : selected_StudentId ], type: ApitTypeSringFile.GET, token: Token ?? ""  , isBaseUrl: false) { [weak self] (
                result: Result<MyQuizSuc,
                Error>
            ) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let successResponse):
                        if successResponse.status == true{
                            self.correct_ans = successResponse.data?.first?.right_answer ?? ""
                            self.message = successResponse.data?.first?.message ?? ""
                            self.worng_ans = successResponse.data?.first?.wrong_answer ?? ""
                            self.not_ans = successResponse.data?.first?.un_answer ?? ""
                            self.get_QuizDetails = successResponse.data ?? []
                            self.quiz_details = successResponse.data?.first?.quiz_details ?? []
                            self.tv.reloadData()
                        }
                    case .failure(let error):
                        print("Error fetching notices: \(error.localizedDescription)")
                    }
                }
            }
    }
}
