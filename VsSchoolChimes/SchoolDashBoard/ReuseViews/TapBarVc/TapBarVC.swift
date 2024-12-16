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
private lazy var firstVC = HomePageVc()
private lazy var Parent = ParentVC()
private lazy var secondVC = HelpVc()
private lazy var thirdVC = SettingsViewController()
private lazy var fourthVC = ProfileViewController()
var languages : String!
var passedValue : Int!
override func viewDidLoad() {
super.viewDidLoad()


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

private func setupTabBar() {

// Configure the tab bar items
let firstItem = UITabBarItem(title: StringsName.Home, image: UIImage(systemName: "house.fill"), tag: 0)
let secondItem = UITabBarItem(title: StringsName.Help, image: UIImage(systemName: "questionmark.circle.fill"), tag: 1)
let thirdItem = UITabBarItem(title : StringsName.Settings, image: UIImage(systemName: "gearshape.fill"), tag: 2)
let fourthItem = UITabBarItem(title: StringsName.Profile, image: UIImage(systemName: "person.crop.circle"), tag: 3)


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

for child in children {
child.willMove(toParent: nil)
child.view.removeFromSuperview()
child.removeFromParent()
}

// Add new child view controller
addChild(viewController)
viewController.view.frame = containerView.bounds
containerView.addSubview(viewController.view)
viewController.didMove(toParent: self)
}

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

}

