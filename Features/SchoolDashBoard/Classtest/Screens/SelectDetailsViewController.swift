//
//  SelectDetailsViewController.swift
//  School Chimes
//
//  Created by apple on 25/06/26.
//

import UIKit

class SelectDetailsViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var exameNameDefaultLbl: UILabel!
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet weak var exameNameTextView: UITextView!
    @IBOutlet public weak var sectionsContainerView: UIView!
    @IBOutlet public weak var sectionsStackView: UIStackView!
    public var viewModel : CreateTestViewModel?
    private var expandedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadConfiguration()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        
        // Register Cell
        tableView.register(
            UINib(nibName: "SubjectDetailsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "SubjectDetailsTableViewCell"
        )
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        exameNameTextView.text = viewModel?.exameName
        registerKeyboardNotifications()
        tableView.reloadData()
    }
    
    private func loadConfiguration(){
        viewModel?.setupExamConfigurationsIfNeeded()
        setupSectionsHeader()
        // Auto-expand first index on presentation
             if viewModel?.examConfigurations.count ?? 0 > 0 {
                 expandedIndexPath = IndexPath(row: 0, section: 0)
             }
        tableView.reloadData()
        
    }
    
    // MARK: - UITextViewDelegate
    public func textViewDidChange(_ textView: UITextView) {
        viewModel?.exameName = exameNameTextView.text ?? ""
        viewModel?.onSelectionChanged?()
       
    }
    private func setupUI() {
        
        exameNameDefaultLbl.setRequiredText("Exam Name")
        exameNameTextView.delegate = self
        styleTextView(exameNameTextView)
        sectionsContainerView.layer.cornerRadius = 12
        sectionsContainerView.layer.borderWidth = 1.0
        sectionsContainerView.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor
        sectionsContainerView.layer.masksToBounds = true
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    private func styleTextView(_ textView: UITextView) {
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor
        textView.backgroundColor = UIColor(red: 0.98, green: 0.985, blue: 1.0, alpha: 1.0)
        
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 8, right: 8)
        textView.adjustsFontForContentSizeCategory = true
        
        textView.isScrollEnabled = true
    }
    
    private func setupSectionsHeader() {
        guard let viewModel = viewModel else { return }
        
        // Clear previous tags
        sectionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Find section names of selected subjects from configurations
        let selectedSubjectSectionNames = Set(viewModel.examConfigurations.map { $0.sectionName.uppercased() })
        let finalSections = Array(selectedSubjectSectionNames).sorted()
        
        for name in finalSections {
            let pillView = UIView()
            pillView.translatesAutoresizingMaskIntoConstraints = false
            pillView.backgroundColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 0.08) // 8% alpha tint
            pillView.layer.cornerRadius = 12
            pillView.layer.masksToBounds = true
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = name
            label.textColor = UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)
            label.font = .systemFont(ofSize: 11, weight: .bold)
            label.textAlignment = .center
            
            pillView.addSubview(label)
            NSLayoutConstraint.activate([
                pillView.widthAnchor.constraint(equalToConstant: 24),
                pillView.heightAnchor.constraint(equalToConstant: 24),
                label.centerXAnchor.constraint(equalTo: pillView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: pillView.centerYAnchor)
            ])
            
            sectionsStackView.addArrangedSubview(pillView)
        }
    }
  
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    // MARK: - Keyboard Handling & Auto-Scrolling
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidBeginEditingNotification, object: nil)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let endFrame = view.convert(endFrameValue.cgRectValue, from: nil)
        // How much of the keyboard actually overlaps our view (0 if it's being dismissed/undocked off-screen)
        let overlap = max(0, view.bounds.maxY - endFrame.minY)
        let bottomInset = max(0, overlap - view.safeAreaInsets.bottom)

        let curve = UIView.AnimationCurve(rawValue: Int(curveRaw)) ?? .easeInOut
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) { [weak self] in
            guard let self = self else { return }
            self.tableView.contentInset.bottom = bottomInset + 20
            self.tableView.scrollIndicatorInsets.bottom = bottomInset + 20
        }
        animator.startAnimation()

        if bottomInset > 0 {
            scrollToActiveTextField()
        }
    }
    
    @objc private func textFieldDidBeginEditing(_ notification: Notification) {
        scrollToActiveTextField()
    }
    
//    private func scrollToActiveTextField() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
//            guard let self = self, let activeField = self.view.firstResponders else { return }
//
//            self.view.layoutIfNeeded() // make sure any pending row-height/autolayout changes are applied first
//
//            let rect = activeField.convert(activeField.bounds, to: self.tableView)
//            let visibleHeight = self.tableView.bounds.height - self.tableView.contentInset.bottom - self.tableView.contentInset.top
//            let maxOffsetY = max(-self.tableView.contentInset.top, self.tableView.contentSize.height - visibleHeight)
//            let targetOffsetY = min(maxOffsetY, max(-self.tableView.contentInset.top, rect.origin.y - 100))
//
//            self.tableView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: true)
//        }
//    }
    
    private func scrollToActiveTextField() {
        guard let activeField = self.view.firstResponders else { return }

        var targetRect = activeField.bounds
        if let textView = activeField as? UITextView,
           let selectedRange = textView.selectedTextRange {
            let caretRect = textView.caretRect(for: selectedRange.end)
            if caretRect.isFinite {
                targetRect = caretRect.insetBy(dx: 0, dy: -12) // small breathing room around the line
            }
        }

        let rectInTableView = activeField.convert(targetRect, to: self.tableView)
        self.tableView.scrollRectToVisible(rectInTableView, animated: true)
    }
    
}

