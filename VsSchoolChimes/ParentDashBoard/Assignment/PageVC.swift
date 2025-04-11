//
//  PageVC.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit

protocol DidSelectDelegate: AnyObject { // Use `AnyObject` for class-only conformance
    func select(index: Int, value: String?,Img:[String],Pdf:String?,text:String?,type:String)
}

class PageVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, DidSelectDelegate{
    func backtohome() {
        guard 0 >= 0 && 0 < pages.count else {
            print("Index out of bounds")
            return
        }
        let currentIndex = viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = 0 > currentIndex ? .forward : .reverse

        // Using UIView.animate to adjust the duration of the transition
        UIView.animate(withDuration: 2.5, animations: {
            // Set the target view controller with the desired animation
            self.setViewControllers([self.pages[0]], direction: direction, animated: true, completion: nil)
        })
    }
    

    var pages: [UIViewController] = []
    
    let imgs: [String] = [ "https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/20-11-2024/File_vc_-7402800388508860765.png", "https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/20-11-2024/File_vc_-7402800388492478013.png", "https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/20-11-2024/File_vc_-7402800388509938245.png","https://s3.ap-south-1.amazonaws.com/schoolchimes-files-india/20-11-2024/File_vc_-7402800388496770445.png"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate and data source
        self.delegate = self
        self.dataSource = self

        // Load pages
        loadPages()

        // Set the initial page
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        for view in self.view.subviews {
               if let scrollView = view as? UIScrollView {
                   scrollView.isUserInteractionEnabled = false
               }
           }
        
        for gesture in self.gestureRecognizers {
            gesture.isEnabled = false
        }
    }

    func loadPages() {
        // Initialize view controllers from nibs
        let page1 = AssignmentListVC(nibName: "AssignmentListVC", bundle: nil)
        page1.didSelectDelegate = self // Assign delegate

        let page2 = ImageShowVc(nibName: nil, bundle: nil)
        page2.delegate = self

        // Add pages to the array
        pages = [page1, page2]
    }

    // MARK: - DidSelectDelegate Method
    
    func select(index: Int, value: String?,Img:[String],Pdf:String?,text:String?,type:String) {
        // Ensure the index is within bounds
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }

        // Check if the target view controller can accept the value
        if let value = value,
           let targetVC = pages[index] as? ImageShowVc {
            targetVC.pageName = "Assigment"
//            targetVC.imageURL = imgs
            targetVC.type = Int(value) ?? 0
        }
        // Determine navigation direction based on current index
        let currentIndex = viewControllers?.first.flatMap { pages.firstIndex(of: $0) } ?? 0
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        // Using UIView.animate to adjust the duration of the transition
        UIView.animate(withDuration: 2.5, animations: {
            // Set the target view controller with the desired animation
            self.setViewControllers([self.pages[index]], direction: direction, animated: true, completion: nil)
        })
    }


    // MARK: - UIPageViewController Data Source Methods

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else {
            return nil
        }
        return pages[currentIndex + 1]
    }

    // Optional: Page Indicator
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let currentVC = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else {
            return 0
        }
        return currentIndex
    }
}
