//
//  AbsentStudentCVC.swift
//  School Chimes
//
//  Created by Chandhru on 11/09/25.
//
import UIKit

class AbsentStudentCVC: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var profileOuterView: UIView!
    @IBOutlet weak var outerView: ShapCustomView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var adminLbl: UILabel!
    @IBOutlet weak var mobileNoBtn: UIButton!
    
    // MARK: - Properties
    static let identifier = "AbsentStudentCVC"
    private var triangleLayer: CAShapeLayer?
    private var curvedTopLayer: CAShapeLayer?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        outerView.setShadow()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profile.image = nil
        nameLbl.text = nil
        rollNoLbl.text = nil
        adminLbl.text = nil
        mobileNoBtn.setTitle(nil, for: .normal)
        
        // Remove existing layers
        triangleLayer?.removeFromSuperlayer()
        triangleLayer = nil
        curvedTopLayer?.removeFromSuperlayer()
        curvedTopLayer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileOuterView.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
        profileOuterView.layer.cornerRadius = 10
        profile.layer.cornerRadius = 10
        profile.tintColor = UIColor.white
    }

    
    // MARK: - Public Methods
    func configure(with student: AbsentisReportStudent) {
        nameLbl.text = student.student_name
        rollNoLbl.text = "Roll No: \(student.roll_no ?? "")"
        adminLbl.text = student.admission_no
        mobileNoBtn.setTitle(student.primary_mobile, for: .normal)
        
        if let imageUrl = student.photo_path, !imageUrl.isEmpty {
            loadImage(from: imageUrl)
        } else {
            profile.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    // MARK: - Image Loading
    private func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else {
            setDefaultProfileImage()
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.setDefaultProfileImage()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.profile.image = image
            }
        }.resume()
    }
    
    private func setDefaultProfileImage() {
        profile.image = UIImage(systemName: "person.circle.fill")
    }
    
    // MARK: - IBActions
    @IBAction func mobileButtonTapped(_ sender: UIButton) {
        
        guard let phoneNumber = sender.titleLabel?.text,
              !phoneNumber.isEmpty,
              let url = URL(string: "tel://\(phoneNumber)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

class ShapCustomView: UIView {
    private var curvedTopLayer: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
        addCurvedTopShape()
    }
    
    private func setupUI() {
        // outerView styling
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        backgroundColor = .white
        layer.cornerRadius = 10
        
        // profileOuterView styling (if separate view)
        let profileOuterView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        profileOuterView.layer.cornerRadius = 10
        addSubview(profileOuterView)
        
        // profile image styling
        let profileView = UIImageView(frame: profileOuterView.bounds)
        profileView.layer.cornerRadius = profileView.frame.width / 2
        profileView.clipsToBounds = true
        profileOuterView.addSubview(profileView)
    }
    
    private func addCurvedTopShape() {
        curvedTopLayer?.removeFromSuperlayer()
        
        let width = bounds.width
        let height = bounds.height
        let curveHeight: CGFloat = 90
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: curveHeight))
        path.addQuadCurve(to: CGPoint(x: width, y: curveHeight), controlPoint: CGPoint(x: width/2, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        
        layer.mask = shapeLayer
        curvedTopLayer = shapeLayer
    }
}