extension SelectDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.examConfigurations.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SubjectDetailsTableViewCell",
            for: indexPath
        ) as? SubjectDetailsTableViewCell,
              let viewModel = viewModel else {
            return UITableViewCell()
        }
        
        let config = viewModel.examConfigurations[indexPath.row]
        
        let isExpand = (indexPath == expandedIndexPath)
        let isConfigSelected = viewModel.isSubjectConfigured(subjectId: config.subjectId, sectionId: config.sectionId)
        
        cell.Configure(with: config, viewModel: viewModel, isExpanded: isExpand, isConfigured: isConfigSelected)
        
        //Callback brining
        
        cell.onToggleExpand = {
            [weak self, weak cell] in
            guard let self = self else { return }
            
            self.dismissKeyboard()
            
            let previousExpand = self.expandedIndexPath
            if self.expandedIndexPath == indexPath {
                self.expandedIndexPath = nil
                
            }else{
                self.expandedIndexPath = indexPath
            }
            
            // Reload with animation
            var rowsToReload = [indexPath]
            if let prev = previousExpand, prev != indexPath {
                rowsToReload.append(prev)
            }
            
            self.tableView.reloadRows(at: rowsToReload, with: .fade)
            
            // Scroll new expanded cell to visible range
            if self.expandedIndexPath == indexPath {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                    self?.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                }
            }
            
        }
        
        cell.onAddTest = { [weak self] subjectId, sectionId in

            // Check if existing tests are fully configured before allowing a new one
            if let config = viewModel.examConfigurations.first(where: { $0.subjectId == subjectId && $0.sectionId == sectionId }) {
                if !config.tests.isEmpty && !viewModel.isSubjectConfigured(subjectId: subjectId, sectionId: sectionId) {
                    let alert = UIAlertController(
                        title: "Incomplete Details",
                        message: "Please fill all the details  before adding another Activity.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
            }
            
            viewModel.addTest(to: subjectId, sectionId: sectionId)
            self?.tableView.reloadData()
          }
        
        
        cell.onRemoveTest = { [weak self] testIdx, subjectId, sectionId in
                  viewModel.removeTest(at: testIdx, from: subjectId, sectionId: sectionId)
                  self?.tableView.reloadData()
              }
        
        cell.onUpdateTest = { [weak self, weak cell] updatedTest, testIdx in
            guard let self = self else { return }
            
            let wasConfigured = viewModel.isSubjectConfigured(subjectId: config.subjectId, sectionId: config.sectionId)
            
            
            viewModel.updateTest(updatedTest, for: config.subjectId, sectionId: config.sectionId, at: testIdx)
            
            // Update checkmark state locally in real time without reloading cell (keeps text focus active)
            let isConfigured = viewModel.isSubjectConfigured(subjectId: config.subjectId, sectionId: config.sectionId)
            cell?.checkmarkImageView.isHidden = !isConfigured
            
            // Only reload counterpart sections when configuration status actually changes (prevents scroll jitter while typing)
            
            if wasConfigured != isConfigured {
                self.reloadCounterpartSections(for: config.subjectName, excludingSectionId: config.sectionId)
            }
        }
        
//        cell.onHeightChanged = { [weak self] in
//            guard let self = self else { return }
//            // Animate cell height adjustment dynamically ONLY when text view size actually changes
//            self.tableView.beginUpdates()
//            self.tableView.endUpdates()
//            self.scrollToActiveTextField()
//        }
        
        cell.onMergeTapped = { [weak self] sourceSectionId, targetSectionId, subjectName in
            let alert = UIAlertController(
                title: "Merge Data",
                message: "Do you want to merge the previous \(subjectName) data?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Merge", style: .default, handler: { _ in
                self?.viewModel?.mergeConfigurations(from: sourceSectionId, to: targetSectionId, subjectName: subjectName)
                self?.tableView.reloadData()
            }))
            self?.present(alert, animated: true, completion: nil)
        }
        
        cell.onHeightChanged = { [weak self] in
            guard let self = self else { return }
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                self.tableView.layoutIfNeeded()   // <-- force layout to commit now, synchronously
            }
            self.scrollToActiveTextField()
        }
    
        return cell
    }
    
    
    private func reloadCounterpartSections(for subjectName: String, excludingSectionId: String) {
        guard let viewModel = viewModel else { return }
        var indexPathsToReload: [IndexPath] = []
        
        for (idx, config) in viewModel.examConfigurations.enumerated() {
            if config.subjectName.uppercased() == subjectName.uppercased() && config.sectionId != excludingSectionId {
                indexPathsToReload.append(IndexPath(row: idx, section: 0))
            }
        }
        
        if !indexPathsToReload.isEmpty {
            tableView.reloadRows(at: indexPathsToReload, with: .none)
        }
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}


// MARK: - UIView Extension to locate active responder
fileprivate extension UIView {
    var firstResponders: UIView? {
        if isFirstResponder { return self }
        for subview in subviews {
            if let responder = subview.firstResponders {
                return responder
            }
        }
        return nil
    }
}


extension CGRect {
    var isFinite: Bool {
        origin.x.isFinite && origin.y.isFinite && size.width.isFinite && size.height.isFinite
    }
}
