//
//  CertificateRequestVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 21/01/25.
//

import UIKit
import DropDown

class CertificateRequestVC: UIViewController {
    
    @IBOutlet weak var SegmentControl: UISegmentedControl!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var ButtonStackview: UIStackView!
    @IBOutlet weak var RequestCertificateBtn: UIButton!
    @IBOutlet weak var CertificatesBtn: UIButton!
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
    
    let dropdown = DropDown()
    let certificates = [
        CertificateRequestDetails(certificatename: "Attendance Certificate", Date: "21 Jan 2024", reason: "I need this certificate to apply for the education loan for my studies", status: "Approved"),
        CertificateRequestDetails(certificatename: "Bonafide Certificate", Date: "15 Jan 2024", reason: "Required for scholarship application", status: "Pending"),
        CertificateRequestDetails(certificatename: "Migration Certificate", Date: "10 Jan 2024", reason: "Needed for admission to another university", status: "Approved"),
        CertificateRequestDetails(certificatename: "Provisional Certificate", Date: "05 Jan 2024", reason: "Required for job application process", status: "Rejected"),
        CertificateRequestDetails(certificatename: "Character Certificate", Date: "01 Jan 2024", reason: "Necessary for government employment application", status: "Approved")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))

        ButtonStackview.isLayoutMarginsRelativeArrangement = true
        ButtonStackview.layoutMargins = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        ButtonStackview.layer.cornerRadius = 8
        RequestCertificateBtn.layer.cornerRadius = 8
        CertificatesBtn.layer.cornerRadius = 8
        
        ButtonStackview.layer.borderWidth = 0.0
        ButtonStackview.layer.borderColor = UIColor.gray.cgColor
        
        ButtonStackview.backgroundColor = .clr
        CertificatesBtn.backgroundColor = .white
        RequestBtn.backgroundColor = .white
     

        //gradientcolours(button: RequestCertificateBtn, colours: [Colornames.gradientgreen.cgColor,Colornames.gradientBlue.cgColor])
        
        RequestView.layer.cornerRadius = 10
        RequestView.layer.shadowColor = UIColor.black.cgColor
        RequestView.layer.shadowOffset = CGSize(width: 0, height: 2)
        RequestView.layer.shadowRadius = 5
        RequestView.layer.shadowOpacity = 0.3
        
        StyleAndTranslate()
        
        tv.isHidden = true
        
        RequestCertificateBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
        CertificatesBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
        BackBtn.setTitleFont(style: .primary, size: 17)
        CertificatesBtn.tintColor = .lightGray
        
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(UrgencyDropdown))
        DropdownView.addGestureRecognizer(tap)
        DropdownView.isUserInteractionEnabled = true
        
        let urgentTap = UITapGestureRecognizer(target: self, action: #selector(UrgentAct))
        UrgentView.addGestureRecognizer(urgentTap)
        UrgentView.isUserInteractionEnabled = true
        
        let noturgentTap = UITapGestureRecognizer(target: self, action: #selector(NotUrgentAct))
        NotUrgentView.addGestureRecognizer(noturgentTap)
        NotUrgentView.isUserInteractionEnabled = true
        
        let nib = UINib(nibName: CellConfingName.CertificateTableViewCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.CertificateTableViewCell)
        
        configureSegmentedControlAppearance(SegmentControl, lightenFactor: 0.3) // Adjust lightening factor
               configureSegmentedControlText(SegmentControl)
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        view.applyGradient(
            colors: [
                Colornames.gradientBlue,  // Green
                Colornames.gradientgreen   // Blue
            ],
            startPoint: CGPoint(x: 1, y: 0.5),  // Right-center
            endPoint: CGPoint(x: 0, y: 0.5)     // Left-center
        )
        configureButton(RequestCertificateBtn, gradientColors: [UIColor.blue,UIColor.green],opacity: 0.8,lightenFactor: 0.6)
    }
    
    func StyleAndTranslate(){
        
        NameLbl.setFont(style: .body, size: 15)
        StandardLbl.setFont(style: .body, size: 15)
        SelectCertificateLbl.setFont(style: .title, size: FontSize.TitleSize)
        SelectUrgencyLbl.setFont(style: .title, size: FontSize.TitleSize)
        DropdownLbl.setFont(style: .body, size: FontSize.BodySize)
        UrgentLbl.setFont(style: .body, size: FontSize.BodySize)
        NotUrgentLbl.setFont(style: .body, size: FontSize.BodySize)
        RequestBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        DropdownView.layer.cornerRadius = 10
        DropdownView.layer.borderWidth = 1
        DropdownView.layer.borderColor = UIColor.lightGray.cgColor
        
        UrgentView.layer.cornerRadius = 10
        UrgentView.layer.borderWidth = 1
        UrgentView.layer.borderColor = UIColor.lightGray.cgColor
        NotUrgentView.layer.cornerRadius = 10
        NotUrgentView.layer.borderWidth = 1
        NotUrgentView.layer.borderColor = UIColor.lightGray.cgColor
        UrgentCheckImg.image = UIImage(named: "CheckCircle")
        NoturgentCheckImg.image = UIImage(named: "CheckCircle")
        
        ReasonTextView.layer.cornerRadius = 10
        ReasonTextView.layer.borderWidth = 1
        ReasonTextView.layer.borderColor = UIColor.lightGray.cgColor
        ReasonTextView.text = "Enter Reason for Certificate"
        ReasonTextView.textColor = .gray
        
        RequestBtn.layer.cornerRadius = 10
    }
    
    
    @IBAction func SegmentControlAct(_ sender: Any) {
        UpdateUI()
    }
    
    // MARK: - Customize UISegmentedControl Background
        func configureSegmentedControlAppearance(_ segmentedControl: UISegmentedControl, lightenFactor: CGFloat) {
            // Base gradient colors
            let baseColors = [UIColor.systemBlue, UIColor.systemGreen]

            // Apply lightening factor to colors
            let adjustedColors = baseColors.map { $0.blendedWithWhite(factor: lightenFactor) }

            // Create gradient image for the selected segment
            let gradientImage = createGradientImage(colors: adjustedColors)

            // Create a solid color image for unselected segments
            let unselectedColorImage = createImageWithColor(color: UIColor.lightGray.withAlphaComponent(0.3))

            // Apply the images to the segmented control
            segmentedControl.setBackgroundImage(unselectedColorImage, for: .normal, barMetrics: .default)
            segmentedControl.setBackgroundImage(gradientImage, for: .selected, barMetrics: .default)

            // Remove divider image for a seamless look
            segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

            // Optional: Round the corners of the segmented control
            segmentedControl.layer.cornerRadius = 8
            segmentedControl.layer.masksToBounds = true
            
        }

        // MARK: - Customize UISegmentedControl Text Colors
        func configureSegmentedControlText(_ segmentedControl: UISegmentedControl) {
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.darkGray, // Text color for unselected segments
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white, // Text color for selected segment
                .font: UIFont.systemFont(ofSize: 16, weight: .bold)
            ]
            
            segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
            segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        }

        // MARK: - Create Gradient Image
        func createGradientImage(colors: [UIColor]) -> UIImage? {
            let gradientLayer = CAGradientLayer()
            let size = CGSize(width: 200, height: 40) // Adjust width/height as needed
            gradientLayer.frame = CGRect(origin: .zero, size: size)
            gradientLayer.colors = colors.map { $0.cgColor }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

            UIGraphicsBeginImageContext(size)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            gradientLayer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return image
        }

        // MARK: - Create Solid Color Image
        func createImageWithColor(color: UIColor) -> UIImage {
            let rect = CGRect(x: 0, y: 0, width: 1, height: 30) // Small 1px-wide image
            UIGraphicsBeginImageContext(rect.size)
            guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
            context.setFillColor(color.cgColor)
            context.fill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image ?? UIImage()
        }
    
   

    
    func UpdateUI(){
        if SegmentControl.selectedSegmentIndex == 0{
            tv.isHidden = true
            RequestView.isHidden = false
        }else {
            tv.isHidden = false
            RequestView.isHidden = true
            tv.delegate = self
            tv.dataSource = self
            tv.reloadData()
        }
       
    }
    
    @IBAction func RequestAct(_ sender: Any) {
        //gradientcolours(button: RequestCertificateBtn, colours: [Colornames.gradientgreen.cgColor,Colornames.gradientBlue.cgColor])
        configureButton(RequestCertificateBtn, gradientColors: [UIColor.blue,UIColor.green],opacity: 0.8,lightenFactor: 0.6)
        RequestCertificateBtn.tintColor = .black
        CertificatesBtn.tintColor = .lightGray
        
        gradientcolours(button: CertificatesBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        
        tv.isHidden = true
        RequestView.isHidden = false
    }
    
    @IBAction func CertificatesAct(_ sender: Any) {
        //gradientcolours(button: CertificatesBtn, colours: [Colornames.gradientgreen.cgColor,Colornames.gradientBlue.cgColor])
        configureButton(CertificatesBtn, gradientColors: [UIColor.blue,UIColor.green],opacity: 0.8,lightenFactor: 0.6)
        CertificatesBtn.tintColor = .black
        RequestCertificateBtn.tintColor = .lightGray
        
        gradientcolours(button: RequestCertificateBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        
        tv.isHidden = false
        RequestView.isHidden = true
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
        
    }
    
    @IBAction func RequestCertificateAct(_ sender: Any) {
    }
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func UrgencyDropdown(){
        dropdown.anchorView = DropdownView
        dropdown.dataSource = ["Bonafide Certificate", "Attendance Certificate", "Transfer Certificate","Fee Certificate"]
        dropdown.show()
        dropdown.bottomOffset = CGPoint(x: 0, y: DropdownView.bounds.height)
        
        dropdown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            // Update the label inside the UIView
            if let label = self?.DropdownView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.numberOfLines = 0
                label.text = item
            }
        }
    }
    
    @IBAction func UrgentAct(){
        UrgentCheckImg.image = UIImage(named: "RadioCheck")
        NoturgentCheckImg.image = UIImage(named: "CheckCircle")
    }
    
    @IBAction func NotUrgentAct(){
        NoturgentCheckImg.image = UIImage(named: "RadioCheck")
        UrgentCheckImg.image = UIImage(named: "CheckCircle")
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
    
}

