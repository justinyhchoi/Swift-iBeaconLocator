
//
//  ViewController.swift
//  BeaconSpot
//
//  Created by someone in the world on 10/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import CoreBluetooth

// minor = lap counter +1

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var btnSwitchSpotting: UIButton!
    
    @IBOutlet weak var lblBeaconReport: UILabel!
    
    @IBOutlet weak var lblBeaconDetails: UILabel!
    
    @IBOutlet weak var lbl1: UILabel!
    
    @IBOutlet weak var lbl2: UILabel!
    
    @IBOutlet weak var lbl3: UILabel!
    
    var beaconRegion: CLBeaconRegion!
    
    var locationManager: CLLocationManager!
    
    var isSearchingForBeacons = false
    
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    
    var lastProximity: CLProximity! = CLProximity.unknown
    
    var lapCount: [Int] = [0, 0, 0]
    
    var sensitivity:[CLProximity] = [ .far, .immediate, .near]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lblBeaconDetails.isHidden = true
        btnSwitchSpotting.layer.cornerRadius = 30.0
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let uuid = UUID(uuidString: "INSERT UUID")
        beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "INSERT IDENTIFIER")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    
    
    // MARK: IBAction method implementation
    
    @IBAction func switchSpotting(_ sender: AnyObject) {
        if !isSearchingForBeacons {
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Stop Spotting", for: UIControl.State())
            lblBeaconReport.text = "Spotting beacons..."
        }
        else {
            locationManager.stopMonitoring(for: beaconRegion)
            locationManager.stopRangingBeacons(in: beaconRegion)
            locationManager.stopUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Start Spotting", for: UIControl.State())
            lblBeaconReport.text = "Not running"
            lblBeaconDetails.isHidden = true
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
    
    func locationManager(_ manager: CLLocationManager!, didStartMonitoringFor region: CLRegion!) {
        locationManager.requestState(for: region)
    }
    
    
    func locationManager(_ manager: CLLocationManager!, didDetermineState state: CLRegionState, for region: CLRegion!) {
        if state == CLRegionState.inside {
            locationManager.startRangingBeacons(in: beaconRegion)
        }
        else {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
    }

    
    func locationManager(_ manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        lblBeaconReport.text = "Beacon in range"
        lblBeaconDetails.isHidden = false
    }
    
    
    func locationManager(_ manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        lblBeaconReport.text = "No beacons in range"
        lblBeaconDetails.isHidden = true
    }
    
    
    func locationManager(_ manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        var shouldHideBeaconDetails = true
        
        if let foundBeacons = beacons {
            if foundBeacons.count > 0 {
                if let closestBeacon = foundBeacons[0] as? CLBeacon {
                    if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                        lastFoundBeacon = closestBeacon
                        lastProximity = closestBeacon.proximity
                        
                        var proximityMessage: String!
                        switch lastFoundBeacon.proximity {
                        case CLProximity.immediate:
                            proximityMessage = "Very close"
                            
                        case CLProximity.near:
                            proximityMessage = "Near"
                            
                        case CLProximity.far:
                            proximityMessage = "Far far away"
                            
                        default:
                            proximityMessage = "Where's the beacon? ;)"
                        }
                        
                        shouldHideBeaconDetails = false
                        
                        lblBeaconDetails.text = "Beacon Details:\nMajor = " +
                            String(closestBeacon.major.int32Value) + "\nMinor = " +
                            String(closestBeacon.minor.int32Value) + "\nDistance: " +
                            proximityMessage
                        
                        var x = Int(closestBeacon.minor.int32Value)
                        lapCount[x] += 1
                    
                    
                        switch x {
                        case 1:
                            lbl1.text = String(lapCount[1])
                            
                        case 2:
                            lbl2.text = String(lapCount[2])
                            
                        case 3:
                            lbl3.text = String(lapCount[3])
                            
                        default:
                            print("Unexpected minor number")
                        }
                        
                    }
                }
            }
        }
        
        lblBeaconDetails.isHidden = shouldHideBeaconDetails
    }
 
    
    func locationManager(_ manager: CLLocationManager!, didFailWithError error: Error) {
        print(error)
    }
    
    
    func locationManager(_ manager: CLLocationManager!, monitoringDidFailFor region: CLRegion!, withError error: Error) {
        print(error)
    }
    
    
    func locationManager(_ manager: CLLocationManager!, rangingBeaconsDidFailFor region: CLBeaconRegion!, withError error: Error) {
        print(error)
    }
}

