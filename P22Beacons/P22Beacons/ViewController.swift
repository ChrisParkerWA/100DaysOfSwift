//
//  ViewController.swift
//  P22Beacons
//
//  Created by Chris Parker on 7/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    //  Challenge 2: Add a second label to the app that shows new text depending on which beacon was located.
    @IBOutlet var identifier: UILabel!
    @IBOutlet var distanceReading: UILabel!      
    @IBOutlet var rangeView: UIView!
    
    var locationManager: CLLocationManager?
    
    var activeBeaconUUID: UUID?
    
    //  Challenge 2: Add two or three other iBeacons in the Detect Beacon app and add their UUIDs to your app.
    let beacons: [UUID: String] = [
        UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")! : "Apple Beacon 1",
        UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")! : "Apple Beacon 2",
        UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")! : "Apple Beacon 3"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        identifier.text = "Not In Range"
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        rangeView.layer.cornerRadius = 128
        rangeView.backgroundColor = .gray
        view.backgroundColor = .gray
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        
        for (uuid, identifier) in beacons {
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: identifier)
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(in: beaconRegion)
        }
        
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            
            //  Challenge 3: Add a circle to your view, then use animation to scale it up and down depending on the distance from the beacon.
            switch distance {
                
            case .far:
                self.view.backgroundColor = .white
                self.rangeView.backgroundColor = .blue
                self.animateCircle(scale: 0.25)
                self.distanceReading.text = "FAR"
                
            case .near:
                self.view.backgroundColor = .white
                self.rangeView.backgroundColor = .orange
                self.animateCircle(scale: 0.5)
                self.distanceReading.text = "NEAR"
                
            case .immediate:
                self.view.backgroundColor = .white
                self.rangeView.backgroundColor = .red
                self.animateCircle(scale: 1.0)
                self.distanceReading.text = "RIGHT HERE"
                
            default:
                self.view.backgroundColor = .gray
                self.rangeView.backgroundColor = .gray
                self.identifier.text = "Not In Range"
                self.animateCircle(scale: 0.001)
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
            
            //  Challenge 1: Write code to display an alert when beacon is first detected.
            //  Challnege 2: Add a second label to the app that shows new text depending on which beacon was located.
            if activeBeaconUUID != beacon.proximityUUID {
                activeBeaconUUID = beacon.proximityUUID
                identifier.text = self.beacons[activeBeaconUUID!]
                showAlert(beacon: beacon)
            }
        }
    }
    
    func showAlert(beacon: CLBeacon) {
        //  Challenge 1 & 2
        let ac = UIAlertController(title: "Beacon Detected", message:
            """
            Identifier: \(beacons[beacon.proximityUUID] ?? "No Identifier")\n
            UUID: \(beacon.proximityUUID)
            """,
            preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func animateCircle(scale: CGFloat) {
        //  Challenge 3:  Add a circle to your view, then use animation to scale it up and down depending on the distance from the beacon.
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0, options: [], animations: {
            self.rangeView.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }

}

