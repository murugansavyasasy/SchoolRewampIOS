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

    private var lastWidth: CGFloat = 0

    /// The banner can be created before the page knows its final width; when the width
    /// changes, re-size the ad cells so exactly one ad fills the frame (no next ad peeking in).
    override func layoutSubviews() {
        super.layoutSubviews()
        guard contentView != nil, collectionView != nil else { return }
        contentView.layoutIfNeeded()
        let width = collectionView.bounds.width
        guard width > 0, abs(width - lastWidth) > 0.5 else { return }
        lastWidth = width
        collectionView.collectionViewLayout.invalidateLayout()
        let page = pageControl.currentPage
        if page < ads.count {
            collectionView.layoutIfNeeded()
            collectionView.setContentOffset(CGPoint(x: CGFloat(page) * width, y: 0), animated: false)
        }
    }

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
// The banner stays fixed at the top of the page's main list area; the list scrolls underneath it.
// The page's own XIB and constraints are not changed. Same rules as the dashboard:
// hidden when the API says no, when there are no ads, or (per page) after the user closes it.

final class AdBannerPlacement {
    let banner = DashboardAdBannerView(frame: .zero)
    private var heightConstraint: NSLayoutConstraint!
    private let gap: CGFloat = 8

    // Header mode: the banner sits right under the page's header bar and the
    // page content below the header is moved down by the banner's height.
    private var shiftedConstraints: [(NSLayoutConstraint, CGFloat)] = []
    /// Fills the space under the header with the page content's own colour, so the ad
    /// looks like part of the page and not part of the (blue) header / toolbar.
    private let backing = UIView()
    /// The content view under the header (used to find cards that overlap the header by design).
    private weak var contentView: UIView?

    // Scroll mode (fallback): the banner is pinned to the top of a list and
    // the list content starts below it.
    private weak var scrollView: UIScrollView?
    private var topConstraint: NSLayoutConstraint?
    private var addedInset: CGFloat = 0

