//
//  FestivalWishVC.swift
//  School Chimes
//
//  Festival greeting popup shown on the staff / parent dashboards when the
//  menu API returns `is_festival = true`.
//
//  Driven by `festival_details`: title (`name`), date, content and image (`url`).
//  Whatever the API leaves empty is hidden; an empty image url falls back to a
//  common festival image.
//
//  ⚠️ UNDER DEVELOPMENT — see the global note in DashboardPopupScheduler.swift.
//  The API still returns `is_festival = false`, so this screen does not appear
//  on the live dashboards yet.
//

import UIKit
import SDWebImage

/// Fallback banner used when the API sends an empty / unreachable image url.
private enum FestivalFallback {
    /// Illustration in `BaseAssets.xcassets` shown in place of the API image.
    static let assetName = "school-closed-day"
}

class FestivalWishVC: UIViewController {

    // MARK: - Inputs
    /// `festival_details.name`
    var titleText: String = ""
    /// `festival_details.date` — expected as `yyyy-MM-dd`.
    var dateText: String = ""
    /// `festival_details.content`
    var descriptionText: String = ""
    /// `festival_details.url`
    var imageUrlString: String = ""
    /// Called after the popup has been dismissed.
    var onDismiss: (() -> Void)?

    // MARK: - UI
    private let cardView = UIView()
    private let bannerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let contentStack = UIStackView()
    private let textStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setupCard()
        setupContent()
        setupCloseButton()
        setupBackgroundTap()
        populate()
    }

    // MARK: - Setup

    private func setupCard() {
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        let cardWidth = min(UIScreen.main.bounds.width - 48, 340)

        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: cardWidth),
            cardView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func setupContent() {
        bannerImageView.contentMode = .scaleAspectFill
        bannerImageView.clipsToBounds = true
        bannerImageView.backgroundColor = .systemGray6
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        bannerImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = Colornames.primeryColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .center
        dateLabel.numberOfLines = 1

        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(dateLabel)
        textStack.addArrangedSubview(descriptionLabel)
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.isLayoutMarginsRelativeArrangement = true
        textStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 20, right: 16)

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.addArrangedSubview(bannerImageView)
        contentStack.addArrangedSubview(textStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }

    private func setupCloseButton() {
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .darkGray
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        closeButton.layer.cornerRadius = 15
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        cardView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setupBackgroundTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func populate() {
        // Title / date / content are shown only when the API sends them.
        let title = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        titleLabel.text = title
        titleLabel.isHidden = title.isEmpty

        let date = formattedDate(from: dateText.trimmingCharacters(in: .whitespacesAndNewlines))
        dateLabel.text = date
        dateLabel.isHidden = date.isEmpty

        let content = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        descriptionLabel.text = content
        descriptionLabel.isHidden = content.isEmpty

        // Nothing to say → drop the whole text block so the card is image only.
        textStack.isHidden = title.isEmpty && date.isEmpty && content.isEmpty

        // Empty / invalid image url, or a failed download → common festival image.
        let urlString = imageUrlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.isEmpty, let url = URL(string: urlString) {
            bannerImageView.sd_setImage(with: url) { [weak self] image, error, _, _ in
                if image == nil || error != nil {
                    self?.applyCommonBanner()
                }
            }
        } else {
            applyCommonBanner()
        }
    }

    /// Turns the API's `yyyy-MM-dd` date into `24 Nov 2026`. An unparseable value
    /// is shown as-is, an empty value stays empty so the label hides.
    private func formattedDate(from rawDate: String) -> String {
        guard !rawDate.isEmpty else { return "" }

        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = inputFormatter.date(from: rawDate) else { return rawDate }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "dd MMM yyyy"
        return outputFormatter.string(from: date)
    }

    /// Common festival banner: the `school-closed-day` illustration, falling back
    /// to an SF Symbol if that asset is missing from the flavour's catalog.
    /// Shown with aspect-fit so the artwork is never cropped.
    private func applyCommonBanner() {
        if let image = UIImage(named: FestivalFallback.assetName) {
            bannerImageView.image = image
            bannerImageView.contentMode = .scaleAspectFit
            bannerImageView.tintColor = nil
            bannerImageView.backgroundColor = Colornames.primeryColor.withAlphaComponent(0.08)
        } else {
            let configuration = UIImage.SymbolConfiguration(pointSize: 64, weight: .regular)
            bannerImageView.image = UIImage(systemName: "sparkles", withConfiguration: configuration)
            bannerImageView.contentMode = .center
            bannerImageView.tintColor = Colornames.primeryColor
            bannerImageView.backgroundColor = Colornames.primeryColor.withAlphaComponent(0.12)
        }
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismissPopup()
    }

    /// Tapping the dimmed area outside the card closes the popup.
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        guard !cardView.frame.contains(location) else { return }
        dismissPopup()
    }

    private func dismissPopup() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}
