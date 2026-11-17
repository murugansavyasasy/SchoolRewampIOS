//
//  DashboardAds.swift
//  School Chimes
//
//  Internal ads on the staff and parent dashboards (dashboard/api/dashboard/get-ads).
//
//  Response: data[0] = { ads_display_options: { enable_ad, banner_ad, native_ad, google_ad } },
//            data[1…] = { id, name, content_url, redirect_url } (one per ad).
//  The banner shows only when status is true, enable_ad and banner_ad are true
//  and at least one ad has an image. Otherwise it stays hidden.
//  The close button hides it until the app is opened again.
//
//  Layout: DashboardAdBannerView.xib (the banner) and DashboardAdCell.xib (one ad).
//

import UIKit
import Kingfisher
import SafariServices

// MARK: - Model

struct DashboardAd {
    let id: String
    let name: String
    let imageURL: URL
    let redirectURL: URL?
}

struct DashboardAdsResponse: Codable {
    let status: Bool?
    let message: String?
    let data: [FeeJSON]?

    /// Ads to show, or [] when ads are switched off or the call failed.
    var bannerAds: [DashboardAd] {
        guard status == true, let items = data else { return [] }
        let objects = items.compactMap { $0.object }
        let options = objects.first { $0["ads_display_options"] != nil }?["ads_display_options"]?.object
        let flag: (String) -> Bool = { key in
            switch options?[key] {
            case .bool(let b)?: return b
            case .number(let n)?: return n != 0
            case .string(let s)?: return ["true", "1", "yes"].contains(s.lowercased())
            default: return false
            }
        }
        // No options block = show; an options block must allow ads and banners.
        if options != nil && (!flag("enable_ad") || !flag("banner_ad")) { return [] }
        return objects.compactMap { o -> DashboardAd? in
            let r = FeeRecord(raw: o)
            guard let link = r.text("content_url"), let url = URL(string: link.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? link) else { return nil }
            let redirect = r.text("redirect_url").flatMap { URL(string: $0) }
            return DashboardAd(id: r.text("id") ?? "", name: r.text("name") ?? "", imageURL: url, redirectURL: redirect)
        }
    }
}

enum DashboardAdsService {
    /// Set when the user closes the banner; cleared when the app restarts.
    // 24 h close rule – turned off for now (uncomment to hide ads for 24 h after the user closes them).
//    /// Closing the banner hides it for this long (also across app launches).
//    static let snoozeAfterClose: TimeInterval = 24 * 60 * 60
//    private static let closedAtKey = "dashboardAdsClosedAt.v2"

//    static var closedThisSession: Bool {
//        get {
//            let at = UserDefaults.standard.double(forKey: closedAtKey)
//            return at > 0 && Date().timeIntervalSince1970 - at < snoozeAfterClose
//        }
//        set {
//            UserDefaults.standard.set(newValue ? Date().timeIntervalSince1970 : 0, forKey: closedAtKey)
//        }
//    }

    /// Pages whose banner the user closed (until the app is opened again).
    /// Each page is separate: closing ads on Homework does not close them on Notice board.
    /// Key: the page's menu_id, or "dashboard" for the home screens.
    private static var closedPages = Set<String>()

    private static func key(_ menuId: Int?) -> String { menuId.map { "menu-\($0)" } ?? "dashboard" }

    static func isClosed(menuId: Int?) -> Bool { closedPages.contains(key(menuId)) }

    static func close(menuId: Int?) { closedPages.insert(key(menuId)) }

    static func load(token: String, menuId: Int? = nil, completion: @escaping ([DashboardAd]) -> Void) {
        guard !isClosed(menuId: menuId) else {
            print("📢 Ads: hidden – closed by the user in this session")
            completion([]); return
        }
        var params: [String: Any] = [:]
        if let id = menuId { params["menu_id"] = id }
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_dashboard_get_ads,
            parameters: params,
            type: ApitTypeSringFile.GET,
            token: token,
            isBaseUrl: false
        ) { (result: Result<DashboardAdsResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let ads = response.bannerAds
                    print("📢 Ads: status=\(response.status.map { "\($0)" } ?? "nil") message=\(response.message ?? "") ads=\(ads.count)")
                    completion(ads)
                case .failure(let error):
                    print("📢 Ads: request failed – \(error.localizedDescription)")
                    completion([])
                }
            }
        }
    }
}

// MARK: - One ad  (DashboardAdCell.xib)

final class DashboardAdCell: UICollectionViewCell {
    static let id = "DashboardAdCell"

