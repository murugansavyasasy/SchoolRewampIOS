//
//  EventPageVC.swift
//  VsSchoolChimes
//
//  Created by admin on 04/12/24.
//

import UIKit

protocol HistorySelectDelegate {
    func select(Title: String, Description: String, Images: [UIImage], pdf: String)
}

@available(iOS 14.0, *)
class EventPageVC: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, HistorySelectDelegate, EditObjectDelegate {
    
    func editDta(edit: Any) {
        if pages.count > 0, let senderVC = pages[0] as? SenderNoticeBoardVC{
            senderVC.fetchData(notice: edit as? Notice)
        }
        if pages.count > 0, let senderVC = pages[0] as? EventsVC{
            senderVC.fetchData(eventList: edit as? EventList)
        }
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 1
        let direction: UIPageViewController.NavigationDirection = 0 > currentIndex ? .reverse : .forward
        updateTabUI(for: 0)
        pageViewController.setViewControllers([pages[0]], direction: direction, animated: true, completion: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var reportsBtn: UIButton!
    @IBOutlet weak var reportsLb: UILabel!
    @IBOutlet weak var createLbl: UILabel!
    @IBOutlet weak var presentView: UIView!
    @IBOutlet weak var searcchBtn: UIButton!
    // MARK: - Variables
    var pageViewController: UIPageViewController!
    var pages: [UIViewController] = []
    var page1 = UIViewController()
    var page2 = UIViewController()
    var titleLbl = ""
    var button1 = "Create".translated()
    var button2 = "History".translated()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = language == "ar" ? .forceRightToLeft : .forceLeftToRight
        BackBtn.contentHorizontalAlignment = language == "ar" ? .right : .left
        BackBtn.imageView?.applyRTLFlip(language == "ar")
        
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
        if titleLbl == CommonStringFile.CreateEvent {
            BackBtn.configureAsBackButton(firstLine: titleLbl, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        } else {
            BackBtn.setTitle(titleLbl, for: .normal)
            BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        }
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
    
    func loadPages(_ CV: [UIViewController]) {
        pages = CV
        if let historyVC = pages[1] as? NoticeBoardVc {
            historyVC.delegate = self
        }
        if let historyVC = pages[1] as? EventHistoryVC {
            historyVC.delegate = self
        }
    }
    
    //    func disableSwipeGesture() {
    //        for view in pageViewController.view.subviews {
    //            if let gesture = view.gestureRecognizers {
    //                for recognizer in gesture {
    //                    view.removeGestureRecognizer(recognizer)
    //                }
    //            }
    //        }
    //    }
    
    // MARK: - Navigation Actions
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        if pages.indices.contains(1), let senderVC = pages[1] as? NoticeBoardVc {
            senderVC.searchHide(hide: sender.isSelected)
        }
    }
    @IBAction func switchController(_ sender: UIButton) {
        let selectedIndex = sender.tag
        guard selectedIndex >= 0 && selectedIndex < pages.count else {
            print("Index out of bounds")
            return
        }
        
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = selectedIndex > currentIndex ? .forward : .reverse
        
        updateTabUI(for: selectedIndex)
        
        pageViewController.setViewControllers([pages[selectedIndex]], direction: direction, animated: true, completion: nil)
    }
    func updateTabUI(for index: Int) {
        UIView.animate(withDuration: 0.25) {
            self.searcchBtn.isHidden = index == 0
            self.createLbl.backgroundColor = index == 0 ? .blue : .white
            self.reportsLb.backgroundColor = index == 0 ? .white : .blue
            self.reportsBtn.tintColor = index == 0 ? .black : .blue
            self.createBtn.tintColor = index == 1 ? .black : .blue
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else {
            return
        }
        
        updateTabUI(for: currentIndex)
    }
    
    
    
    // MARK: - PageViewController Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }
    
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
    
    // MARK: - HistorySelectDelegate
    func select(Title: String, Description: String, Images: [UIImage], pdf: String) {
        guard pages.count > 0, let senderVC = pages[0] as? SenderNoticeBoardVC else { return }
        
        //        senderVC.Title = Title
        //        senderVC.desript = Description
        //        senderVC.selectedImages = Images
        //        senderVC.pdfPath = pdf
        //
        //        // Switch to Create Page
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 1
        let direction: UIPageViewController.NavigationDirection = 0 > currentIndex ? .reverse : .forward
        
        pageViewController.setViewControllers([pages[0]], direction: direction, animated: true, completion: nil)
    }
    
    // Optional utility
    func selectVC(index: Int) {
        guard index >= 0 && index < pages.count else { return }
        let currentIndex = pageViewController.viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }
}
