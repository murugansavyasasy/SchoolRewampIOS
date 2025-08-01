// CustomDashboard.swift
// School Chimes

import UIKit

class CustomDasboard: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var headerView: HeaderWaveView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!

    @IBOutlet weak var pagecontroller: UIPageControl!
    @IBOutlet weak var recentActiveMenuCollection: UICollectionView!
    @IBOutlet weak var MenuCollection: UICollectionView!

    // MARK: - Sample Data
    var recentMenuItems: [DashboardMenu] = [
        DashboardMenu(icon:"ic_homework", title: "Daily Homework", subtitle: ""),
        DashboardMenu(icon:"ic_fee", title: "Fee Payment", subtitle: "")
    ]

    var menuItems: [DashboardMenu] = [
        DashboardMenu(icon: "ic_feed", title: "Your Feed", subtitle: "Lorem ipsum dolor sit amet."),
        DashboardMenu(icon:"ic_attendance", title: "Attendance", subtitle: "Lorem ipsum dolor sit amet."),
        DashboardMenu(icon: "ic_assessment", title: "Assessments", subtitle: "Lorem ipsum dolor sit amet."),
        DashboardMenu(icon: "ic_message", title: "Messages", subtitle: "Lorem ipsum dolor sit amet."),
        DashboardMenu(icon:"ic_calendar", title: "School Calendar", subtitle: "Lorem ipsum dolor sit amet."),
        DashboardMenu(icon:"ic_staff", title: "Staff Information", subtitle: "Lorem ipsum dolor sit amet.")
    ]
    var menu_details: [MenuDetail]?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cells
        recentActiveMenuCollection.register(UINib(nibName: "TopCVCell", bundle: nil), forCellWithReuseIdentifier: "TopCVCell")
        MenuCollection.register(UINib(nibName: "CustomMenuCVC", bundle: nil), forCellWithReuseIdentifier: "CustomMenuCVC")
        pagecontroller.numberOfPages = recentMenuItems.count
        // Delegates and DataSources
        recentActiveMenuCollection.delegate = self
        recentActiveMenuCollection.dataSource = self
        MenuCollection.delegate = self
        MenuCollection.dataSource = self

        setupHeaderView()
        setupLabels()
        setupProfileImage()
        get_dashboard_details()
    }
 
    func get_dashboard_details() {
        APIService.shared.makeApi(
            url: ServiceUrl.get_dashboard_details,
            parameters: ["member_type": "staff"],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<DashboardResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("Dashboard Response:", response)
                
                DispatchQueue.main.async {
                    if response.status == true, let details = response.data?.first?.menu_details {
                        self.menu_details = details
                        self.MenuCollection.reloadData()
                    } else {
                        
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error:", error.localizedDescription)
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        headerView.startWaveAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        headerView.stopWaveAnimation()
    }

    private func setupHeaderView() {
        headerView.setNeedsDisplay()
    }

    private func setupLabels() {
        welcomeLabel.text = "Welcome back"
        welcomeLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        welcomeLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        nameLabel.text = "Madhuri Sharma"
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }

    private func setupProfileImage() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    }

    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recentActiveMenuCollection {
            return recentMenuItems.count
        } else {
            return menu_details?.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recentActiveMenuCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCVCell", for: indexPath) as! TopCVCell
            let item = recentMenuItems[indexPath.item]
            cell.configure(with: item)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomMenuCVC", for: indexPath) as! CustomMenuCVC
            let item = menu_details?[indexPath.item]
            if let name = item?.id {
                if #available(iOS 14.0, *) {
                    let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == name }
                    let img = UIImage(named: filteredItems.first?.name ?? "")
                    cell.iconBtn.setImage(img, for: .normal)
                    cell.imenuName.text = item?.name
                    cell.menuCondent.text = "Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet."
                }
            }
            return cell
        }
    }
}
extension CustomDasboard: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == recentActiveMenuCollection {
            return CGSize(width: 200, height: 90) // Horizontal scroll items
        } else {
            return CGSize(width: (collectionView.frame.width - 25) / 2, height: 100)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

// MARK: - HeaderWaveView
class HeaderWaveView: UIView {

    private var waveOffset: CGFloat = 0
    private var displayLink: CADisplayLink?
    private let waveSpeed: CGFloat = 0.2
    private let waveHeight: CGFloat = 15
    private let baseYOffset: CGFloat = 20

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        clipsToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    deinit {
        stopWaveAnimation()
    }

    func startWaveAnimation() {
        guard displayLink == nil else { return }

        displayLink = CADisplayLink(target: self, selector: #selector(updateWave))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .current, forMode: .default)
    }

    func stopWaveAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateWave() {
        waveOffset += waveSpeed
        let cycleWidth = bounds.width * 2
        if waveOffset > cycleWidth {
            waveOffset = 0
        }
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)

        drawGradientBackground(in: context, rect: rect)
        drawAnimatedWaves(in: context, rect: rect)
    }

    private func drawGradientBackground(in context: CGContext, rect: CGRect) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // Updated colors to match the exact design
        let topColor = UIColor(red: 0.31, green: 0.58, blue: 0.98, alpha: 1.0).cgColor // Brighter blue
        let middleColor = UIColor(red: 0.24, green: 0.51, blue: 0.93, alpha: 1.0).cgColor // Mid blue
        let bottomColor = UIColor(red: 0.18, green: 0.42, blue: 0.85, alpha: 1.0).cgColor // Deeper blue
        let colors = [topColor, middleColor, bottomColor] as CFArray

        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 0.5, 1.0]) else { return }

        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: bounds.height),
                                   options: [])
    }

    private func drawAnimatedWaves(in context: CGContext, rect: CGRect) {
        let width = bounds.width
        let height = bounds.height
        let baseY = height - waveHeight - baseYOffset

        // First wave (back layer) - more transparent
        drawWave(in: context,
                 width: width,
                 height: height,
                 baseY: baseY - 10,
                 frequency: 1.8,
                 amplitude: waveHeight * 0.6,
                 phase: waveOffset * 0.018,
                 color: UIColor.white.withAlphaComponent(0.4),
                 stepSize: 2.0)

        // Second wave (middle layer)
        drawWave(in: context,
                 width: width,
                 height: height,
                 baseY: baseY - 10,
                 frequency: 2.2,
                 amplitude: waveHeight * 0.7,
                 phase: waveOffset * 0.022,
                 color: UIColor.white.withAlphaComponent(0.6),
                 stepSize: 1.5)

        // Third wave (front layer) - most opaque
        drawWave(in: context,
                 width: width,
                 height: height,
                 baseY: baseY,
                 frequency: 2.5,
                 amplitude: waveHeight * 0.8,
                 phase: waveOffset * 0.025,
                 color: UIColor.white.withAlphaComponent(0.9),
                 stepSize: 1.0)
    }

    private func drawWave(in context: CGContext,
                          width: CGFloat,
                          height: CGFloat,
                          baseY: CGFloat,
                          frequency: CGFloat,
                          amplitude: CGFloat,
                          phase: CGFloat,
                          color: UIColor,
                          stepSize: CGFloat) {

        let wavePath = UIBezierPath()
        
        // Start from bottom left
        wavePath.move(to: CGPoint(x: 0, y: height))
        
        // Draw to the start of the wave
        wavePath.addLine(to: CGPoint(x: 0, y: baseY))

        // Create the wave
        var x: CGFloat = 0
        while x <= width {
            let relativeX = x / width
            let sine = sin((relativeX * frequency * 2 * .pi) + phase)
            let y = baseY + sine * amplitude
            wavePath.addLine(to: CGPoint(x: x, y: y))
            x += stepSize
        }

        // Complete the path
        wavePath.addLine(to: CGPoint(x: width, y: height))
        wavePath.close()

        context.saveGState()
        color.setFill()
        wavePath.fill()
        context.restoreGState()
    }
}
struct DashboardMenu {
    let icon: String
    let title: String
    let subtitle: String
}
