//
//  StrengthTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 12/12/24.
//

import UIKit
import Charts

class StrengthTvCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    var hasAnimatedProgress = false
    var sections: [SectionList]?
    var boycount : String?
    var girlscount : String?
    override func awakeFromNib() {
        super.awakeFromNib()
        standardFullview.setShadow(cornerRadius:5)
        viewDetailsBtnName.layer.cornerRadius = 5
        // Initial UI Setup
        barchartHeight.constant = 0
        countLbl.setFont(style: .body, size: FontSize.BodySize)
        boysCountLbl.setFont(style: .body, size: FontSize.BodySize)
        girlsCountLbl.setFont(style: .body, size: FontSize.BodySize)
        cellview.layer.cornerRadius = 10
        sectionCollertionView.delegate = self
        sectionCollertionView.dataSource = self
        sectionCollertionView.register(UINib(nibName: "SectionStregnthCVC", bundle: nil), forCellWithReuseIdentifier: "SectionStregnthCVC")
        
        
//        updateProgress(
//            boys: boycount ?? "",
//            girls: girlscount ?? "")
    }



    func updateProgress(boys: String, girls: String) {
        let boysCount = Int(boys) ?? 0
        let girlsCount = Int(girls) ?? 0
        let total = boysCount + girlsCount
        guard total > 0 else {
            progressView.progress = 0
            return
        }

        let boysPercent = Float(boysCount) / Float(total)

        if !hasAnimatedProgress {
            progressView.setProgress(boysPercent, animated: true)
            hasAnimatedProgress = true
        } else {
            progressView.setProgress(boysPercent, animated: false)
        }
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
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionStregnthCVC", for: indexPath) as? SectionStregnthCVC else {
            return UICollectionViewCell()
        }
        
        cell.layer.cornerRadius = 10
        cell.standardName.text = "Section " + (section.name ?? "")
        cell.standardName.setFont(style: .body, size: FontSize.TitleSize)
        
        // Boys
        setTwoPartAttributedText(label: cell.boysCountLbl,
                                 firstText: "Boys : ",
                                 firstColor: .darkGray,
                                 secondText: "\(section.boys_count ?? "")",
                                 secondColor: .black)
        
        // Girls
        setTwoPartAttributedText(label: cell.girlsCountLbl,
                                 firstText: "Girls : ",
                                 firstColor: .darkGray,
                                 secondText: "\(section.girls_count ?? "")",
                                 secondColor: .black)

        // Others
        setTwoPartAttributedText(label: cell.otersCountLbl,
                                 firstText: "Unspecified : ",
                                 firstColor: .darkGray,
                                 secondText: "\(section.other_count ?? "")",
                                 secondColor: .black)
        
        // Student Count Button Title
        let title =  "Total Students " + "\(section.total_students ?? "")"
        let font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let textWidth = (title as NSString).size(withAttributes: attributes).width
        let padding: CGFloat = 20
        
        cell.studentCount.setTitle(title, for: .normal)
        cell.studentCount.titleLabel?.font = font
        cell.studentCount.layer.cornerRadius = 8
        cell.btnWidth.constant = textWidth + padding
        
        // Styling
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
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: firstColor
        ]
        
        let secondAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: secondColor
        ]
        
        let attributedText = NSMutableAttributedString(string: firstText, attributes: firstAttributes)
        attributedText.append(NSAttributedString(string: secondText, attributes: secondAttributes))
        label.attributedText = attributedText
    }

    // Collection Cell Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 160)
    }
}

