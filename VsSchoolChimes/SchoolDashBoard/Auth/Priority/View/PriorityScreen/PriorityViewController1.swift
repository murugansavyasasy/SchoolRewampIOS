    //
    //  PriorityViewController1.swift
    //  SchoolchimesDemo
    //
    //  Created by Admin on 28/10/24.
    //

    import UIKit

    @available(iOS 14.0, *)
    class PriorityViewController1: UIViewController {

    @IBOutlet weak var TeacherParentlbl: UILabel!
    @IBOutlet weak var ChooseRoleLabel: UILabel!

    @IBOutlet weak var NextButtonView: UIButton!

    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var priorityview: UIView!

    @IBOutlet weak var teacherButton: UIButton!

    @IBOutlet weak var ParentButton: UIButton!

    var selectedIndexPath : IndexPath!

    let assetColors: [String] = ["Priority", "priortitClr1", "PriorityClr2"]
    let gradientcolour : [String] = ["gradient1", "gradient2", "gradient3"]
    var passedValue = 1
    override func viewDidLoad() {
    super.viewDidLoad()

    UserDefaults.standard.set(passedValue, forKey: "passvalue")

    NextButtonView.isHidden = true
    NextButtonView.layer.cornerRadius = 18

    priorityview.layer.cornerRadius = 20
    teacherButton.layer.cornerRadius = 20
    ParentButton.layer.cornerRadius = 20

    TeacherParentlbl.setFont(style: .body, size: FontSize.BodySize)
    ChooseRoleLabel.setFont(style: .title, size: FontSize.TitleSize)
    NextButtonView.setTitleFont(style: .body, size: FontSize.BodySize)
    TeacherParentlbl.setFont(style: .body, size: FontSize.BodySize)
    ChooseRoleLabel.setFont(style: .title, size: FontSize.TitleSize)

    ParentButton.setTitle("Parent", for: .normal)
    teacherButton.setTitle("Principal", for: .normal)
    ParentButton.setTitleColor(.black, for:.normal)

    DispatchQueue.main.async {
    self.teacherButton.setTitleFont(style: .body, size: FontSize.BodySize)
    self.ParentButton.setTitleFont(style: .body, size: FontSize.BodySize)
    }

    gradientcolours(button: NextButtonView, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])

    gradientcolours(button: teacherButton,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
    teacherButton.tintColor = .white




    let nib = UINib(nibName: CellConfingName.DemoTVCell, bundle: nil)
    tableview.register(nib, forCellReuseIdentifier: CellConfingName.DemoTVCell)

    let nib1 = UINib(nibName: CellConfingName.principalTVCell, bundle: nil)
    tableview.register(nib1, forCellReuseIdentifier: CellConfingName.principalTVCell)


    tableview.delegate = self
    tableview.dataSource = self
    tableview.reloadData()
    }


    @IBAction func teacherAct(_ sender: Any) {
    gradientcolours(button: teacherButton,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])


    teacherButton.setTitleColor(.white, for:.normal)


    gradientcolours(button: ParentButton,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
    ParentButton.setTitleColor(.black, for:.normal)


    passedValue = 1
    UserDefaults.standard.set(passedValue, forKey: "passvalue")
    tableview.delegate = self
    tableview.dataSource = self
    tableview.reloadData()

    }


    @IBAction func ParentAct(_ sender: Any) {

    gradientcolours(button: ParentButton,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])

    ParentButton.setTitleColor(.white, for:.normal)

    teacherButton.backgroundColor = .clear


    gradientcolours(button: teacherButton,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])

    teacherButton.setTitleColor(.black, for:.normal)


    passedValue = 2
    UserDefaults.standard.set(passedValue, forKey: "passvalue")
    tableview.delegate = self
    tableview.dataSource = self
    tableview.reloadData()
    }


    func gradientcolours(button : UIButton,colours : [CGColor]){


    button.layer.sublayers?.removeAll { $0 is CAGradientLayer }

    // Create and configure the gradient layer
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = colours
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
    gradientLayer.frame = button.bounds
    gradientLayer.cornerRadius = button.layer.cornerRadius

    // Insert the gradient layer into the button's layer
    button.layer.insertSublayer(gradientLayer, at: 0)

    }

    @IBAction func NextAction(_ sender: Any) {

    if selectedIndexPath != nil{

    let vc = TapBarVC(nibName: nil, bundle: nil)
    vc.modalPresentationStyle = .fullScreen
    vc.passedValue = passedValue
    present(vc, animated: true)
    }
    }

    }

    @available(iOS 14.0, *)
    extension PriorityViewController1: UITableViewDelegate, UITableViewDataSource {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    if passedValue == 1 {
            
        return 0
    }else{
        
        return 10
        
    }
        
   
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let colorName = assetColors[indexPath.row % assetColors.count]
    let colour1 = UIColor(named: colorName)
    let gradient = gradientcolour[indexPath.row % gradientcolour.count]
    let colour2 =  UIColor(named: gradient)

    if passedValue  == 2 {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.DemoTVCell, for: indexPath) as! DemoTVCell

    if let color1 = colour1, let color2 = colour2 {
    cell.setGradientColors([color2.cgColor, color1.cgColor])
    }
    cell.SchoolInfoView.backgroundColor = colour1

    return cell

    } else {

    let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.principalTVCell, for: indexPath) as! principalTVCell


    if let color1 = colour1, let color2 = colour2 {
    cell.setGradientColors([color2.cgColor, color1.cgColor])
    }

    cell.checkbox.isUserInteractionEnabled = false
    cell.checkbox.isChecked = (indexPath == selectedIndexPath)


    return cell

    }
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    NextButtonView.isHidden = false
    // Update the selection when a row is tapped
    updateSelection(for: indexPath, in: tableView)
    }

    private func updateSelection(for indexPath: IndexPath, in tableView: UITableView) {
    // Check if the row was already selected
    if selectedIndexPath == indexPath {

    selectedIndexPath = nil // Deselect
    NextButtonView.isHidden = true

    } else {

    selectedIndexPath = indexPath // Select the new row
    }

    // Reload data to update the checkboxes
    tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    // Ensure checkbox is deselected if the row is deselected
    if let cell = tableView.cellForRow(at: indexPath) as? principalTVCell {

    cell.checkbox.isChecked = false

    }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
    }

    }






