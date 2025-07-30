//
//  CertificateRequestVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 21/01/25.
//

import UIKit
import DropDown

class CertificateRequestVC: UIViewController {

    @IBOutlet weak var certificatesView: UIView!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var DropdownView: UIView!
    @IBOutlet weak var RequestView: UIView!
    @IBOutlet weak var SelectCertificateLbl: UILabel!
    @IBOutlet weak var DropdownLbl: UILabel!
    @IBOutlet weak var DropdownImgview: UIImageView!
    @IBOutlet weak var SelectUrgencyLbl: UILabel!
    @IBOutlet weak var Urgencystackview: UIStackView!
    @IBOutlet weak var NotUrgentView: UIView!
    @IBOutlet weak var NoturgentCheckImg: UIImageView!
    @IBOutlet weak var NotUrgentLbl: UILabel!
    @IBOutlet weak var UrgentView: UIView!
    @IBOutlet weak var UrgentLbl: UILabel!
    @IBOutlet weak var UrgentCheckImg: UIImageView!
    @IBOutlet weak var RequestBtn: UIButton!
    @IBOutlet weak var ReasonTextView: UITextView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var HistoryBtn: UIButton!
    @IBOutlet weak var CreateBtn: UIButton!
    
    let dropdown = DropDown()
    var CertificatTypes : [String]?
    var certificates: [CertificateRequest]? = []
    var filteredCertificates: [CertificateRequest]? = []
    var urgetStatus = "Not Urgent"
    var studentDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
//                    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//                    layout.minimumLineSpacing = 0
//                    layout.minimumInteritemSpacing = 0
//                }
        
