//
//  StudentOneViewStatCells.swift
//  School Chimes
//
//  Visual stat cells for Student One View: a segmented ring, coloured tiles
//  and a labelled progress bar. Layout lives in OneViewRingCell.xib,
//  OneViewTilesCell.xib and OneViewBarCell.xib; the two small views below only
//  draw the ring and the bar fill (used as custom classes inside those XIBs).
//

import UIKit

// MARK: - Ring (custom class in OneViewRingCell.xib)

final class OneViewRingView: UIView {
    var lineWidth: CGFloat = 12
    private var segments: [(CGFloat, UIColor)] = []
    private let trackLayer = CAShapeLayer()
    private var arcLayers: [CAShapeLayer] = []
    private var animated = false

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = .clear
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor(feeHex: "EEF2F6").cgColor
        layer.addSublayer(trackLayer)
        isAccessibilityElement = false
    }

    /// Fractions should add up to 1 or less; the rest stays as the grey track.
    func setSegments(_ list: [(CGFloat, UIColor)], animate: Bool = true) {
        segments = list
        animated = !animate
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        guard radius > 0 else { return }
        trackLayer.lineWidth = lineWidth
        trackLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        arcLayers.forEach { $0.removeFromSuperlayer() }
        arcLayers = []
        let visible = segments.filter { $0.0 > 0.001 }
        let gap: CGFloat = visible.count > 1 ? 0.035 : 0
        var start = -CGFloat.pi / 2
        for (fraction, color) in visible {
            let sweep = CGFloat.pi * 2 * min(fraction, 1)
            let arc = CAShapeLayer()
            arc.fillColor = UIColor.clear.cgColor
            arc.strokeColor = color.cgColor
            arc.lineWidth = lineWidth
            arc.lineCap = visible.count > 1 ? .butt : .round
            let end = start + max(sweep - gap, 0.01)
            arc.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true).cgPath
            layer.addSublayer(arc)
            arcLayers.append(arc)
            if !animated {
                let a = CABasicAnimation(keyPath: "strokeEnd")
                a.fromValue = 0; a.toValue = 1; a.duration = 0.6
                a.timingFunction = CAMediaTimingFunction(name: .easeOut)
                arc.add(a, forKey: "grow")
            }
            start += sweep
        }
        animated = true
    }
}

// MARK: - Bar fill (custom class in OneViewBarCell.xib)

final class OneViewBarView: UIView {
    var fraction: CGFloat = 0 { didSet { setNeedsLayout() } }
    var fillColor: UIColor = OneViewPalette.paid { didSet { fill.backgroundColor = fillColor } }
    private let fill = UIView()

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = UIColor(feeHex: "EEF2F6")
        clipsToBounds = true
        fill.backgroundColor = fillColor
        addSubview(fill)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        fill.layer.cornerRadius = bounds.height / 2
        fill.frame = CGRect(x: 0, y: 0, width: bounds.width * min(max(fraction, 0), 1), height: bounds.height)
    }
}

// MARK: - Ring card (OneViewRingCell.xib)

final class OneViewRingCell: UITableViewCell {
    static let id = "OneViewRingCell"

    @IBOutlet weak var ringView: OneViewRingView!
    @IBOutlet weak var centerLabel: UILabel!
    @IBOutlet weak var centerCaptionLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var legend1Dot: UIView!
    @IBOutlet weak var legend1Title: UILabel!
    @IBOutlet weak var legend1Value: UILabel!
    @IBOutlet weak var legend2Dot: UIView!
    @IBOutlet weak var legend2Title: UILabel!
    @IBOutlet weak var legend2Value: UILabel!
    @IBOutlet weak var legend3Dot: UIView!
    @IBOutlet weak var legend3Title: UILabel!
    @IBOutlet weak var legend3Value: UILabel!

    func configure(caption: String, value: String, note: String, center: String, centerCaption: String, segments: [OneViewSegment]) {
        captionLabel.text = caption
        valueLabel.text = value
        noteLabel.text = note
        noteLabel.isHidden = note.isEmpty
        centerLabel.text = center
        centerCaptionLabel.text = centerCaption
        centerCaptionLabel.isHidden = centerCaption.isEmpty
        ringView.setSegments(segments.map { ($0.fraction, $0.color) })
        let rows = [(legend1Dot, legend1Title, legend1Value), (legend2Dot, legend2Title, legend2Value), (legend3Dot, legend3Title, legend3Value)]
        for (i, row) in rows.enumerated() {
            let seg = i < segments.count ? segments[i] : nil
            row.0?.backgroundColor = seg?.color
            row.1?.text = seg?.title
            row.2?.text = seg?.value
            row.0?.superview?.isHidden = seg == nil
        }
        accessibilityLabel = ([caption, value, center] + segments.map { "\($0.title) \($0.value)" }).joined(separator: ", ")
        isAccessibilityElement = true
    }
}

// MARK: - Tiles (OneViewTilesCell.xib) – up to 4 tiles in a 2 × 2 grid

final class OneViewTilesCell: UITableViewCell {
    static let id = "OneViewTilesCell"

    @IBOutlet weak var secondRow: UIStackView!
    @IBOutlet var tileViews: [UIView]!
    @IBOutlet var iconBackViews: [UIView]!
    @IBOutlet var iconViews: [UIImageView]!
    @IBOutlet var valueLabels: [UILabel]!
    @IBOutlet var titleLabels: [UILabel]!

    func configure(_ tiles: [OneViewTile]) {
        let ordered = { (list: [UIView]) in list.sorted { $0.tag < $1.tag } }
        let views = ordered(tileViews), backs = ordered(iconBackViews)
        let icons = iconViews.sorted { $0.tag < $1.tag }
        let values = valueLabels.sorted { $0.tag < $1.tag }
        let titles = titleLabels.sorted { $0.tag < $1.tag }
        for i in 0..<views.count {
            guard i < tiles.count else {
                views[i].alpha = 0
                views[i].isAccessibilityElement = false
                continue
            }
            let t = tiles[i], c = t.tone.colors
            views[i].alpha = 1
            views[i].backgroundColor = c.bg
            backs[i].backgroundColor = .white
            icons[i].image = UIImage(systemName: t.symbol)
            icons[i].tintColor = c.fg
            values[i].text = t.value
            values[i].textColor = c.fg
            titles[i].text = t.title
            views[i].isAccessibilityElement = true
            views[i].accessibilityLabel = "\(t.title), \(t.value)"
        }
        secondRow.isHidden = tiles.count <= 2
    }
}

// MARK: - Bar row (OneViewBarCell.xib)

final class OneViewBarCell: UITableViewCell {
    static let id = "OneViewBarCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var barView: OneViewBarView!
    @IBOutlet weak var subtitleLabel: UILabel!

    func configure(_ bar: OneViewBar) {
        titleLabel.text = bar.title
        valueLabel.text = bar.value
        valueLabel.textColor = bar.tone.colors.fg
        barView.fillColor = bar.tone == .neutral ? OneViewPalette.discount : bar.tone.colors.fg
        barView.fraction = bar.fraction
        subtitleLabel.text = bar.subtitle
        subtitleLabel.isHidden = bar.subtitle.isEmpty
        isAccessibilityElement = true
        accessibilityLabel = "\(bar.title), \(bar.value)"
    }
}
