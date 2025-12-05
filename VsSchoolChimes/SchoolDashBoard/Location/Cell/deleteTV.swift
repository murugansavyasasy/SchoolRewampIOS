//
//  LocationTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by Chandhru on 05/09/25.
//

import UIKit
import CoreLocation


// MARK: - Table View Cell
class deleteTV: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var distancePoint: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var coordinatesLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var visitLbl: UILabel!
    @IBOutlet weak var placeView: UIView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    
    // MARK: - Properties
    private var locationData: GeometricLocation?
    private var indexPath: IndexPath?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        outerView.setShadow()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Rounded buttons
        editBtn.layer.cornerRadius = editBtn.frame.width / 2
        distancePoint.layer.cornerRadius = distancePoint.frame.width / 2
        deleteBtn.layer.cornerRadius = deleteBtn.frame.width / 2
        iconView.layer.cornerRadius = iconView.frame.width / 2
        placeView.layer.cornerRadius = 10
        editBtn.clipsToBounds = true
        deleteBtn.clipsToBounds = true
        [editBtn, deleteBtn].forEach { btn in
            btn?.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            btn?.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }
    
    // MARK: - Configuration
    func configure(with locationData: GeometricLocation, at indexPath: IndexPath) {
        self.locationData = locationData
        self.indexPath = indexPath
        // Set location label
        locationLbl.text = locationData.location?.trimmingCharacters(in: .whitespacesAndNewlines)
        // Coordinates label
        if let lat = Double(locationData.latitude ?? ""),
           let lng = Double(locationData.longitude ?? "") {
            coordinatesLbl.text = String(format: "%.6f, %.6f", lat, lng)
            // Get the location name from coordinates
            getLocationName(latitude: lat, longitude: lng) { locationName in
                DispatchQueue.main.async {
                    self.placeLbl.text = locationName ?? "Unknown location"
                }
            }
        } else {
            coordinatesLbl.text = "\(locationData.latitude ?? "-"), \(locationData.longitude ?? "-")"
            placeLbl.text = "Unknown location"
        }
        
        // Distance label
        if let distanceValue = Int(locationData.distance ?? "") {
            distanceLbl.text = "±\(distanceValue) meters"
        } else if let distanceStr = locationData.distance {
            distanceLbl.text = "±\(distanceStr) meters"
        } else {
            distanceLbl.text = "—"
        }
        
        // Visit count
        if let visits = locationData.visitedCount {
            visitLbl.text = "Visits: \(visits)"
        } else {
            visitLbl.text = nil
        }
        // Time label
        timeLbl.text = /*locationData.time */ "2 hours ago"
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        guard let location = locationData else { return }
        accessibilityLabel = """
        Location: \(location.location ?? ""),
        Coordinates: \(coordinatesLbl.text ?? "") - 
        Distance: \(distanceLbl.text ?? "")
        """
        editBtn.accessibilityLabel = "Edit location \(location.location ?? "")"
        deleteBtn.accessibilityLabel = "Delete location \(location.location ?? "")"
    }
    
    // MARK: - Button Animation
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction) {
            sender.transform = .identity
        }
    }
}

// MARK: - Reverse Geocoding Function
func getLocationName(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: latitude, longitude: longitude)
    geocoder.reverseGeocodeLocation(location) { placemarks, error in
        if let error = error {
            print("Reverse geocoding error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        if let placemark = placemarks?.first {
            let name = placemark.name ?? ""
            let locality = placemark.locality ?? ""
            let administrativeArea = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""
            
            let locationName = [name, locality, administrativeArea, country]
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
            
            completion(locationName)
        } else {
            completion(nil)
        }
    }
}