        certificateTypeApi()
        view.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                           startPoint: CGPoint(x: 1, y: 0.5),
                           endPoint: CGPoint(x: 0, y: 0.5))

        BackBtn.applyBackButton()
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        NameLbl.text = studentDetails?.name
        StandardLbl.text = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
        ReasonTextView.applyRightTxt()
        searchBar.searchTextField.addDoneButton()
        configureUI()
        addUnderline(to: CreateBtn, unselectedButton: HistoryBtn)
        setupGestureRecognizers()
        
        
        setupTableView()
        searchBar.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                           startPoint: CGPoint(x: 1, y: 0.5),
                           endPoint: CGPoint(x: 0, y: 0.5))
    }

    private func configureUI() {
        ReasonTextView.delegate = self
        ReasonTextView.layer.cornerRadius = 10
        ReasonTextView.layer.borderWidth = 1
        ReasonTextView.layer.borderColor = UIColor.lightGray.cgColor
        ReasonTextView.text = "Enter Reason for Certificate"
        ReasonTextView.textColor = .gray

        RequestView.layer.cornerRadius = 10
        RequestView.layer.shadowColor = UIColor.black.cgColor
        RequestView.layer.shadowOffset = CGSize(width: 0, height: 2)
        RequestView.layer.shadowRadius = 5
        RequestView.layer.shadowOpacity = 0.3

        DropdownView.layer.cornerRadius = 10
        DropdownView.layer.borderWidth = 1
        DropdownView.layer.borderColor = UIColor.lightGray.cgColor

        UrgentView.layer.cornerRadius = 10
        UrgentView.layer.borderWidth = 1
        UrgentView.layer.borderColor = UIColor.lightGray.cgColor

        NotUrgentView.layer.cornerRadius = 10
        NotUrgentView.layer.borderWidth = 1
        NotUrgentView.layer.borderColor = UIColor.lightGray.cgColor

        RequestBtn.layer.cornerRadius = 10

        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        SelectCertificateLbl.setFont(style: .title, size: FontSize.TitleSize)
        SelectUrgencyLbl.setFont(style: .title, size: FontSize.TitleSize)
        DropdownLbl.setFont(style: .body, size: FontSize.BodySize)
        UrgentLbl.setFont(style: .body, size: FontSize.BodySize)
        NotUrgentLbl.setFont(style: .body, size: FontSize.BodySize)
        RequestBtn.setTitleFont(style: .body, size: FontSize.BodySize)

        UrgentCheckImg.image = UIImage(named: "CheckCircle")
        NoturgentCheckImg.image = UIImage(named: "RadioCheck")
    }

    private func setupGestureRecognizers() {
        DropdownView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UrgencyDropdown)))
        UrgentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UrgentAct)))
        NotUrgentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NotUrgentAct)))
    }

    private func setupTableView() {
        tv.isHidden = true
        cv.isHidden = true
        certificatesView.isHidden = true
        tv.register(UINib(nibName: CellConfingName.CertificateTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.CertificateTableViewCell)
        tv.delegate = self
        tv.dataSource = self
        
        cv.register(UINib(nibName: "CertificateCv", bundle: nil), forCellWithReuseIdentifier: "CertificateCv")
        cv.delegate = self
        cv.dataSource = self
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
    
    func certificateListApi() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_certificate_request_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<CertificateResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                  //  self?.tv.isHidden = false
                    self?.certificates = response.data
                    self?.filteredCertificates = response.data
                  //  self?.tv.reloadData()
                    self?.cv.reloadData()
//                    self?.noDataImg.isHidden = !(self?.filteredCertificates?.isEmpty ?? false)
//                    self?.noDataLbl.isHidden = !(self?.filteredCertificates?.isEmpty ?? false)
//                    self?.noDataLbl.text = response.message
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }
    func certificateTypeApi() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_certificate_types,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.CertificatTypes = response.data
                    self?.DropdownLbl.text = self?.CertificatTypes?.first
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }

    func SendeRequestApi(reason: String) {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_certificate_send_request,
            parameters: [
                "requested_for": DropdownLbl.text ?? "",
                "urgency_level": urgetStatus,
                "reason": reason
            ],
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<ChangePasswordSuc, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    let alert = CustomAlert()
                    alert.showAlert(title: "Success", message: "Request submitted successfully.", on: self ?? UIViewController())
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }

    @IBAction func requestCertificate(_ sender: UISegmentedControl) {
        certificatesView.isHidden = sender.selectedSegmentIndex == 0
        RequestView.isHidden = sender.selectedSegmentIndex == 1
        if sender.selectedSegmentIndex == 1{
            certificateListApi()
        }
            
    }
    
    @IBAction func CreateAction(_ sender: Any) {
        addUnderline(to: CreateBtn, unselectedButton: HistoryBtn)
        cv.isHidden = true
        RequestView.isHidden = false
    }
    
    @IBAction func HistoryAction(_ sender: Any) {
        addUnderline(to: HistoryBtn, unselectedButton: CreateBtn)
        certificateListApi()
        cv.isHidden = false
        RequestView.isHidden = true
    }
    
    @IBAction func RequestCertificateAct(_ sender: Any) {
        if !ReasonTextView.text.isEmpty && ReasonTextView.text != "Enter Reason for Certificate" {
            SendeRequestApi(reason: ReasonTextView.text)
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "Alert", message: AlertstringFile.Fill_All_Required_Fields, on: self)
        }
    }

    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func UrgencyDropdown() {
        dropdown.anchorView = DropdownView
        dropdown.dataSource = CertificatTypes ?? []
        dropdown.show()
        dropdown.bottomOffset = CGPoint(x: 0, y: DropdownView.bounds.height)

        dropdown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.DropdownLbl.text = item
        }
    }

    @IBAction func UrgentAct() {
        UrgentCheckImg.image = UIImage(named: "RadioCheck")
        NoturgentCheckImg.image = UIImage(named: "CheckCircle")
        urgetStatus = "Urgent"
    }

    @IBAction func NotUrgentAct() {
        NoturgentCheckImg.image = UIImage(named: "RadioCheck")
        UrgentCheckImg.image = UIImage(named: "CheckCircle")
        urgetStatus = "Not Urgent"
    }
}

extension CertificateRequestVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCertificates?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.CertificateTableViewCell, for: indexPath) as! CertificateTableViewCell

        let item = filteredCertificates?[indexPath.row]
        cell.certificateNameLbl.text = item?.type
        cell.dateLbl.text = item?.requested_on?.convertToTargetDateFormat() ?? "-"
        cell.issueCertificatStack.isHidden = item?.issued_on == ""
        cell.issuedLbl.text = item?.issued_on?.convertToTargetDateFormat() ?? "-"
        cell.confic(secondString: item?.reason)
        cell.StatusLbl.text = item?.status

        if item?.status == "Approved" {
            cell.statusView.backgroundColor = Colornames.AprovedClr
            cell.statusImgview.image = ImageName.check
            cell.StatusLbl.textColor = .white
            cell.DownloadBtnHeight.constant = 30
            cell.DownloadBtn.isHidden = false
        } else if item?.status == "Rejected" {
            cell.statusView.backgroundColor = .red
            cell.statusImgview.image = UIImage(systemName: "multiply.circle.fill")
            cell.StatusLbl.textColor = .white
            cell.statusImgview.tintColor = .white
            cell.DownloadBtnHeight.constant = 0
            cell.DownloadBtn.isHidden = true
        } else {
            cell.StatusLbl.textColor = .white
            cell.statusImgview.image = ImageName.Pending
            cell.statusImgview.tintColor = .white
            cell.statusView.backgroundColor = Colornames.pendingClr
            cell.DownloadBtnHeight.constant = 0
            cell.DownloadBtn.isHidden = true
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CertificateRequestVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter Reason for Certificate" {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Reason for Certificate"
            textView.textColor = .gray
        }
    }
}

