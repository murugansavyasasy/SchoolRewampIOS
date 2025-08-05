//
//  AttachCommonPage.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 04/08/25.
//

import UIKit

class AttachCommonPage: UIViewController,UIPageViewControllerDelegate, UIPageViewControllerDataSource, SelectNotice {
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var reportsBtn: UIButton!
    @IBOutlet weak var reportsLb: UILabel!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var presentView: UIView!

    var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    var page1 = UIViewController()
    var page2 = UIViewController()
    var titleLbl = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft : .forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right : .left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")

        uiConficration()
        setupPageViewController()
        loadPages([page1, page2])
//        disableSwipeGesture()

        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }

    func uiConficration() {
//        BackBtn.setTitle(titleLbl, for: .normal)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self

        addChild(pageViewController)
        presentView.addSubview(pageViewController.view)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: presentView.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: presentView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: presentView.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: presentView.bottomAnchor)
        ])

        pageViewController.didMove(toParent: self)
    }

    
    func gradientcolours(button: UIButton, colours: [CGColor]) {
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.layer.cornerRadius

        button.layer.insertSublayer(gradientLayer, at: 0)
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }

//    @IBAction func switchController(_ sender: UIButton) {
    @IBAction func segment(_ sender: UIButton) {
        
        let index = sender.tag
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }
        updateTabUI(for: index)
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }

    
    func updateTabUI(for index: Int) {
        UIView.animate(withDuration: 0.25) {
//            self.searcchBtn.isHidden = index == 0
            self.createLbl.backgroundColor = index == 0 ? .blue : .white
            self.reportsLb.backgroundColor = index == 0 ? .white : .blue
            self.reportsBtn.tintColor = index == 0 ? .black : .blue
            self.createBtn.tintColor = index == 1 ? .black : .blue
        }
    }
    func loadPages(_ CV: [UIViewController]) {
        if #available(iOS 14.0, *) {
            if let page2 = CV[1] as? AttachHistroyVC {
                page2.selectNotice = self
            }
        }
            pages = CV
    }

    func SelectedVC(index: Int) {
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }

        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }

    // MARK: - UIPageViewController Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }

//    private func disableSwipeGesture() {
//        for view in pageViewController.view.subviews {
//            if let scrollView = view as? UIScrollView {
//                scrollView.isScrollEnabled = false
//            }
//        }
//    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else {
            return 0
        }
        return currentIndex
 
    }
    func didTapButton(
        title: String,
        content: String,
        items: [FilePath],
        editId editID:String
    ) {
        if #available(iOS 14.0, *) {
            if let page1 = pages.first as? SenderAttachmentVC{
//                segmentController.selectedSegmentIndex = 0
                
                createBtn.setTitle("Update", for: .normal)
                updateTabUI(for: 0)
                
               
                page1
                    .setSelectedHomeWork(
                        title: title,
                        content: content,
                        imageUrls: items,
                        editId: editID
                    )
                let currentIndex =  pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
                let direction: UIPageViewController.NavigationDirection = 0 > currentIndex ? .forward : .reverse
                pageViewController.setViewControllers([page1], direction: direction, animated: true, completion: nil)
            }
        }
    }
    
    
}

