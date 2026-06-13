import UIKit

class RouteHeaderCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var locationPinbackgroundview: UIView!
    @IBOutlet weak var studentLocationfullView: UIView!
    @IBOutlet weak var findMyDropBusBtnName: UIButton!
    @IBOutlet weak var findMypickBusBtnname: UIButton!
    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var topIconContainer: UIView!
    // Header Outlets
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var stopSubtitleLabel: UILabel!
    @IBOutlet weak var pickupTimeLabel: UILabel!
    @IBOutlet weak var dropTimeLabel: UILabel!
    @IBOutlet weak var busNumberValueLabel: UILabel!
    // Pickup Accordion Outlets
    @IBOutlet weak var pickupHeaderContainer: UIView!
    @IBOutlet weak var pickupHeaderTitleLabel: UILabel!
    @IBOutlet weak var pickupHeaderIconImageView: UIImageView!
    @IBOutlet weak var pickupHeaderChevron: UIImageView!
    @IBOutlet weak var pickupDetailsStack: UIStackView!
    // Pickup Day Selector Outlets
    @IBOutlet weak var pickupMon: UIButton!
    @IBOutlet weak var pickupTue: UIButton!
    @IBOutlet weak var pickupWed: UIButton!
    @IBOutlet weak var pickupThu: UIButton!
    @IBOutlet weak var pickupFri: UIButton!
    @IBOutlet weak var pickupSat: UIButton!
    // Nested pickup stops table view
    @IBOutlet weak var pickupStopsTableView: DynamicHeightTableView!
    // Drop Accordion Outlets
    @IBOutlet weak var dropHeaderContainer: UIView!
    @IBOutlet weak var dropHeaderTitleLabel: UILabel!
    @IBOutlet weak var dropHeaderIconImageView: UIImageView!
    @IBOutlet weak var dropHeaderChevron: UIImageView!
    @IBOutlet weak var dropDetailsStack: UIStackView!
    // Drop Day Selector Outlets
    @IBOutlet weak var dropMon: UIButton!
    @IBOutlet weak var dropTue: UIButton!
    @IBOutlet weak var dropWed: UIButton!
    @IBOutlet weak var dropThu: UIButton!
    @IBOutlet weak var dropFri: UIButton!
    @IBOutlet weak var dropSat: UIButton!
    @IBOutlet weak var bottomRouteContainer: UIView!
    // Nested drop stops table view
    @IBOutlet weak var dropStopsTableView: DynamicHeightTableView!
    // Footer Outlets
    @IBOutlet weak var findMyBusButton: UIButton!
    
    // Action Closures
    var onTogglePickup: (() -> Void)?
    var onToggleDrop: (() -> Void)?
    var onFindMyBus: (() -> Void)?
    var onFindPickupMyBus: ((Int) -> Void)?
    var onFindDropMyBus: ((Int) -> Void)?
    var onSizeChanged: (() -> Void)?
    private var pickupStops: [Stops] = []
    private var dropStops: [Stops] = []
    private var userStopId: String = ""
    var myLat : String?
    var myLong : String?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Style main card
        mainCardView.layer.cornerRadius = 24
        mainCardView.backgroundColor = .white
        mainCardView.layer.shadowColor = UIColor.black.cgColor
        mainCardView.layer.shadowOpacity = 0.05
        mainCardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        mainCardView.layer.shadowRadius = 16
        
        // Find My Bus Button styling
        
        findMyBusButton.layer.cornerRadius = 16
        locationPinbackgroundview.layer.cornerRadius = 12
        studentLocationfullView.layer.cornerRadius = 13
        topIconContainer.layer.cornerRadius = 16
        bottomRouteContainer.layer.cornerRadius = 16
        pickupHeaderContainer.layer.cornerRadius = 8
        dropHeaderContainer.layer.cornerRadius = 8
        findMyBusButton.layer.shadowColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 0.3).cgColor
        findMyBusButton.layer.shadowOpacity = 0.8
        findMyBusButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        findMyBusButton.layer.shadowRadius = 12
        
        // Tap recognizer for Pickup Header
        let pickupTap = UITapGestureRecognizer(target: self, action: #selector(handlePickupTap))
        pickupHeaderContainer.addGestureRecognizer(pickupTap)
        pickupHeaderContainer.isUserInteractionEnabled = true
        
        // Tap recognizer for Drop Header
        let dropTap = UITapGestureRecognizer(target: self, action: #selector(handleDropTap))
        dropHeaderContainer.addGestureRecognizer(dropTap)
        dropHeaderContainer.isUserInteractionEnabled = true
        
        // Setup table views
        setupNestedTableView(pickupStopsTableView)
        setupNestedTableView(dropStopsTableView)
        
        pickupStopsTableView.onContentSizeChange = { [weak self] in
            guard let self = self else { return }
            self.invalidateIntrinsicContentSize()
            self.onSizeChanged?()
        }
        
        dropStopsTableView.onContentSizeChange = { [weak self] in
            guard let self = self else { return }
            self.invalidateIntrinsicContentSize()
            self.onSizeChanged?()
        }
     
    }
    
    @IBAction func findmydropbusAct(_ sender: UIButton) {
        onFindDropMyBus?(sender.tag)
    }
    @IBAction func findmypickbusAct(_ sender: UIButton) {
        onFindPickupMyBus?(sender.tag)
    }
    private func setupNestedTableView(_ tableView: DynamicHeightTableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.backgroundColor = .clear
        
        // Register StopTimelineCell
        tableView.register(UINib(nibName: "StopTimelineCell", bundle: nil), forCellReuseIdentifier: "StopTimelineCell")
    }
    
    @objc private func handlePickupTap() {
        onTogglePickup?()
    }
    
    @objc private func handleDropTap() {
        onToggleDrop?()
    }
    
    @IBAction func findMyBusButtonTapped(_ sender: UIButton) {
        onFindMyBus?()
    }
    
    func configure(with data: StudentRouteData, isPickupExpanded: Bool, isDropExpanded: Bool) {
        self.userStopId = data.stop_id ?? ""
        //
        
        topIconContainer.backgroundColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
        bottomRouteContainer.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 1.0)
        
        // 1. Header Information
        routeLabel.text = data.route_name
        stopSubtitleLabel.text = data.stop_name
        pickupTimeLabel.text = data.tentative_pickup_time
        dropTimeLabel.text = data.tentative_drop_time
        busNumberValueLabel.text = data.vehicle_reg_no
        
        // 2. Pickup Accordion Layout
        pickupHeaderChevron.image = UIImage(systemName: isPickupExpanded ? "chevron.up" : "chevron.down")
        pickupDetailsStack.isHidden = !isPickupExpanded
        
       
            pickupHeaderContainer.layer.borderColor = UIColor(red: 15/255, green: 25/255, blue: 45/255, alpha: 1.0).cgColor
        
        
        // 3. Drop Accordion Layout
        dropHeaderChevron.image = UIImage(systemName: isDropExpanded ? "chevron.up" : "chevron.down")
        dropDetailsStack.isHidden = !isDropExpanded
        
       
            dropHeaderContainer.layer.borderColor = UIColor(red: 220/255, green: 235/255, blue: 225/255, alpha: 1.0).cgColor
       
        
        // 4. Pickup Day Selector & Timeline Setup
        if let pickingJourney = data.stopping_points?.first(where: { $0.journey_type == "PICKING" }) {
            self.pickupStops = pickingJourney.stops ?? []
            let pickupButtons = [pickupMon!, pickupTue!, pickupWed!, pickupThu!, pickupFri!, pickupSat!]
            configureDaySelector(buttons: pickupButtons, workingDays: pickingJourney.working_days ?? [])
            pickupStopsTableView.reloadData()
            pickupStopsTableView.layoutIfNeeded()
        }
        
        // 5. Drop Day Selector & Timeline Setup
        if let droppingJourney = data.stopping_points?.first(where: { $0.journey_type == "DROPPING" }) {
            self.dropStops = droppingJourney.stops ?? []
            let dropButtons = [dropMon!, dropTue!, dropWed!, dropThu!, dropFri!, dropSat!]
            configureDaySelector(buttons: dropButtons, workingDays: droppingJourney.working_days ?? [])
            dropStopsTableView.reloadData()
            dropStopsTableView.layoutIfNeeded()
        }
        
        self.layoutIfNeeded()
    }
    
    private func configureDaySelector(buttons: [UIButton], workingDays: [String]) {
        let daysOfWeek = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
        let daysShort = ["MON", "TUE", "WED", "THU", "FRI", "SAT"]
        
        for (index, button) in buttons.enumerated() {
            let dayName = daysOfWeek[index]
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"

            let currentDay = formatter.string(from: Date()).uppercased()

            let isWorking = workingDays.contains(daysOfWeek[index])
            let isSelected = (daysOfWeek[index] == currentDay)// Default active day in the mockup
            
            if isSelected {
                button.backgroundColor = UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0)
                button.setTitleColor(.white, for: .normal)
                button.layer.borderWidth = 0
            } else if isWorking {
                button.backgroundColor = UIColor(red: 242/255, green: 245/255, blue: 252/255, alpha: 1.0)
                button.setTitleColor(UIColor(red: 45/255, green: 130/255, blue: 255/255, alpha: 1.0), for: .normal)
                button.layer.borderWidth = 0
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(UIColor.lightGray, for: .normal)
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == pickupStopsTableView {
            return pickupStops.count
        } else if tableView == dropStopsTableView {
            return dropStops.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StopTimelineCell", for: indexPath) as! StopTimelineCell
        
        if tableView == pickupStopsTableView {
            let stop = pickupStops[indexPath.row]
            let isYourStop = (stop.stop_id == userStopId)
            cell.configure(
                number: "\(indexPath.row + 1)",
                stopName: stop.stop_name ?? "",
                time: stop.stop_time ?? "",
                landmark: stop.landmark ?? "",
                isYourStop: isYourStop,
                isFirst: indexPath.row == 0,
                isLast: indexPath.row == pickupStops.count - 1,
                journeyType: "PICKING"
            )
        } else if tableView == dropStopsTableView {
            let stop = dropStops[indexPath.row]
            let isYourStop = (stop.stop_id == userStopId)
            if isYourStop {
                  let latitude = stop.latitude
                  let longitude = stop.longitude
                  myLat = latitude
                  myLong = longitude
                  print("Your Stop Lat: \(latitude ?? "")")
                  print("Your Stop Long: \(longitude ?? "")")
              }
            cell.configure(
                number: "\(indexPath.row + 1)",
                stopName: stop.stop_name ?? "",
                time: stop.stop_time ?? "",
                landmark: stop.landmark ?? "",
                isYourStop: isYourStop,
                isFirst: indexPath.row == 0,
                isLast: indexPath.row == dropStops.count - 1,
                journeyType: "DROPPING"
            )
        }
        
        return cell
    }
}
