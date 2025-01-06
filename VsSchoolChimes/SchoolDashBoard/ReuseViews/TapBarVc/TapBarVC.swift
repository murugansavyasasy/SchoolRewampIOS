//
//  TapBarVC.swift
//  VsSchoolChimes
//
//  Created by admin on 30/10/24.
//

import UIKit

@available(iOS 14.0, *)
class TapBarVC: UIViewController,UITabBarDelegate, BaktoHome {
    func backtohome() {
        setupTabBar()
        setupContainerView()
        if passedValue == 1{
            
            firstVC.getValue = passedValue
            selectViewController(firstVC)
            
        }else if passedValue == 2{
            Parent.getValue = passedValue
            selectViewController(Parent)
        }
    }
    
    
    
    private let tabBar = UITabBar()
    private var containerView = UIView()
    private lazy var firstVC = HomePageVc()
    private lazy var Parent = ParentVC()
    private lazy var secondVC = HelpVc()
    private lazy var thirdVC = SettingsViewController()
    private lazy var fourthVC = ProfileViewController()
    var languages : String!
    var passedValue : Int!
    var languageCode : String!
    var profile:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupTabBar()
        setupContainerView()
    }
    
    private func setupTabBar() {
        
        // Configure the tab bar items
        let firstItem = UITabBarItem(title: StringsName.Home.translated(), image: UIImage(systemName: "house.fill"), tag: 0)
        let secondItem = UITabBarItem(title: StringsName.Help.translated(), image: UIImage(systemName: "questionmark.circle.fill"), tag: 1)
        let thirdItem = UITabBarItem(title : StringsName.Settings.translated(), image: UIImage(systemName: "gearshape.fill"), tag: 2)
        let fourthItem = UITabBarItem(title: StringsName.Profile.translated(), image: UIImage(systemName: "person.crop.circle"), tag: 3)
        // Create the gradient color for tab bar
     
        tabBar.tintColor = .purple
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if passedValue == 2{
            Parent.getValue = passedValue
            selectViewController(Parent)
            
            let width = UIScreen.main.bounds.width
            let gradientColor = createGradientColor(
                colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                size: CGSize(width: width, height: 400),
                startPoint: CGPoint(x: 1, y: 0.5), // Start from the right
                endPoint: CGPoint(x: 0, y: 0.5)    // End at the left
            )
            tabBar.backgroundImage = gradientColor
        }else if passedValue == 1{
            firstVC.getValue = passedValue
            selectViewController(firstVC)
            let width = UIScreen.main.bounds.width
            let gradientColor = createGradientColor(
                colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
              
                size: CGSize(width: width, height: 400),
                startPoint: CGPoint(x: 1, y: 0.5), // Start from the right
                endPoint: CGPoint(x: 0, y: 0.5)    // End at the left
            )
            tabBar.backgroundImage = gradientColor
        }
        tabBar.tintColor = .white
    }
    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: view.topAnchor),
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
//        ])
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor) // Correct alignment
        ])

    }
    
    private func selectViewController(_ viewController: UIViewController) {
        // Remove all existing child view controllers
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        // Ensure `hidesBottomBarWhenPushed` is false
        viewController.hidesBottomBarWhenPushed = false

        // Apply gradient if necessary
        if let settingsVC = viewController as? SettingsViewController, passedValue == 2 {
            settingsVC.delegate = self
            settingsVC.passVale = passedValue
            
        } else if let profileVC = viewController as? ProfileViewController, passedValue == 2 {
            profileVC.passvalue = passedValue
//
        }else if let profileVC = viewController as? ParentVC, passedValue == 2 {
            profileVC.getValue = passedValue
            
        }else if let HelpVc = viewController as? HelpVc, passedValue == 2 {
            HelpVc.passVale = passedValue
            
        }

        // Add the new child view controller
        addChild(viewController)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
//
//    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        switch item.tag {
//        case 0:
//            if passedValue == 1 {
//                selectViewController(firstVC)
//                firstVC.bottomCv.reloadData()
//            } else if passedValue == 2 {
//                selectViewController(Parent)
//                Parent.bottomCv.reloadData()
//            }
//        case 1:
//            selectViewController(secondVC)
//        case 2:
//            selectViewController(thirdVC)
//        case 3:
//            selectViewController(fourthVC)
//        default:
//            break
//        }
//    }


    
//    private func selectViewController(_ viewController: UIViewController) {
//        
//        for child in children {
//            child.willMove(toParent: nil)
//            child.view.removeFromSuperview()
//            child.removeFromParent()
//        }
//        if let pageVC = viewController as? SettingsViewController {
//            pageVC.delegate = self
//           if passedValue == 2{
//               pageVC.view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//            }
//        }else if let pageVC = viewController as? ProfileViewController {
//            if passedValue == 2{
//                pageVC.view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//                pageVC.fullview.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
////                tabBar.tintColor = .red
//             }
//        }
//        // Add new child view controller
//        addChild(viewController)
//        viewController.view.frame = containerView.bounds
//        containerView.addSubview(viewController.view)
//        viewController.didMove(toParent: self)
//        }
    
    // Handle tab bar item selection with animation
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag {
        case 0:
            if passedValue == 1{
                selectViewController(firstVC)
                firstVC.bottomCv.reloadData()
                
            }else if passedValue == 2{
                
                selectViewController(Parent)
                Parent.bottomCv.reloadData()
            }
            
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
    
    
    func createGradientColor(colors: [UIColor], size: CGSize, startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) -> UIImage? {
        // Adjust the alpha of the colors to make them less opaque
        let adjustedColors = colors.map { color -> UIColor in
            let alpa = profile ? 0:0.7
            return color.withAlphaComponent(0.7) // Reduce alpha to 70% (you can change this value)
        }
        
        // Create a gradient layer with adjusted colors
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = adjustedColors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        
        // Render the gradient to a UIImage
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        gradientLayer.render(in: context)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gradientImage
    }

    
}
extension UIColor {
    // Convert hex string to UIColor
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
