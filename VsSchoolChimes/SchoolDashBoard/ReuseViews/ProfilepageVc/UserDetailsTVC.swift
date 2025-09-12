//
//  UserDetailsTVC.swift
//  School Chimes
//
//  Created by Chandhru on 02/09/25.
//

import UIKit
import DropDown
protocol UpdateProfileDelegate{
    func updateProfile(params:[String:Any]?)
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
    let SectionDropdown = DropDown()
    private var genderButtons: [UIButton] = []
    var selectedGender: String?
    var attachments: [AttachmentItem] = []
    var sectionList: [String] = []
    var delegate:UpdateProfileDelegate?
    // Node key and update tracking
    var node: String?
    var updateParams: [String: Any]?
    var onValueChanged: ((String, Any?) -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
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
        imageSelection()
        attachmentCollectionView.register(UINib(nibName: "AttachmentCVC", bundle: nil), forCellWithReuseIdentifier: "AttachmentCVC")
        addAttachmentBtn.layer.cornerRadius = 4
        attachmentCollectionView.dataSource = self
        attachmentCollectionView.delegate = self
        txtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    func imageSelection() {
           PhotoPickerManager.shared.onCameraImagePicked = { [weak self] image in
               guard let self = self else { return }
               self.attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
               user_inputs.selectedFileType = CommonStringFile.IMAGE
               self.attachmentCollectionView.reloadData()
               valueChanged(attachments)
           }
           
           PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
               guard let self = self else { return }
               user_inputs.selectedFileType = CommonStringFile.IMAGE
               let imageItems = images.map {
                   AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
               }
               self.attachments.append(contentsOf: imageItems)
               self.attachmentCollectionView.reloadData()
               valueChanged(attachments)
           }
           
           PhotoPickerManager.shared.onFilePicked = { [weak self] data in
               guard let self = self else { return }
               user_inputs.selectedFileType = CommonStringFile.pdf
               self.attachments.append(
                   AttachmentItem(image: nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf)
               )
               self.reloadCollectionAndUpdateHeight()
               valueChanged(attachments)
           }
           
       }
    override func prepareForReuse() {
        super.prepareForReuse()
        resetViews()
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
        onValueChanged?(key, value as Any)
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
    }
    
    // MARK: - Configure Cell
    func configure(with item: UserDetailItem?) {
        resetViews()
        guard let item = item else {
            titleLable.isHidden = true
            updateview.isHidden = false
            return
        }
        node = item.node
        print(node ?? "")
        titleLable.text = item.title
        titleLable.isHidden = false
        
        switch item.type {
        case .text:
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
            updateGenderSelection(selected: item.value)
            enableGenderButtons(item.is_editable ?? false)
            
        case .dropdown:
            dropDownView.isHidden = false
            dropDownLbl.text = item.value ?? "Select \(item.title)"
            sectionList = item.options ?? []
            
        case .document:
            attachmentView.isHidden = false
            addAttachmentBtn.isHidden = !(item.is_editable ?? false)
            attachments.removeAll()
            if let files = item.options {
                attachments = files.map { urlString in
                    let url = urlString
                    let type = urlString.lowercased().hasSuffix(".jpg") || urlString.lowercased().hasSuffix(".png") ? "image" :
                               urlString.lowercased().hasSuffix(".mp4") || urlString.lowercased().hasSuffix(".mov") ? "video" :
                               "unknown"
                    
                    if type == "image" {
                        return AttachmentItem(image: nil, imageURL: url, fileType: "image")
                    } else if type == "video" {
                        return AttachmentItem(image: UIImage(systemName: "video"), imageURL: url, fileType: "video", VideoURl: URL(string: url))
                    } else {
                        return AttachmentItem(image: nil, imageURL: url, fileType: type)
                    }
                }
            }
            reloadCollectionAndUpdateHeight()
        case .number, .image:
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
            genderButtons.first { $0.title(for: .normal) == selected }?
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(countrydropDownTapped))
        contryDropDownView.addGestureRecognizer(tap)
        contryDropDownView.isUserInteractionEnabled = true
    }
    