extension UIImage {
    func resizeTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

extension CertificateRequestVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCertificates = certificates
        } else {
            filteredCertificates = certificates?.filter {
                ($0.type?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.reason?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.issued_on?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        noDataImg.isHidden = !(filteredCertificates?.isEmpty ?? false)
        noDataLbl.isHidden = !(filteredCertificates?.isEmpty ?? false)
        
        tv.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension CertificateRequestVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCertificates?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "CertificateCv", for: indexPath) as! CertificateCv
        let data = filteredCertificates?[indexPath.item]
        cell.CertificateName.text=data?.type
        cell.reasonLbl.text = data?.reason
        if data?.status == "Approved" {
            
            cell.CertificateView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.8).cgColor
        }else {
            
           // cell.CertificateView.backgroundColor = .systemGray6
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let spacing: CGFloat = 10
        let inset: CGFloat = 10

        // Adjust for spacing and insets
        let availableWidth = collectionView.bounds.width - (inset * 2 + spacing)

        // Get the text and font
        let text = filteredCertificates?[indexPath.item].reason ?? ""
        let font = UIFont.systemFont(ofSize: 12)

        // Calculate text height using boundingRect
        let labelMaxSize = CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let boundingRect = NSString(string: text).boundingRect(
            with: labelMaxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )

        // Calculate total height with extra fixed UI elements (like padding, images, etc.)
        let totalHeight = ceil(boundingRect.height) + 40 + 90

        return CGSize(width: availableWidth, height: totalHeight)
    }

    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let spacing: CGFloat = 10
//        let inset: CGFloat = 10
//
//        let availableWidth = collectionView.bounds.width - (inset * 2 + spacing)
//       // let width = floor(availableWidth)
//        let width = collectionView.frame.width
//        
//        let label = UILabel()
//        label.text = filteredCertificates?[indexPath.item].reason ?? ""
//        label.font = UIFont.systemFont(ofSize: 12)
//        
//        let heigt = label.frame.height + 40 + 90
//
//        return CGSize(width: width, height: heigt)
//    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    
}


import UIKit

@IBDesignable
class FolderView: UIView {

    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        shapeLayer.fillColor = UIColor.orange.cgColor
        layer.insertSublayer(shapeLayer, at: 0)

        // Optional: Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawFolderShape()
    }

    private func drawFolderShape() {
        let w = bounds.width
        let h = bounds.height

        guard w > 0, h > 0 else { return }

        let r: CGFloat = 16
        let tabWidth: CGFloat = 40
        let tabHeight: CGFloat = 18

        let path = UIBezierPath()
        path.move(to: CGPoint(x: r, y: 0))
        path.addLine(to: CGPoint(x: tabWidth, y: 0))
        path.addLine(to: CGPoint(x: tabWidth + 10, y: tabHeight))
        path.addLine(to: CGPoint(x: w - r, y: tabHeight))
        path.addQuadCurve(to: CGPoint(x: w, y: tabHeight + r), controlPoint: CGPoint(x: w, y: tabHeight))
        path.addLine(to: CGPoint(x: w, y: h - r))
        path.addQuadCurve(to: CGPoint(x: w - r, y: h), controlPoint: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: r, y: h))
        path.addQuadCurve(to: CGPoint(x: 0, y: h - r), controlPoint: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 0, y: r))
        path.addQuadCurve(to: CGPoint(x: r, y: 0), controlPoint: CGPoint(x: 0, y: 0))

        shapeLayer.path = path.cgPath
        shapeLayer.frame = bounds
    }
}
