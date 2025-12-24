//
//  UserDetailsTVC.swift
//  School Chimes
//
//  Created by Chandhru on 02/09/25.
//

import UIKit
//import DropDown

protocol UpdateProfileDelegate {
    func updateProfile(params: [String: Any]?)
}

@available(iOS 14.0, *)
class UserDetailsTVC: UITableViewCell, Datepicker, DeleteImge, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
    @IBOutlet weak var addAttachmentBtn: UIButton!
    @IBOutlet weak var contryDropDownView: UIView!
    @IBOutlet weak var txtViewHeight: NSLayoutConstraint!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var contryCode: UILabel!
    @IBOutlet weak var contriFlag: UIImageView!
    @IBOutlet weak var genderStack: UIStackView!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dropDownLbl: UILabel!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var updateview: UIView!
    @IBOutlet weak var titleLable: UILabel!
    
    // MARK: - Properties
    let sectionDropdown = DropDown()
    private var genderButtons: [UIButton] = []
    var selectedGender: String?
    var attachments: [AttachmentItem] = []
    var sectionList: [String] = []
    var delegate: UpdateProfileDelegate?
    var node: String?
    var updateParams: [String: Any]?
    var onValueChanged: ((String, Any?) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetViews()
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        resetViews()
        txtField.addDoneButton()
        txtField.delegate = self
        txtView.delegate = self
        txtView.addDoneButton()
        setupGenderButtons()
        addTapToDropDown()
        countryDropDown()
        addTapToDateButton()
        applyBorders()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        // Register the nib for AttachmentCVC
        let nib = UINib(nibName: "AttachmentCVC", bundle: nil)
        attachmentCollectionView.register(nib, forCellWithReuseIdentifier: "AttachmentCVC")
        
        // Set delegate and data source
        attachmentCollectionView.dataSource = self
        attachmentCollectionView.delegate = self
        
        // Configure layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        attachmentCollectionView.collectionViewLayout = layout
        
        // Ensure collection view is visible
        attachmentCollectionView.isHidden = false
        attachmentView.isHidden = false
        
        // Set background color for debugging
        attachmentCollectionView.backgroundColor = .white
        addAttachmentBtn.layer.cornerRadius = 4
    }
    
  
    // MARK: - Update Tracking
    private func valueChanged(_ value: Any?) {
        guard let key = node else { return }
        updateParams = updateParams ?? [:]
        if let value = value {
            updateParams?[key] = value
        } else {
            updateParams?.removeValue(forKey: key)
        }
        onValueChanged?(key, value)
    }
    
    // MARK: - Reset Views
    private func resetViews() {
        txtField.isHidden = true
        txtView.isHidden = true
        contryDropDownView.isHidden = true
        dateView.isHidden = true
        dropDownView.isHidden = true
        genderStack.isHidden = true
        attachmentView.isHidden = true
        addAttachmentBtn.isHidden = true
        updateview.isHidden = true
        
        titleLable.text = nil
        txtField.text = nil
        txtView.text = nil
        dateLbl.text = nil
        dropDownLbl.text = nil
        selectedGender = nil
        attachments.removeAll()
        
        // Ensure collection view is reset
        attachmentCollectionView.reloadData()
        collectionViewHeight.constant = 0
    }
    
    // MARK: - Configure Cell
    func configure(with item: UserDetailItem?,attachments: [AttachmentItem]?) {
        resetViews()
        guard let item = item else {
            titleLable.isHidden = true
            updateview.isHidden = false
            return
        }
        node = item.node
        if item.optional ?? false{
            titleLable.text = item.title
        }else{
            titleLable.profilesetRequiredText(item.title)
        }
        titleLable.isHidden = false
        
        switch item.type {
        case .text,.number:
            txtField.isHidden = false
            txtField.placeholder = item.title
            txtField.text = item.value
            txtField.isEnabled = item.is_editable ?? false
        case .address:
            txtView.isHidden = false
            txtViewHeight.constant = 100
            txtView.text = item.value ?? ""
            txtView.isEditable = item.is_editable ?? false
            
        case .mobile:
            txtField.isHidden = false
            contryDropDownView.isHidden = false
            txtField.placeholder = item.title
            txtField.text = item.value
            txtField.isEnabled = item.is_editable ?? false
            contryCode.text = "+91"
            let countries = getCountryListWithDialingCodes()
            sectionList = countries.map { $0.code }
            
        case .calendar:
            dateView.isHidden = false
            dateLbl.text = item.value ?? "Select \(item.title)"
            dateBtn.isEnabled = item.is_editable ?? false
            
        case .gender:
            genderStack.isHidden = false
            updateGenderSelection(selected: item.value ?? "")
            enableGenderButtons(item.is_editable ?? false)
            
        case .dropdown:
            dropDownView.isHidden = false
            dropDownLbl.text = item.options?.first ?? "Select \(item.title)"
            sectionList = item.options ?? []
            
        case .document:
            attachmentView.isHidden = false
            addAttachmentBtn.isHidden = !(item.is_editable ?? false)
            self.attachments = attachments ?? []
            reloadCollectionAndUpdateHeight()
        case .image:
            break
        }
    }
    
    // MARK: - TextField & TextView Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        valueChanged(textField.text)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        valueChanged(textField.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        valueChanged(textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        valueChanged(textView.text)
    }
    
    // MARK: - Gender Handling
    private func setupGenderButtons() {
        let genders = ["Male", "Female", "Other"]
        genderButtons.forEach { $0.removeFromSuperview() }
        genderButtons = []
        
        for gender in genders {
            let button = UIButton(type: .system)
            button.setTitle(gender, for: .normal)
            let font = UIFont.systemFont(ofSize: 16, weight: .regular)
            button.titleLabel?.font = font
            let config = UIImage.SymbolConfiguration(pointSize: font.pointSize, weight: .regular)
            button.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal)
            button.tintColor = .systemBlue
            button.contentHorizontalAlignment = .leading
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            button.addTarget(self, action: #selector(genderSelected(_:)), for: .touchUpInside)
            genderStack.addArrangedSubview(button)
            genderButtons.append(button)
        }
    }
    
    @objc private func genderSelected(_ sender: UIButton) {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        genderButtons.forEach { $0.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal) }
        sender.setImage(UIImage(systemName: "largecircle.fill.circle", withConfiguration: config), for: .normal)
        selectedGender = sender.title(for: .normal)
        valueChanged(selectedGender)
    }
    
    private func updateGenderSelection(selected: String?) {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        genderButtons.forEach { $0.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal) }
        if let selected = selected {
            genderButtons.first { $0.title(for: .normal) == selected.capitalized }?
                .setImage(UIImage(systemName: "largecircle.fill.circle", withConfiguration: config), for: .normal)
        }
        selectedGender = selected
    }
    
    private func enableGenderButtons(_ isEnabled: Bool) {
        genderButtons.forEach { $0.isEnabled = isEnabled; $0.alpha = isEnabled ? 1 : 0.6 }
    }
    
    // MARK: - DropDown Handling
    private func addTapToDropDown() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dropDownTapped))
        dropDownView.addGestureRecognizer(tap)
        dropDownView.isUserInteractionEnabled = true
    }
    
    private func countryDropDown() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(countryDropDownTapped))
        contryDropDownView.addGestureRecognizer(tap)
        contryDropDownView.isUserInteractionEnabled = true
    }
    
    @objc private func dropDownTapped() {
        sectionDropdown.anchorView = dropDownView
        sectionDropdown.dataSource = sectionList
        sectionDropdown.bottomOffset = CGPoint(x: 0, y: dropDownView.bounds.height)
        sectionDropdown.show()
        
        sectionDropdown.selectionAction = { [weak self] _, item in
            guard let self = self else { return }
            self.dropDownLbl.text = item
            self.valueChanged(item)
        }
    }
    
    @objc private func countryDropDownTapped() {
        sectionDropdown.anchorView = contryDropDownView
        sectionDropdown.dataSource = sectionList
        sectionDropdown.bottomOffset = CGPoint(x: 0, y: contryDropDownView.bounds.height)
        sectionDropdown.show()
        
        sectionDropdown.selectionAction = { [weak self] _, item in
            guard let self = self else { return }
            self.contryCode.text = item
            self.valueChanged(item)
        }
    }
    
    // MARK: - Date Handling
    private func addTapToDateButton() {
        dateBtn.addTarget(self, action: #selector(dateTapped), for: .touchUpInside)
    }
    
    @objc private func dateTapped() {
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = dateLbl.text
        vc.maximumDate = Date()
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        if let topVC = getCurrentViewController() {
            topVC.present(vc, animated: false)
        }
    }
    
    func date(date: String) {
        dateLbl.text = date
        valueChanged(date)
    }
    
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
    
    // MARK: - Borders & Corner Radius
    private func applyBorders() {
        let allViews = [txtField, txtView, contryDropDownView, dateView, dropDownView]
        allViews.forEach { view in
            view?.layer.cornerRadius = 8
            view?.layer.borderWidth = 1
            view?.layer.borderColor = UIColor.systemGray5.cgColor
            view?.clipsToBounds = true
        }
        
        genderButtons.forEach { btn in
            btn.layer.cornerRadius = 6
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.systemGray5.cgColor
            btn.clipsToBounds = true
        }
        
        dateBtn.layer.cornerRadius = 8
        dateBtn.layer.borderWidth = 1
        dateBtn.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    // MARK: - Attachments
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        reloadCollectionAndUpdateHeight()
        valueChanged(attachments)
//        if let table = self.superview as? UITableView {
//            table.beginUpdates()
//            table.endUpdates()
//        }
    }
    
    private func reloadCollectionAndUpdateHeight() {
        attachmentCollectionView.reloadData()
        attachmentCollectionView.layoutIfNeeded()
        collectionViewHeight.constant = attachmentCollectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    // MARK: - Country Codes
    func getCountryListWithDialingCodes() -> [(name: String, code: String)] {
        let locale = Locale.current
        let countryCodes = Locale.isoRegionCodes
        var result = [(name: String, code: String)]()
        
        for countryCode in countryCodes {
            if let countryName = locale.localizedString(forRegionCode: countryCode),
               let dialingCode = CountryCodes.dialingCodes[countryCode] {
                result.append((name: countryName, code: dialingCode))
            }
        }
        return result.sorted { $0.name < $1.name }
    }
}

// MARK: - UICollectionView Handling
@available(iOS 14.0, *)
extension UserDetailsTVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCVC", for: indexPath) as? AttachmentCVC else {
            print("Failed to dequeue AttachmentCVC")
            return UICollectionViewCell()
        }
        
        let file = attachments[indexPath.item]
        if let urlString = file.imageURL?.lowercased(), urlString.hasPrefix("http") {
            cell.deleteBtn.isHidden = true
        } else {
            cell.deleteBtn.isHidden = false
        }
        cell.delegate = self