    /// Under the header bar of `root` (the page's main view). Returns nil when the page
    /// has no header bar with content hanging below it.
    init?(underHeaderOf page: UIView) {
        // The header may sit directly in the page view, or inside one full-screen
        // container view (e.g. parent Homework); look up to 3 levels down.
        guard let found = AdBannerPlacement.findHeader(in: page) else { return nil }
        let (root, header, below) = found
        shiftedConstraints = below.map { ($0, $0.constant) }
        // The content view that sits under the header (e.g. the white list area).
        let content = below.compactMap { c -> UIView? in
            let other = (c.firstItem === header ? c.secondItem : c.firstItem) as? UIView
            return other === header ? nil : other
        }.first
        contentView = content
        backing.translatesAutoresizingMaskIntoConstraints = false
        backing.backgroundColor = AdBannerPlacement.solidColor(of: content) ?? AdBannerPlacement.solidColor(of: root) ?? .systemBackground
        backing.isHidden = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.isHidden = true
        root.insertSubview(backing, belowSubview: header)
        root.insertSubview(banner, aboveSubview: backing)
        heightConstraint = banner.heightAnchor.constraint(equalToConstant: 100)
        NSLayoutConstraint.activate([
            backing.topAnchor.constraint(equalTo: header.bottomAnchor),
            backing.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            backing.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            backing.bottomAnchor.constraint(equalTo: banner.bottomAnchor),
            banner.topAnchor.constraint(equalTo: header.bottomAnchor, constant: gap),
            banner.leadingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor),
            heightConstraint
        ])
        banner.onClose = { [weak self] in self?.setSpace(0) }
    }

    /// Fixed at the top of a list; the list content starts below it.
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.isHidden = true
        banner.backgroundColor = AdBannerPlacement.pageColor(for: scrollView)
        heightConstraint = banner.heightAnchor.constraint(equalToConstant: 100)
        if let host = scrollView.superview {
            host.insertSubview(banner, aboveSubview: scrollView)
            let top = banner.topAnchor.constraint(equalTo: scrollView.topAnchor)
            topConstraint = top
            NSLayoutConstraint.activate([
                top,
                banner.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                banner.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                heightConstraint
            ])
        }
        banner.onClose = { [weak self] in self?.setSpace(0) }
    }

    func show(_ ads: [DashboardAd]) {
        guard banner.superview != nil else { return }
        if let scroll = scrollView { topConstraint?.constant = scroll.adjustedContentInset.top - addedInset }
        banner.show(ads)
        setSpace(ads.isEmpty ? 0 : heightConstraint.constant)
    }

    /// Makes room for the banner (or gives the space back after close / no ads).
    private func setSpace(_ height: CGFloat) {
        let wanted = height > 0 ? height + gap : 0
        if !shiftedConstraints.isEmpty {
            let host = banner.superview
            backing.isHidden = wanted == 0
            // Some pages pull their first card up over the header (negative top, e.g. Attendance).
            // Under the ad that card would cover the ad's bottom, so move it clear as well.
            let overlap = wanted > 0 ? overlapAboveContent() : 0
            let extra = overlap > 0 ? overlap + gap : 0
            UIView.animate(withDuration: 0.25) {
                for (c, original) in self.shiftedConstraints { c.constant = original + wanted + extra }
                host?.layoutIfNeeded()
            }
            return
        }
        guard let scroll = scrollView else { return }
        let delta = wanted - addedInset
        guard delta != 0 else { return }
        let wasAtTop = scroll.contentOffset.y <= -scroll.adjustedContentInset.top + 1
        addedInset = wanted
        UIView.animate(withDuration: 0.25) {
            scroll.contentInset.top += delta
            scroll.verticalScrollIndicatorInsets.top += delta
            if wasAtTop { scroll.contentOffset.y = -scroll.adjustedContentInset.top }
            scroll.superview?.layoutIfNeeded()
        }
    }

    /// Finds the header bar and the constraints that hang page content below it.
    private static func findHeader(in page: UIView) -> (UIView, UIView, [NSLayoutConstraint])? {
        var host = page
        for _ in 0..<3 {
            if let header = header(in: host) {
                let below = host.constraints.filter { c in
                    (c.firstItem === header && c.firstAttribute == .bottom && c.secondAttribute == .top && (c.secondItem as? UIView)?.superview === host) ||
                    (c.secondItem === header && c.secondAttribute == .bottom && c.firstAttribute == .top && (c.firstItem as? UIView)?.superview === host)
                }
                if !below.isEmpty { return (host, header, below) }
            }
            // Step into a single container that fills the whole page.
            let fills = host.subviews.filter {
                !$0.isHidden && !($0 is UIScrollView) &&
                $0.frame.height >= host.bounds.height * 0.8 && $0.frame.width >= host.bounds.width - 1
            }
            guard fills.count == 1 else { return nil }
            host = fills[0]
        }
        return nil
    }

    /// The page's header bar: the app's rounded / wave header, else a top bar that starts at y = 0.
    private static func header(in root: UIView) -> UIView? {
        root.layoutIfNeeded()
        if let h = root.subviews.first(where: { $0 is BottomRoundedView || $0 is HeaderWaveView }), !h.isHidden { return h }
        return root.subviews.first { v in
            !v.isHidden && v.frame.minY <= 1 && v.frame.height > 40 && v.frame.height < root.bounds.height * 0.35
                && v.frame.width >= root.bounds.width - 1
        }
    }

    /// How far the content's own cards stick out above its top edge (0 when none do).
    private func overlapAboveContent() -> CGFloat {
        guard let content = contentView else { return 0 }
        content.superview?.layoutIfNeeded()
        let top = content.subviews.filter { !$0.isHidden && $0.alpha > 0 }.map { $0.frame.minY }.min() ?? 0
        return max(0, -top)
    }

    /// The view's own background colour when it is solid (not clear / see-through).
    private static func solidColor(of view: UIView?) -> UIColor? {
        guard let c = view?.backgroundColor, c.cgColor.alpha > 0.99 else { return nil }
        return c
    }

    private static func pageColor(for scroll: UIScrollView) -> UIColor {
        var v: UIView? = scroll
        while let view = v {
            if let c = view.backgroundColor, c.cgColor.alpha > 0.99 { return c }
            v = view.superview
        }
        return .systemBackground
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
        guard objc_getAssociatedObject(self, &UIViewController.adPlacementKey) == nil else { return }
        let placement: AdBannerPlacement
        if let underHeader = AdBannerPlacement(underHeaderOf: view) {
            placement = underHeader          // usual case: right under the blue header
        } else if let scroll = scrollView ?? view.adsMainScrollView() {
            placement = AdBannerPlacement(scrollView: scroll)
        } else { return }
        placement.banner.menuId = menuId
        objc_setAssociatedObject(self, &UIViewController.adPlacementKey, placement, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        DashboardAdsService.load(token: token, menuId: menuId) { [weak placement] ads in
            placement?.show(ads)
        }
    }
}

