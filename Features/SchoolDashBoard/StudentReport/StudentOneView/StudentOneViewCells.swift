//
//  StudentOneViewCells.swift
//  School Chimes
//
//  Cells for the Student One View screen. Layout lives in the matching .xib files;
//  these classes only bind data.
//

import UIKit
import Kingfisher

// MARK: - Tab chip  (OneViewTabCell.xib)

final class OneViewTabCell: UICollectionViewCell {
    static let id = "OneViewTabCell"

    @IBOutlet weak var pillView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(_ title: String, selected: Bool) {
        titleLabel.text = title
        let brand = UIColor(named: "BackGroundClr") ?? UIColor(feeHex: "1F5FD1")
        pillView.backgroundColor = selected ? brand : .white
        pillView.layer.borderWidth = selected ? 0 : 1
        pillView.layer.borderColor = UIColor(feeHex: "E2E8F0").cgColor
        titleLabel.textColor = selected ? .white : StudentFeeColor.ink
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits = selected ? [.button, .selected] : .button
    }
}

// MARK: - Student header  (OneViewHeaderCell.xib)

final class OneViewHeaderCell: UITableViewCell {
    static let id = "OneViewHeaderCell"

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var line1Label: UILabel!
    @IBOutlet weak var line2Label: UILabel!

    func configure(name: String, line1: String, line2: String, photo: String) {
        nameLabel.text = name
        line1Label.text = line1
        line1Label.isHidden = line1.isEmpty
        line2Label.text = line2
        line2Label.isHidden = line2.isEmpty
        initialsLabel.text = name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
        if let url = URL(string: photo), photo.hasPrefix("http") {
            photoView.isHidden = false
            photoView.kf.setImage(with: url)
        } else {
            photoView.kf.cancelDownloadTask()
            photoView.isHidden = true
            photoView.image = nil
        }
    }
}

// MARK: - Summary card  (OneViewSummaryCell.xib)

final class OneViewSummaryCell: UITableViewCell {
    static let id = "OneViewSummaryCell"

    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var statsStack: UIStackView!
    @IBOutlet weak var stat1TitleLabel: UILabel!
    @IBOutlet weak var stat1ValueLabel: UILabel!
    @IBOutlet weak var stat2TitleLabel: UILabel!
    @IBOutlet weak var stat2ValueLabel: UILabel!
    @IBOutlet weak var stat3TitleLabel: UILabel!
    @IBOutlet weak var stat3ValueLabel: UILabel!

    func configure(caption: String, value: String, note: String, progress: Float?, stats: [OneViewStat]) {
        captionLabel.text = caption
        valueLabel.text = value
        noteLabel.text = note
        noteLabel.isHidden = note.isEmpty
        progressView.isHidden = progress == nil
        progressView.progress = progress ?? 0
        progressView.progressTintColor = (progress ?? 1) < 0.5 ? StudentFeeColor.orange : (UIColor(named: "BackGroundClr") ?? StudentFeeColor.green)
        let pairs = [(stat1TitleLabel, stat1ValueLabel), (stat2TitleLabel, stat2ValueLabel), (stat3TitleLabel, stat3ValueLabel)]
        for (i, pair) in pairs.enumerated() {
            let stat = i < stats.count ? stats[i] : nil
            pair.0?.text = stat?.title
            pair.1?.text = stat?.value
            pair.0?.superview?.isHidden = stat == nil
        }
        statsStack.isHidden = stats.isEmpty
    }
}

// MARK: - Key / value  (OneViewKeyValueCell.xib)

final class OneViewKeyValueCell: UITableViewCell {
    static let id = "OneViewKeyValueCell"

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    func configure(key: String, value: String) {
        keyLabel.text = key
        valueLabel.text = value
    }
}

// MARK: - List row  (OneViewListCell.xib)

final class OneViewListCell: UITableViewCell {
    static let id = "OneViewListCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var statusLabel: StudentFeePillLabel!

    func configure(_ item: OneViewItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        subtitleLabel.isHidden = item.subtitle.isEmpty
        detailLabel.text = item.detail
        detailLabel.isHidden = item.detail.isEmpty
        valueLabel.text = item.value
        valueLabel.isHidden = item.value.isEmpty
        let colors = item.tone.colors
        statusLabel.text = item.status
        statusLabel.textColor = colors.fg
        statusLabel.backgroundColor = colors.bg
        statusLabel.isHidden = item.status.isEmpty
        accessoryType = item.url.isEmpty ? .none : .disclosureIndicator
        selectionStyle = item.url.isEmpty ? .none : .default
    }
}