//        cell.deleteBtn.tag = indexPath.item
        // Configure cell based on file type
        switch file.fileType.uppercased() {
        case CommonStringFile.IMAGE:
            cell.imgIconBtn.setTitle("IMG", for: .normal)
            cell.imgIconBtn.backgroundColor = UIColor.blue.withAlphaComponent(0.15)
        case CommonStringFile.pdf:
            cell.imgIconBtn.setTitle("DOC", for: .normal)
            cell.imgIconBtn.backgroundColor = UIColor.orange.withAlphaComponent(0.15)
        default:
            cell.imgIconBtn.setTitle("DOC", for: .normal)
            cell.imgIconBtn.backgroundColor = UIColor.gray.withAlphaComponent(0.15)
        }
        
        // Set file name
        if let urlString = file.imageURL, let path = URL(string: urlString) {
            let fullFileName = path.lastPathComponent
            let fileName = fullFileName.components(separatedBy: "-").last ?? fullFileName
            cell.imageNameLbl.text = fileName
        } else {
            cell.imageNameLbl.text = "File \(indexPath.item + 1)"
        }
        // Fetch and display file size
        if let urlString = file.imageURL, let sizeURL = URL(string: urlString) {
            getRemoteFileSize(from: sizeURL) { sizeString in
                DispatchQueue.main.async {
                    cell.imageTypeSizeLbl.text = "\(sizeString ?? "Unknown").\(file.fileType)"
                }
            }
        } else {
            cell.imageTypeSizeLbl.text = "Unknown.\(file.fileType)"
        }
        
        return cell
    }
    
    func getRemoteFileSize(from url: URL, completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse,
               let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length"),
               let size = Double(contentLength) {
                let sizeInKB = size / 1024.0
                let sizeString: String
                if sizeInKB > 1024 {
                    sizeString = String(format: "%.1f MB", sizeInKB / 1024.0)
                } else {
                    sizeString = String(format: "%.0f KB", sizeInKB)
                }
                completion(sizeString)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let currentVC = getCurrentViewController() {
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.attachment = attachments
            imageVC.subjectName = "Profile"
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.item
            imageVC.modalPresentationStyle = .fullScreen
            currentVC.present(imageVC, animated: true)
        }

       
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2
        let padding: CGFloat = 10
        let availableWidth = collectionView.frame.width - (padding * (itemsPerRow - 1))
        let itemWidth = floor(availableWidth / itemsPerRow)
        return CGSize(width: itemWidth, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - Country Codes
struct CountryCodes {
    static let dialingCodes: [String: String] = {
        var codes: [String: String] = [:]
        // Add user default country code if available
        if let countryDetails = UserDefaultFileManager.getCountryDetails() {
            if let code = countryDetails.code, let id = countryDetails.id {
                codes["\(id)"] = "\(code)"
            }
        }
        
        return codes
    }()
}