// MARK: - Reusable: ads on a menu screen that was just opened (parent side uses this for every menu)

extension UIView {
    /// The main vertical list or scroll area of a screen: the biggest scroll view that scrolls
    /// up and down (horizontal carousels, text views and tiny scroll views are skipped).
    func adsMainScrollView() -> UIScrollView? {
        var best: UIScrollView?
        var bestArea: CGFloat = 0
        func isHorizontalList(_ s: UIScrollView) -> Bool {
            guard let layout = (s as? UICollectionView)?.collectionViewLayout as? UICollectionViewFlowLayout else { return false }
            return layout.scrollDirection == .horizontal
        }
        func visit(_ v: UIView) {
            // Paging scrollers (tab / page containers) are skipped but searched inside.
            if let s = v as? UIScrollView, !(s is UITextView), !s.isHidden, !s.isPagingEnabled,
               s.bounds.height >= 200, !isHorizontalList(s) {
                let area = s.bounds.width * s.bounds.height
                if area > bestArea { best = s; bestArea = area }
                return   // don't look inside the scroll view's own cells
            }
            v.subviews.forEach(visit)
        }
        visit(self)
        return best
    }
}

extension UIViewController {
    /// Call right after presenting a menu screen. When the screen is on screen,
    /// the ad banner is placed above its main list (if it has one).
    func showAdsOnOpenedMenu(menuId: Int, token: String) {
        guard let opened = presentedViewController else { return }
        let target = (opened as? UINavigationController)?.visibleViewController ?? opened
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak target] in
            guard let screen = target, screen.viewIfLoaded?.window != nil else { return }
            screen.showPageAds(menuId: menuId, token: token)
        }
    }
}

// MARK: - Staff menus that show the ad banner

enum StaffAdMenus {
    /// Mark attendance, Lesson plan, Quiz, PTM (26 and 5), Daily collection, Fee pending,
    /// Punch attendance (geo), Approve student leave, Upload exam marks.
    static let ids: Set<Int> = [
        Menu_id.attendance, Menu_id.LessonPlan, Menu_id.quiz, Menu_id.ptm, 5,
        Menu_id.dailyCollection, Menu_id.feependingreport, Menu_id.geoMatricAttendace,
        Menu_id.leaveReq, Menu_id.Upload_Marks
    ]

    /// Call right after a staff menu screen was presented from `presenter`.
    static func showIfNeeded(menuId: Int, from presenter: UIViewController) {
        guard ids.contains(menuId) else { return }
        // Not on the school picker: the ad goes on the menu screen opened after it.
        if presenter.presentedViewController is SchoolListVC { return }
        presenter.showAdsOnOpenedMenu(menuId: menuId,
                                      token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "")
    }
}