    @objc private func dropDownTapped() {
        SectionDropdown.anchorView = dropDownView
        SectionDropdown.dataSource = sectionList
        SectionDropdown.bottomOffset = CGPoint(x: 0, y: dropDownView.bounds.height)
        SectionDropdown.show()
        
        SectionDropdown.selectionAction = { [weak self] _, item in
            guard let self = self else { return }
            self.dropDownLbl.text = item
            self.valueChanged(item)
        }
    }
    
    @objc private func countrydropDownTapped() {
        SectionDropdown.anchorView = contryDropDownView
        SectionDropdown.dataSource = sectionList
        SectionDropdown.bottomOffset = CGPoint(x: 0, y: contryDropDownView.bounds.height)
        SectionDropdown.show()
        
        SectionDropdown.selectionAction = { [weak self] _, item in
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
        let urls = attachments
        valueChanged(urls)
    }
    
    @IBAction func addDocs(_ sender: UIButton) {
        if attachments.count < 10 {
            if let topVC = getCurrentViewController() {
                PhotoPickerManager.shared.limiSelection = 10 - attachments.count
                PhotoPickerManager.shared.presentPicker(ofType: .file, from: topVC)
            }
        } else {
            let alert = CustomAlert()
            if let topVC = getCurrentViewController() {
                alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: topVC)
            }
        }
    }
    
    private func reloadCollectionAndUpdateHeight() {
        attachmentCollectionView.reloadData()
        attachmentCollectionView.layoutIfNeeded()
        collectionViewHeight.constant = attachmentCollectionView.collectionViewLayout.collectionViewContentSize.height
        let urls = attachments.map { $0.imageURL ?? "" }.joined(separator: ",")
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
            return UICollectionViewCell()
        }
        
        let file = attachments[indexPath.item]
        cell.deleteBtn.isHidden = false
        cell.delegate = self
        
        switch file.fileType.uppercased() {
        case CommonStringFile.IMAGE:
            cell.imgIconBtn.setTitle("IMG", for: .normal)
            cell.imgIconBtn.backgroundColor = UIColor.blue.withAlphaComponent(0.15)
        case CommonStringFile.VIDEO:
            cell.imgIconBtn.setTitle("VID", for: .normal)
            if #available(iOS 15.0, *) {
                cell.imgIconBtn.backgroundColor = UIColor.systemMint.withAlphaComponent(0.15)
            }
        default:
            cell.imgIconBtn.setTitle("DOC", for: .normal)
            cell.imgIconBtn.backgroundColor = UIColor.orange.withAlphaComponent(0.15)
        }
        
        if let urlString = file.imageURL, let path = URL(string: urlString) {
            let fullFileName = path.lastPathComponent
            let fileName = fullFileName.components(separatedBy: "-").last ?? fullFileName
            cell.imageNameLbl.text = fileName
        }
        
        if let urlString = file.imageURL, let sizeURL = URL(string: urlString) {
            getRemoteFileSize(from: sizeURL) { sizeString in
                DispatchQueue.main.async {
                    cell.imageTypeSizeLbl.text = "\(sizeString ?? "").\(file.fileType)"
                }
            }
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
            } else { completion(nil) }
        }.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2
        let availableWidth = collectionView.frame.width
        let itemWidth = floor(availableWidth / itemsPerRow)
        return CGSize(width: itemWidth, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
}

// MARK: - Country Codes
struct CountryCodes {
    static let dialingCodes: [String: String] = [
        "US": "+1",
        "IN": "+91",
        "GB": "+44",
        "CA": "+1",
        "AU": "+61",
        "DE": "+49",
        "FR": "+33",
        "JP": "+81",
        "CN": "+86"
    ]
}