    @IBOutlet weak var adImageView: UIImageView!

    func configure(_ ad: DashboardAd) {
        let brand = UIColor(named: "BackGroundClr") ?? UIColor(feeHex: "1F5FD1")
        adImageView.backgroundColor = brand.withAlphaComponent(0.05)
        adImageView.layer.cornerRadius = 12
        // Fill the whole rounded frame (edges of very wide or tall images are trimmed).
        adImageView.contentMode = .scaleAspectFill
        adImageView.clipsToBounds = true
        adImageView.layer.borderWidth = 1
        adImageView.layer.borderColor = brand.withAlphaComponent(0.25).cgColor
        adImageView.kf.indicatorType = .activity
        adImageView.kf.setImage(with: ad.imageURL, options: [.transition(.fade(0.2))])
        isAccessibilityElement = true
        accessibilityLabel = ad.name
        accessibilityTraits = ad.redirectURL == nil ? .image : [.image, .link]
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        adImageView.kf.cancelDownloadTask()
        adImageView.image = nil
    }
}

// MARK: - Banner  (DashboardAdBannerView.xib)

/// Put a plain UIView with this custom class in the dashboard XIB; it loads its own layout.
final class DashboardAdBannerView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sponsoredLabel: UILabel!

    /// Called after the user taps close (the dashboard hides the view).
    var onClose: (() -> Void)?
    /// The page this banner belongs to (nil = dashboard). Closing only hides ads for this page.
    var menuId: Int?

    private var ads: [DashboardAd] = []
    private var timer: Timer?

    override init(frame: CGRect) { super.init(frame: frame); loadLayout() }
    required init?(coder: NSCoder) { super.init(coder: coder); loadLayout() }

    deinit { timer?.invalidate() }

    private func loadLayout() {
        Bundle.main.loadNibNamed("DashboardAdBannerView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        backgroundColor = .clear

        // No card or white background: each ad image sits straight on the dashboard, with rounded corners.
        cardView.backgroundColor = .clear
        collectionView.backgroundColor = .clear

        collectionView.register(UINib(nibName: DashboardAdCell.id, bundle: nil), forCellWithReuseIdentifier: DashboardAdCell.id)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = .fast

        closeButton.accessibilityLabel = "Close ad".translated()
        sponsoredLabel.text = "Ad".translated()
        pageControl.addTarget(self, action: #selector(pageTapped), for: .valueChanged)
    }

    /// Shows the ads, or hides the banner when the list is empty.
    func show(_ list: [DashboardAd]) {
        ads = list
        pageControl.numberOfPages = list.count
        pageControl.currentPage = 0
        pageControl.isHidden = list.count < 2
        // One ad: 100 pt. Several ads: 116 pt, room for the page dots.
        constraints.first { $0.firstAttribute == .height && $0.secondItem == nil }?.constant = list.count > 1 ? 116 : 100
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
        setVisible(!list.isEmpty, animated: true)
        if !list.isEmpty { playEntrance() }
        autoAdvancesLeft = list.count - 1
        restartTimer()
    }

    /// How many more automatic moves are allowed. After every ad has been shown once it stays still.
    private var autoAdvancesLeft = 0
    private static var didPlayEntrance = false

    private var calmMode: Bool { UIAccessibility.isReduceMotionEnabled || UIAccessibility.isVoiceOverRunning }

    /// Fades the banner in and lifts it 8 pt, once per app launch (skipped with Reduce Motion).
    private func playEntrance() {
        guard !Self.didPlayEntrance, !calmMode else { return }
        Self.didPlayEntrance = true
        cardView.alpha = 0
        cardView.transform = CGAffineTransform(translationX: 0, y: 8)
        UIView.animate(withDuration: 0.45, delay: 0.3, options: [.curveEaseOut, .allowUserInteraction]) {
            self.cardView.alpha = 1
            self.cardView.transform = .identity
        }
    }

    @IBAction func closeTapped(_ sender: UIButton) {
        DashboardAdsService.close(menuId: menuId)
        timer?.invalidate()
        setVisible(false, animated: true)
        onClose?()
    }

    @objc private func pageTapped() {
        scroll(to: pageControl.currentPage)
        restartTimer()
    }

    private func setVisible(_ visible: Bool, animated: Bool) {
        guard isHidden == visible else { return }
        let change = {
            self.isHidden = !visible
            self.alpha = visible ? 1 : 0
            self.superview?.layoutIfNeeded()
        }
        if animated { UIView.animate(withDuration: 0.25, animations: change) } else { change() }
    }

    // Auto-advance every 6 s, only until each ad has been shown once,
    // never with Reduce Motion / VoiceOver, and not while the dashboard is off screen.
    private func restartTimer() {
        timer?.invalidate()
        guard ads.count > 1, autoAdvancesLeft > 0, !calmMode else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            guard self.window != nil, UIApplication.shared.applicationState == .active else { return }
            guard self.autoAdvancesLeft > 0 else { t.invalidate(); return }
            self.autoAdvancesLeft -= 1
            self.scroll(to: (self.pageControl.currentPage + 1) % self.ads.count)
        }
    }

    private func scroll(to index: Int) {
        guard index < ads.count else { return }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        pageControl.currentPage = index
    }

    private func open(_ url: URL) {
        guard let host = hostViewController else { UIApplication.shared.open(url); return }
        host.present(SFSafariViewController(url: url), animated: true)
    }

    internal var hostViewController: UIViewController? {
        var r: UIResponder? = self
        while let n = r?.next { if let vc = n as? UIViewController { return vc }; r = n }
        return nil
    }
}