extension CertificateRequestVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return certificates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.CertificateTableViewCell, for: indexPath) as! CertificateTableViewCell
        
        cell.certificateNameLbl.text = certificates[indexPath.row].certificatename
        cell.dateLbl.text = certificates[indexPath.row].Date
        cell.reasonLbl.text = certificates[indexPath.row].reason
        cell.StatusLbl.text = certificates[indexPath.row].status
        
        if certificates[indexPath.row].status == "Approved" {
            cell.statusView.backgroundColor = Colornames.AprovedClr
            cell.statusImgview.image = ImageName.check//UIImage(named: "checked_Tick")//UIImage(systemName: "checkmark.circle.fill")//
            cell.StatusLbl.textColor = .white
            cell.DownloadBtnHeight.constant = 30
            cell.DownloadBtn.isHidden = false
        } else if certificates[indexPath.row].status == "Rejected" {
            cell.statusView.backgroundColor = .red
            cell.statusImgview.image = UIImage(systemName: "multiply.circle.fill")
            cell.StatusLbl.textColor = .white
            cell.statusImgview.tintColor = .white
            cell.DownloadBtnHeight.constant = 0
            cell.DownloadBtn.isHidden = true
        } else {
            
//            if let originalImage = UIImage(named: "Pending") {
//                let resizedImage = originalImage.resizeTo(size: CGSize(width: 100, height: 100))
//                cell.statusImgview.image = resizedImage?.withTintColor(.white)//ImageName.Pending
//            cell.statusImgview.tintColor = .white
//                print("Original Size: \(originalImage.size), Resized Size: \(resizedImage!.size)")
//            }
            
            cell.StatusLbl.textColor = .white
            cell.StatusImgHeight.constant = 15
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

extension CertificateRequestVC : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if ReasonTextView.text == "Enter Reason for Certificate"{
            ReasonTextView.text = ""
            ReasonTextView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if ReasonTextView.text == ""{
            ReasonTextView.text = "Enter Reason for Certificate"
            ReasonTextView.textColor = .gray
        }
    }
}

struct CertificateRequestDetails{
    
    let certificatename : String
    let Date : String
    let reason : String
    let status : String
    
}

import UIKit

extension UIImage {
    func resizeTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0) // Use 0.0 to maintain scale factor
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}



