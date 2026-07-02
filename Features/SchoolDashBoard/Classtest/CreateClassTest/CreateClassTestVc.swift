//
//  CreateClassTestVc.swift
//  School Chimes
//
//  Created by apple on 23/06/26.
//

import UIKit

class CreateClassTestVc: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet public weak var headerBackgroundView: UIView!
    @IBOutlet weak var BackDismissImg: UIImageView!
    @IBOutlet weak var maincardView: UIView!
    @IBOutlet public weak var stepProgressLabel: UILabel!
    @IBOutlet public weak var stepTitleLabel: UILabel!
    @IBOutlet public weak var stepSubtitleLabel: UILabel!
    
    @IBOutlet public weak var childContainerView: UIView!
    @IBOutlet public weak var backButton: UIButton!
    @IBOutlet public weak var continueButton: UIButton!
    
    @IBOutlet weak var acadmicYrBtnName: UIButton!
    // Stepper node outlets
    @IBOutlet public weak var step1Circle: UIView!
    @IBOutlet public weak var step1Label: UILabel!
    @IBOutlet public weak var step1Title: UILabel!
    
    @IBOutlet public weak var step2Circle: UIView!
    @IBOutlet public weak var step2Label: UILabel!
    @IBOutlet public weak var step2Title: UILabel!
    
    @IBOutlet public weak var step3Circle: UIView!
    @IBOutlet public weak var step3Label: UILabel!
    @IBOutlet public weak var step3Title: UILabel!
    
    @IBOutlet public weak var step4Circle: UIView!
    @IBOutlet public weak var step4Label: UILabel!
    @IBOutlet public weak var step4Title: UILabel!
    
    @IBOutlet public weak var step5Circle: UIView!
    @IBOutlet public weak var step5Label: UILabel!
    @IBOutlet public weak var step5Title: UILabel!
    
    // Stepper connecting lines
    @IBOutlet public weak var line1To2: UIView!
    @IBOutlet public weak var line2To3: UIView!
    @IBOutlet public weak var line3To4: UIView!
    @IBOutlet public weak var line4To5: UIView!
    @IBOutlet weak var viewHistoryBtn: UIButton!
    
    private let acidamicdrops = DropDown()
    private var accadimYr: [String] = []
    private var academicId = 0
    var AcadimicYears: [AcadimicYearData] = []
    // MARK: - Properties
    private let viewModel = CreateTestViewModel()
    private var activeViewController: UIViewController?
    
    private var alert = CustomAlert()
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
//        viewModel.getStandardsAPI(academic_year_id: academicId)
        getacadmicYr()
    }
    
    func getacadmicYr() {
        DispatchQueue.main.async{ [weak self] in
            self?.AcadimicYears = localData.accidamic_year_data?.data ?? []
            let currentYear = self?.AcadimicYears.first(where: { $0.current_academic_year == true })
            self?.academicId = currentYear?.id ?? 0
            
            var config = UIButton.Configuration.plain()

            var attributedTitle = AttributedString(currentYear?.year ?? "")
            attributedTitle.font = UIFont.systemFont(ofSize: 12, weight: .semibold)

            config.attributedTitle = attributedTitle
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
            config.image = UIImage(systemName: "arrowtriangle.down.fill")?
                .applyingSymbolConfiguration(symbolConfig)

            config.imagePlacement = .trailing
            config.imagePadding = 8

            self?.acadmicYrBtnName.configuration = config
            
            self?.acadmicYrBtnName.contentHorizontalAlignment = .fill
            self?.acadmicYrBtnName.tintColor = .white
            self?.viewModel.getStandardsAPI(academic_year_id: self?.academicId ?? 0)
        }
    }

    private func setupUI() {
        // Rounded bottom corners of header background view
        headerBackgroundView.clipsToBounds = true
//        headerBackgroundView.layer.cornerRadius = 24
        headerBackgroundView.clipsToBounds = true
        maincardView.layer.cornerRadius = 20
        headerBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
//        acadmicYrBtnName.layer.cornerRadius = 
        acadmicYrBtnName.layer.borderWidth = 1.0
        acadmicYrBtnName.layer.borderColor = UIColor.white.cgColor
        
        // Circular steps helper
        configureCircle(step1Circle)
        configureCircle(step2Circle)
        configureCircle(step3Circle)
        configureCircle(step4Circle)
        configureCircle(step5Circle)
        
        // Customize action buttons
        backButton.layer.cornerRadius = 16
        backButton.layer.borderWidth = 1.0
        backButton.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor
        continueButton.layer.cornerRadius = 16
        childContainerView.layer.cornerRadius = 16 
        // Dynamic types
        stepProgressLabel.adjustsFontForContentSizeCategory = true
        stepTitleLabel.adjustsFontForContentSizeCategory = true
        stepSubtitleLabel.adjustsFontForContentSizeCategory = true
        
        let backDis = UITapGestureRecognizer(target: self, action: #selector(backDismiss))
        BackDismissImg.addGestureRecognizer(backDis)
    }
    
    @objc func backDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    private func configureCircle(_ view: UIView) {
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1.5
        view.layer.masksToBounds = true
    }
    
    private func bindViewModel() {
        viewModel.onDataLoaded = { [weak self] in
            self?.updateStepView(for: self?.viewModel.currentStep ?? 1)
        }
        
        viewModel.onStepChanged = { [weak self] step in
            self?.updateStepView(for: step)
        }
        
        viewModel.onSelectionChanged = { [weak self] in
            // Refresh title / states depending on select bounds
            self?.updateButtons()
        }
    }
    
    private func updateStepView(for step: Int) {
        // 1. Update text content
        stepProgressLabel.text = "Step \(step) of 5"
        
        switch step {
        case 1:
            stepTitleLabel.text = "Select Standard"
            stepSubtitleLabel.text = "Choose the class for which you want to create a test"
            backButton.isHidden = true
            continueButton.isHidden = false
            
            let vc = SelectStandardViewController(nibName: "SelectStandardViewController", bundle: nil)
            vc.viewModel = viewModel
            transition(to: vc)
            
        case 2:
            stepTitleLabel.text = "Select Sections"
            stepSubtitleLabel.text = "Standard \(viewModel.selectedStandard?.name ?? "") — select one or more"
            backButton.isHidden = false
            continueButton.isHidden = false
            
            let vc = SelectSectionsViewController(nibName: "SelectSectionsViewController", bundle: nil)
            vc.viewModel = viewModel
            transition(to: vc)
            
        case 3:
            stepTitleLabel.text = "Create Class Test"
            stepSubtitleLabel.text = "Choose subjects to include in the test"
            backButton.isHidden = false
            continueButton.isHidden = false
            
            let vc = SelectSubjectVc(nibName: "SelectSubjectVc", bundle: nil)
            vc.viewModel = viewModel
            transition(to: vc)
            
        case 4:
            stepTitleLabel.text = "Create Class Test"
            stepSubtitleLabel.text = "Configure each exam"
            backButton.isHidden = false
            continueButton.isHidden = false
            
            let vc = SelectDetailsViewController(nibName: "SelectDetailsViewController", bundle: nil)
            vc.viewModel = viewModel
            transition(to: vc)
            
        case 5:
            stepTitleLabel.text = "Create Class Test"
            stepSubtitleLabel.text = "Almost done — confirm your entries"
            
            
//            if viewModel.exameName == "" {
//                backButton.isHidden = false
//                continueButton.isHidden = false
//                alert.showAlert(title: "", message: "Exame Name is required", on: self)
//            }else{
                backButton.isHidden = true
                continueButton.isHidden = true
                let vc = SelectReviewViewController(nibName: "SelectReviewViewController", bundle: nil)
                vc.viewModel = viewModel
                
                transition(to: vc)
//            }
        default:
            return
        }
        
        // Update steps indicator UI
        updateStepperIndicators(currentStep: step)
        updateButtons()
    }
    
    private func updateStepperIndicators(currentStep: Int) {
        let activeColor =  UIColor.primery/*UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)*/ // #4C4DDC
        let inactiveBorderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0) // #E2E8F0
        let inactiveTextColor = UIColor(red: 0.392, green: 0.455, blue: 0.545, alpha: 1.0) // #64748B
        
        let steps = [
            (step1Circle, step1Label, step1Title),
            (step2Circle, step2Label, step2Title),
            (step3Circle, step3Label, step3Title),
            (step4Circle, step4Label, step4Title),
            (step5Circle, step5Label, step5Title)
        ]
        
        let lines = [line1To2, line2To3, line3To4, line4To5]
        
        for (idx, stepViews) in steps.enumerated() {
            let stepNum = idx + 1
            let circle = stepViews.0!
            let label = stepViews.1!
            let title = stepViews.2!
            
            if stepNum < currentStep {
                // Completed State
                circle.backgroundColor = activeColor
                circle.layer.borderColor = activeColor.cgColor
                label.text = "✓"
                label.textColor = .white
                title.textColor = activeColor
            } else if stepNum == currentStep {
                // Active State
                circle.backgroundColor = .white
                circle.layer.borderColor = activeColor.cgColor
                circle.layer.borderWidth = 2.0
                label.text = "\(stepNum)"
                label.textColor = activeColor
                title.textColor = activeColor
            } else {
                // Inactive State
                circle.backgroundColor = .white
                circle.layer.borderColor = inactiveBorderColor.cgColor
                circle.layer.borderWidth = 1.0
                label.text = "\(stepNum)"
                label.textColor = inactiveTextColor
                title.textColor = inactiveTextColor
            }
        }
        
        // Connect lines logic
        for (idx, line) in lines.enumerated() {
            let lineStep = idx + 1
            if lineStep < currentStep {
                line?.backgroundColor = activeColor
            } else {
                line?.backgroundColor = inactiveBorderColor
            }
        }
    }
    
    private func updateButtons() {
        let activeColor =  UIColor.primery/*UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)*/
        let disabledColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 0.5)
        
        if viewModel.currentStep == 1 {
            acadmicYrBtnName.isHidden = false
            stepProgressLabel.isHidden = true
            let canContinue = viewModel.selectedStandard != nil
            continueButton.isEnabled = canContinue
            continueButton.backgroundColor = canContinue ? activeColor : disabledColor
        } else if viewModel.currentStep == 2 {
            acadmicYrBtnName.isHidden = true
            stepProgressLabel.isHidden = false
            let canContinue = !viewModel.selectedSections.isEmpty
            continueButton.isEnabled = canContinue
            continueButton.backgroundColor = canContinue ? activeColor : disabledColor
        } else if viewModel.currentStep == 3 {
            let canContinue = !viewModel.selectedSubjects.isEmpty
            continueButton.isEnabled = canContinue
            continueButton.backgroundColor = canContinue ? activeColor : disabledColor
        } else if viewModel.currentStep == 4 {
            let canContinue = !viewModel.examConfigurations.isEmpty && viewModel.examConfigurations.allSatisfy { viewModel.isSubjectConfigured(subjectId: $0.subjectId, sectionId: $0.sectionId) }
            continueButton.isEnabled = canContinue
            continueButton.backgroundColor = canContinue ? activeColor : disabledColor
        }else if viewModel.currentStep == 5 {
                backButton.isHidden = true
                continueButton.isHidden = true
        }
    }
    
    private func transition(to child: UIViewController) {
        if let active = activeViewController {
            active.willMove(toParent: nil)
            active.view.removeFromSuperview()
            active.removeFromParent()
        }
        
        addChild(child)
        child.view.frame = childContainerView.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childContainerView.addSubview(child.view)
        child.didMove(toParent: self)
        
        activeViewController = child
    }
    
    
    @IBAction func accidmicYrBtnAct(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.accadimYr = self?.AcadimicYears.compactMap { $0.year } ?? []
            self?.acidamicdrops.anchorView = self?.acadmicYrBtnName
            self?.acidamicdrops.dataSource = self?.accadimYr ?? []
            self?.acidamicdrops.bottomOffset = CGPoint(x: 0, y: self?.acadmicYrBtnName.bounds.height ?? 0.0)
            self?.acidamicdrops.show()
            
            self?.acidamicdrops.selectionAction = { [self] (index: Int, item: String) in
                
                var config = UIButton.Configuration.plain()

                var attributedTitle = AttributedString(item)
                attributedTitle.font = UIFont.systemFont(ofSize: 12, weight: .semibold)

                config.attributedTitle = attributedTitle
                config.image = UIImage(systemName: "arrowtriangle.down.fill")
                config.imagePlacement = .trailing
                config.imagePadding = 8

                self?.acadmicYrBtnName.configuration = config
                
                    self?.acadmicYrBtnName.contentHorizontalAlignment = .fill
                self?.acadmicYrBtnName.tintColor = .white
                self?.academicId = self?.AcadimicYears[index].id ?? 0
                
                self?.viewModel.getStandardsAPI(academic_year_id: self?.academicId ?? 0)
                
            }
        }
    }
    // MARK: - IBActions
    @IBAction public func backButtonTapped(_ sender: UIButton) {
        _ = viewModel.previousStep()
    }
    
    @IBAction public func continueButtonTapped(_ sender: UIButton) {
        _ = viewModel.nextStep()
    }
    
    @IBAction func viewHistoryAct(_ sender: Any) {
        
        let vc = ExamRecordsVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}
