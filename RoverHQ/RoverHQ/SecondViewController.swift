//
//  SecondViewController.swift
//  RoverHQ
//
//  Created by Thaynara Silva on 06/03/2018.
//  Copyright © 2018 Thaynara Silva. All rights reserved.
//

import UIKit
import MapKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var orientationBtn: UIButton!
    @IBOutlet weak var orientationLabel: UILabel!
    let upright = UIImage(named: "upright")
    let upsideDown = UIImage(named: "upsideDown")
    let rightSide = UIImage(named: "rightSide")
    let leftSide = UIImage(named: "leftSide")

    @IBOutlet weak var impactBtn: UIButton!
    @IBOutlet weak var impactLabel: UILabel!
    let normal = UIImage(named: "normal")
    let back = UIImage(named: "back")
    let front = UIImage(named: "front")
    let left = UIImage(named: "left")
    let right = UIImage(named: "right")
    let top = UIImage(named: "top")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        orientationBtn.isUserInteractionEnabled = false
        orientationBtn.tintColor = UIColor.black
        
        impactBtn.isUserInteractionEnabled = false
        impactBtn.setImage(back, for: UIControlState.normal)
        
        self.updateStats()

        
        let currentLocation = CLLocationCoordinate2D(latitude: StatsAndMetrics.globalMetricsVariables.latitude, longitude: StatsAndMetrics.globalMetricsVariables.longitude)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(currentLocation, span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = currentLocation
        mapView.addAnnotation(annotation)
        
    }
    
    func updateStats() {
        self.updateOrientation(orientationCode: StatsAndMetrics.globalMetricsVariables.orientation)
        self.updateImpactDetected(detectedCode: StatsAndMetrics.globalMetricsVariables.impact)
    }
    
    func updateOrientation(orientationCode: Int) {
        switch orientationCode {
        case 0:
            orientationBtn.setImage(upright, for: UIControlState.normal)
            orientationLabel.text = "Upright"
        case 1:
            orientationBtn.setImage(upsideDown, for: UIControlState
            .normal)
            orientationLabel.text = "Rover upside down!"
        case 2:
            orientationBtn.setImage(rightSide, for: UIControlState.normal)
            orientationLabel.text = "Rover on it's right side!"
        case 3:
            orientationBtn.setImage(leftSide, for: UIControlState.normal)
            orientationLabel.text = "Rover on it's left side!"
        default:
            orientationBtn.setImage(upright, for: UIControlState.normal)
            orientationLabel.text = "Upright"
        }
    }
    
    func updateImpactDetected(detectedCode: Int) {
        switch detectedCode {
        case 0:
            impactBtn.setImage(normal, for: UIControlState.normal)
            impactLabel.text = "No impact detected."
        case 1:
            impactBtn.setImage(back, for: UIControlState.normal)
            impactLabel.text = "Rear impact detected!"
        case 2:
            impactBtn.setImage(front, for: UIControlState.normal)
            impactLabel.text = "Front impact detected!"
        case 3:
            impactBtn.setImage(right, for: UIControlState.normal)
            impactLabel.text = "Right side impact detected!"
        case 4:
            impactBtn.setImage(left, for: UIControlState.normal)
            impactLabel.text = "Left side impact detected!"
        case 5:
            impactBtn.setImage(top, for: UIControlState.normal)
            impactLabel.text = "Top impact detected!"
        default:
            impactBtn.setImage(normal, for: UIControlState.normal)
            impactLabel.text = "No impact detected."
        }
    }
    
}

