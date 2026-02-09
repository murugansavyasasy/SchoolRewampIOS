//
//  StrengthTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 12/12/24.
//

import UIKit

class StrengthTvCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var maleImageView: UIImageView!
    @IBOutlet weak var femaleImgView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var standardLbl: UILabel!
    @IBOutlet weak var viewDetailsBtnName: UIButton!
    @IBOutlet weak var standardFullview: UIView!
    @IBOutlet weak var girlsCountLbl: UILabel!
    @IBOutlet weak var boysCountLbl: UILabel!
    @IBOutlet weak var sectionCollertionView: UICollectionView!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var barchartHeight: NSLayoutConstraint!
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var progress: ThreeColorProgressView!
    @IBOutlet weak var othersCountLbl: UILabel!
    @IBOutlet weak var othersImageView: UIImageView!
    
    
    var hasAnimatedProgress = false
    var sections: [SectionList]?
    var boycount : String?
    var girlscount : String?
    let Section = "Section "
    let Boys  = "Boys : "
    let Girls  = "Girls : "
    let Unspecified  = "Unspecified : "
    let TotalStudents  = "Total Students"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        standardFullview.setShadow(cornerRadius:5)
        viewDetailsBtnName.layer.cornerRadius = 5
        // Initial UI Setup
        barchartHeight.constant = 0
        countLbl.setFont(style: .body, size: FontSize.BodySize)
        boysCountLbl.setFont(style: .body, size: FontSize.BodySize)
        girlsCountLbl.setFont(style: .body, size: FontSize.BodySize)
        othersCountLbl.setFont(style: .body, size: FontSize.BodySize)
        cellview.layer.cornerRadius = 10
        sectionCollertionView.delegate = self
        sectionCollertionView.dataSource = self
        sectionCollertionView.register(UINib(nibName: CellConfingName.SectionStregnthCVC, bundle: nil), forCellWithReuseIdentifier: CellConfingName.SectionStregnthCVC)
    }
    func updateProgress(boys: String, girls: String, others: String) {
        let boysCount = Int(boys) ?? 0
        let girlsCount = Int(girls) ?? 0
        let othersCount = Int(others) ?? 0
        let total = boysCount + girlsCount + othersCount
//        guard total > 0 else {
//            progressView.progress = 0
//            return
//        }
//        let boysPercent = Float(boysCount) / Float(total)
//        if !hasAnimatedProgress {
//            progressView.setProgress(boysPercent, animated: true)
//            hasAnimatedProgress = true
//        } else {
//            progressView.setProgress(boysPercent, animated: false)
//        }
        
        progress.setProgress(v1: CGFloat(boysCount), v2: CGFloat(girlsCount), v3: CGFloat(othersCount))
    }
    func configure(_ sections: [SectionList]?) {
        self.sections = sections
        sectionCollertionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = sections?[indexPath.item],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.SectionStregnthCVC, for: indexPath) as? SectionStregnthCVC else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 10
        cell.standardName.text = Section + (section.name ?? "")
        cell.standardName.setFont(style: .body, size: FontSize.TitleSize)
        // Boys
        setTwoPartAttributedText(label: cell.boysCountLbl,
                                 firstText: Boys,
                                 firstColor: .darkGray,
                                 secondText: "\(section.boys_count ?? "")",
                                 secondColor: .black)
        // Girls
        setTwoPartAttributedText(label: cell.girlsCountLbl,
                                 firstText: Girls,
                                 firstColor: .darkGray,
                                 secondText: "\(section.girls_count ?? "")",
                                 secondColor: .black)
        // Others
        setTwoPartAttributedText(label: cell.otersCountLbl,
                                 firstText: Unspecified,
                                 firstColor: .darkGray,
                                 secondText: "\(section.others_count ?? "0")",
                                 secondColor: .black)
        
        // Student Count Button Title
        let title =  TotalStudents + "\(section.total_students ?? "")"
        let font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let textWidth = (title as NSString).size(withAttributes: attributes).width
        let padding: CGFloat = 20
        cell.studentCount.setTitle(title, for: .normal)
        cell.studentCount.titleLabel?.font = font
        cell.studentCount.layer.cornerRadius = 8
        cell.btnWidth.constant = textWidth + padding
        cell.outerView.layer.cornerRadius = 10
        cell.outerView.clipsToBounds = true
        return cell
    }
    
    func setTwoPartAttributedText(label: UILabel,
                                  firstText: String,
                                  firstColor: UIColor,
                                  secondText: String,
                                  secondColor: UIColor) {
        let firstAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: firstColor
        ]
        let secondAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 11),
            .foregroundColor: secondColor
        ]
        let attributedText = NSMutableAttributedString(string: firstText, attributes: firstAttributes)
        attributedText.append(NSAttributedString(string: secondText, attributes: secondAttributes))
        label.attributedText = attributedText
    }
    
    // Collection Cell Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}


final class ThreeColorProgressView: UIView {

    private let segment1 = UIView()
    private let segment2 = UIView()
    private let segment3 = UIView()

    // MARK: - Colors

    var segment1Color: UIColor = UIColor(hex: "#3D82ED") {
        didSet { segment1.backgroundColor = segment1Color }
    }

    var segment2Color: UIColor = UIColor(hex: "#FF93C0") {
        didSet { segment2.backgroundColor = segment2Color }
    }

    var segment3Color: UIColor = .lightGray {
        didSet { segment3.backgroundColor = segment3Color }
    }

    /// Color used when all values are zero
    var emptyStateColor: UIColor = .lightGray {
        didSet { emptyView.backgroundColor = emptyStateColor }
    }

    private let emptyView = UIView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        clipsToBounds = true
        layer.cornerRadius = 2.5

        emptyView.backgroundColor = emptyStateColor

        segment1.backgroundColor = segment1Color
        segment2.backgroundColor = segment2Color
        segment3.backgroundColor = segment3Color

        addSubview(emptyView)
        addSubview(segment1)
        addSubview(segment2)
        addSubview(segment3)
    }

    // MARK: - Progress

    func setProgress(v1: CGFloat, v2: CGFloat, v3: CGFloat) {

        let total = v1 + v2 + v3

        // ZERO STATE
        if total == 0 {
            emptyView.isHidden = false
            segment1.isHidden = true
            segment2.isHidden = true
            segment3.isHidden = true

            emptyView.frame = bounds
            return
        }

        // NORMAL STATE
        emptyView.isHidden = true
        segment1.isHidden = false
        segment2.isHidden = false
        segment3.isHidden = false

        let w1 = bounds.width * (v1 / total)
        let w2 = bounds.width * (v2 / total)
        let w3 = bounds.width * (v3 / total)

        segment1.frame = CGRect(x: 0, y: 0, width: w1, height: bounds.height)
        segment2.frame = CGRect(x: w1, y: 0, width: w2, height: bounds.height)
        segment3.frame = CGRect(x: w1 + w2, y: 0, width: w3, height: bounds.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
