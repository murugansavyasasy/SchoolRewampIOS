//
//  TapBarVC.swift
//  VsSchoolChimes
//
//  Created by admin on 30/10/24.
//

import UIKit

@available(iOS 14.0, *)
class TapBarVC: UIViewController,UITabBarDelegate {
    
    
    private let tabBar = UITabBar()
       private var containerView = UIView()

       // Create instances of your view controllers
       private lazy var firstVC = HomePageVc()
       private lazy var secondVC = HelpVc()
       private lazy var thirdVC = SettingsViewController()
    private lazy var fourthVC = ProfileViewController()

       override func viewDidLoad() {
           super.viewDidLoad()
           setupTabBar()
           setupContainerView()

           // Set the initial view controller
           selectViewController(firstVC)
       }

       private func setupTabBar() {
           // Configure the tab bar items
           let firstItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
           
           let secondItem = UITabBarItem(title: "Help", image: UIImage(systemName: "questionmark.circle.fill"), tag: 1)
           let thirdItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 2)
           let fourthItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 3)

           tabBar.backgroundColor = Colornames.bottomClr
           
           
           
           tabBar.items = [firstItem, secondItem, thirdItem, fourthItem]
           tabBar.delegate = self
           tabBar.selectedItem = firstItem
           view.addSubview(tabBar)

           // Set text attributes for all states
           let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
           UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
           UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .selected)

           // Layout the tab bar
           tabBar.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
               tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor
           )])
       }

       private func setupContainerView() {
           containerView.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(containerView)

           NSLayoutConstraint.activate([
               containerView.topAnchor.constraint(equalTo: view.topAnchor),
               containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
           ])
       }

       private func selectViewController(_ viewController: UIViewController) {
           // Remove previous child view controller
           children.forEach { $0.removeFromParent() }

           // Add new child view controller
           addChild(viewController)
           viewController.view.frame = containerView.bounds
           containerView.addSubview(viewController.view)
           viewController.didMove(toParent: self)
       }

       // Handle tab bar item selection with animation
       func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
          
           styleTabItem(at: item.tag)
           
           
           switch item.tag {
           case 0:
               selectViewController(firstVC)
           case 1:
               selectViewController(secondVC)
           case 2:
               selectViewController(thirdVC)
           case 3:
               selectViewController(fourthVC)
           default:
               break
           }
       }
  

    private func styleTabItem(at selectedIndex: Int) {
            // Reset all tab bar item image views first
        
        print("styleTabItem1")
            for (index, item) in (tabBar.items ?? []).enumerated() {
                print("styleTabItem2")
                if let imageView = tabBar.subviews.compactMap({ $0 as? UIControl }).first(where: { $0.tag == item.tag })?.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                    // Reset unselected tabs
                    
                    print("styleTabItem44")
//                    imageView.layer.cornerRadius = 0
//                    imageView.clipsToBounds = false
//                    imageView.tintColor = .green
                    
                    imageView.layer.cornerRadius = 10
                    imageView.clipsToBounds = true
                    imageView.tintColor = .yellow
                }
            }

            // Apply corner radius and tint color to the selected tab's image
            if let selectedImageView = tabBar.subviews.compactMap({ $0 as? UIControl }).first(where: { $0.tag == selectedIndex })?.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                selectedImageView.layer.cornerRadius = 10
                selectedImageView.clipsToBounds = true
                selectedImageView.tintColor = .yellow
                print("styleTabItem3")
            }
        }
               
               }