extension DashboardAdBannerView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { ads.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardAdCell.id, for: indexPath) as! DashboardAdCell
        cell.configure(ads[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = ads[indexPath.item].redirectURL { open(url) }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // The user took over: no more automatic moves this time.
        autoAdvancesLeft = 0
        timer?.invalidate()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = max(scrollView.bounds.width, 1)
        pageControl.currentPage = Int((scrollView.contentOffset.x / width).rounded())
        restartTimer()
    }
}

// MARK: - Reusable: ads on any page with a scroll view
//
// One line in a page's viewDidLoad:
//     showPageAds(menuId: Menu_id.noticeboardMenuId)
// The banner sits above the page's main scroll view content and scrolls with it.
// The page's own XIB and constraints are not changed. Same rules as the dashboard:
// hidden when the API says no, when there are no ads, or for 24 h after the user closes it.

final class AdBannerPlacement {
    private weak var scrollView: UIScrollView?
    let banner = DashboardAdBannerView(frame: .zero)
    private var heightConstraint: NSLayoutConstraint!
    private var addedInset: CGFloat = 0
    private let gap: CGFloat = 8

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.isHidden = true
        scrollView.addSubview(banner)
        heightConstraint = banner.heightAnchor.constraint(equalToConstant: 100)
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            banner.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: -gap),
            heightConstraint
        ])
        banner.onClose = { [weak self] in self?.setSpace(0) }
    }

    func show(_ ads: [DashboardAd]) {
        banner.show(ads)
        setSpace(ads.isEmpty ? 0 : heightConstraint.constant)
    }

    /// Makes room above the page content for the banner (or gives it back).
    private func setSpace(_ height: CGFloat) {
        guard let scroll = scrollView else { return }
        let wanted = height > 0 ? height + gap : 0
        let delta = wanted - addedInset
        guard delta != 0 else { return }
        let wasAtTop = scroll.contentOffset.y <= -scroll.adjustedContentInset.top + 1
        addedInset = wanted
        UIView.animate(withDuration: 0.25) {
            scroll.contentInset.top += delta
            if wasAtTop { scroll.contentOffset.y = -scroll.adjustedContentInset.top }
        }
    }
}

extension UIViewController {
    private static var adPlacementKey: UInt8 = 0

    /// Shows the internal ad banner at the top of this page's main scroll view.
    /// - Parameters:
    ///   - menuId: sent as `menu_id` so the server can pick ads for this page.
    ///   - scrollView: the scroll view to use; by default the first plain UIScrollView on the page.
    ///   - token: staff token by default.
    func showPageAds(menuId: Int,
                     scrollView: UIScrollView? = nil,
                     token: String = UserDefaultFileManager.get_staff_Details()?.access_token ?? "") {
        guard objc_getAssociatedObject(self, &UIViewController.adPlacementKey) == nil,
              let scroll = scrollView ?? view.subviews.first(where: { type(of: $0) == UIScrollView.self }) as? UIScrollView
        else { return }
        let placement = AdBannerPlacement(scrollView: scroll)
        placement.banner.menuId = menuId
        objc_setAssociatedObject(self, &UIViewController.adPlacementKey, placement, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        DashboardAdsService.load(token: token, menuId: menuId) { [weak placement] ads in
            placement?.show(ads)
        }
    }
}
