//
//  ViewController.swift
//  HelloMyiBeacon
//
//  Created by Mrosstro on 2018/11/22.
//  Copyright © 2018 Mrosstro. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet weak var infoLabel: UILabel!
    
    let beaconUUID = UUID(uuidString: "84288B...")
    var beaconRegion: CLBeaconRegion!
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.requestAlwaysAuthorization()
        manager.delegate = self
        
        // Prepare beaconRegion
        beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!, identifier: "Beacon")
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
    }

    @IBAction func detectBeaconEnableValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            manager.startMonitoring(for: beaconRegion)
        } else {
            manager.stopMonitoring(for: beaconRegion)
            manager.stopRangingBeacons(in: beaconRegion)
        }
    }
}

// MARK: - Common Methods
extension ViewController {
    func showNotification(_ message: String) {
        // 當是前景模式時
        if UIApplication.shared.applicationState == .active {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            present(alert, animated: true)
        } else {  // Background
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "iBeacon state changed."
            content.body = message
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(identifier: "Alert", content: content, trigger: trigger)
            center.add(request) { (error) in
                // Add OK or ERROR?...
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate Methods
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            showNotification("Inside beacon region: \(region.identifier)")
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        } else {  // .outside
            showNotification("Outside beacon region: \(region.identifier)")
            manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            var infoLabelBG: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            let proximity: String
            switch beacon.proximity {
            case .unknown:
                proximity = "不在這"
                infoLabelBG = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            case .immediate:
                proximity = "近"
                infoLabelBG = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            case .near:
                proximity = "中"
                infoLabelBG = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            case .far:
                proximity = "遠"
                infoLabelBG = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            }
            infoLabel.text = "\(region.identifier)\n \(proximity)\n \(beacon.rssi)\n \(beacon.accuracy)"
            infoLabel.backgroundColor = infoLabelBG
            
        }
    }
}
