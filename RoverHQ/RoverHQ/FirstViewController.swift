//
//  FirstViewController.swift
//  RoverHQ
//
//  Created by Thaynara Silva on 06/03/2018.
//  Copyright © 2018 Thaynara Silva. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, StreamDelegate {

    // Referencing the control buttons from UI
    @IBOutlet weak var btnUp: UIButton!
    @IBOutlet weak var btnDown: UIButton!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var btnDisconnect: UIButton!
    @IBOutlet weak var btnMode: UIButton!
    
    // Set Raspberry Pi socket server variables
    let HOST = "172.20.10.5"
    let PORT = 8888
    
    // Set network variables
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    // Data received variable
    var buffer = [UInt8](repeating: 0, count: 200)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load app with disconnect button disabled
        self.disable_btnDisconnect()
        self.updateStats()
    }
    
    // Force application to run in landscape mode
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    // Connect to server button function
    @IBAction func connect_to_server(_ sender: UIButton) {
        // Set up connection socket
        EnableSocket()
        
        // Disable connect to server button after connection has been made
        self.disable_btnConnect()
        
        // Enable disconnect from server button after connection has been made
        self.enable_btnDisconnect()
    }
    
    // Disconnect from server button function
    @IBAction func disconnect_from_server(_ sender: UIButton) {
        // Tell the server to disconnect
        let disconnect: Data = "disconnect".data(using: String.Encoding.utf8)!
        _ = disconnect.withUnsafeBytes{outputStream?.write($0, maxLength: disconnect.count)}
        
        // Disable disconnect from server button after connection has been terminated
        self.disable_btnDisconnect()
        
        // Enable connect to server button after connection has been terminated
        self.enable_btnConnect()
    }
    
    // Socket enabling function
    func EnableSocket() {
        print("Enabling Socket Communication!")
        Stream.getStreamsToHost(withName: HOST, port: PORT, inputStream: &inputStream, outputStream: &outputStream)
        
        // Initialize input and output streams
        inputStream?.delegate = self
        outputStream?.delegate = self
        
        // Schedule receivers for input and output streams in the current loop
        inputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        // Open input and output stream to server
        inputStream?.open()
        outputStream?.open()
    }
    
    // Stream handling function
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        // End of the connection between the raspberry pi and the app
        case Stream.Event.endEncountered:
            print("End Encountered!")
            // Pop up alert message
            let alert = UIAlertController(title: "Alert", message: "Connection terminated by the server.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in self.enable_btnConnect()}))
            self.present(alert, animated: true, completion: nil)
            
            // Disable disconnect from server button
            self.disable_btnDisconnect()
            
            print("Stop input and output streams")
            // Close input and output stream
            inputStream?.close()
            outputStream?.close()
            
            // Remove receivers from input and output streams
            inputStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            outputStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            
        //  Error occurred in the communication
        case Stream.Event.errorOccurred:
            print("Error Occurred!")
            // Pop up alert message
            let alert = UIAlertController(title: "Error", message: "Failed to connect to server", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in self.enable_btnConnect()}))
            self.present(alert, animated: true, completion: nil)
            
            // Disable disconnect from server button
            self.disable_btnDisconnect()
            
            print("Stop input and output streams")
            // Close input and output stream
            inputStream?.close()
            outputStream?.close()
            
            // Remove receivers from input and output streams
            inputStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            outputStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            
        // Receiving data in the communication socket
        case Stream.Event.hasBytesAvailable:
            print("Has Bytes Available!")
            if aStream == inputStream {
                inputStream!.read(&buffer, maxLength: buffer.count)
                let bufferString = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue)
                print(bufferString!)
            }
            
        // Space available in the communication socket
        case Stream.Event.hasSpaceAvailable:
            print("Has Space Available!")
            
        // Communication successful
        case Stream.Event.openCompleted:
            print("Open Completed!")
            btnConnect.setTitle("Connected to server", for: UIControlState.disabled)
        default:
            print("Default Case!")
        }
    }
    
    // Enable and disable connect to server button
    func enable_btnConnect() {
        btnConnect.alpha = 1
        btnConnect.isEnabled = true
        btnConnect.setTitleColor(UIColor.blue, for: UIControlState.normal)
    }
    
    func disable_btnConnect() {
        btnConnect.alpha = 0.3
        btnConnect.isEnabled = false
        btnConnect.setTitleColor(UIColor.gray, for: UIControlState.disabled)
    }
    
    // Enable and disable disconnect from server button
    func enable_btnDisconnect() {
        btnDisconnect.alpha = 1
        btnDisconnect.isEnabled = true
        btnDisconnect.setTitleColor(UIColor.blue, for: UIControlState.normal)
    }
    
    func disable_btnDisconnect() {
        btnDisconnect.alpha = 0.3
        btnDisconnect.isEnabled = false
        btnDisconnect.setTitleColor(UIColor.gray, for: UIControlState.disabled)
    }
    
    // Functions for control buttons
    @IBAction func btnUp_pressed(_ sender: UIButton) {
        // Tell server to move back wheels forward
        let data: Data = "forwardOn".data(using: String.Encoding.utf8)!
        _ = data.withUnsafeBytes{outputStream?.write($0, maxLength: data.count)}
    }
    
    @IBAction func btnUp_released(_ sender: UIButton) {
        // Tell server to stop moving back wheels forward
        let data: Data = "forwardOff".data(using: String.Encoding.utf8)!
        _ = data.withUnsafeBytes{outputStream?.write($0, maxLength: data.count)}
    }
    
    @IBAction func btnDown_pressed(_ sender: UIButton) {
        // Tell server to move back wheels backwards
        let data: Data = "reverseOn".data(using: String.Encoding.utf8)!
        _ = data.withUnsafeBytes{outputStream?.write($0, maxLength: data.count)}
    }
    
    @IBAction func btnDown_released(_ sender: UIButton) {
        // Tell server to stop moving back wheels backwards
        let data: Data = "reverseOff".data(using: String.Encoding.utf8)!
        _ = data.withUnsafeBytes{outputStream?.write($0, maxLength: data.count)}
    }
    
    @IBAction func btnLeft_pressed(_ sender: UIButton) {
        // Tell server to turn front wheels to the left
        let data: Data = "leftOn".data(using: String.Encoding.utf8)!
        _ = data.withUnsafeBytes{outputStream?.write($0, maxLength: data.count)}
    }
    
    @IBAction func btnLeft_released(_ sender: UIButton) {
        // Tell server to return front wheels to middle position
        let data: Data = "leftOff".data(using: String.Encoding.utf8)!
        _ = data.withUnsafeBytes{outputStream?.write($0, maxLength: data.count)}
    }
    
    @IBAction func btnRight_pressed(_ sender: UIButton) {
        // Tell server to turn front wheels to the right
        let data: Data = "rightOn".data(using: String.Encoding.utf8)!
        _ = data.withUnsafeBytes{outputStream?.write($0, maxLength: data.count)}
    }
    
    @IBAction func btnRight_released(_ sender: UIButton) {
        // Tell server to return front wheels to middle position
        let data: Data = "rightOff".data(using: String.Encoding.utf8)!
        _ = data.withUnsafeBytes{outputStream?.write($0, maxLength: data.count)}
    }
    
    // Functions to toggle between Automatic and Manual mode
    @IBAction func btnMode_clicked(_ sender: UIButton) {
        // Enable/Disable control buttons
        if btnUp.isEnabled == true {
            // Disable all control buttons
            btnUp.isEnabled = false
            btnDown.isEnabled = false
            btnLeft.isEnabled = false
            btnRight.isEnabled = false
            
            // Hide all control buttons
            btnUp.isHidden = true
            btnDown.isHidden = true
            btnLeft.isHidden = true
            btnRight.isHidden = true
        } else {
            // Enable all control buttons
            btnUp.isEnabled = true
            btnDown.isEnabled = true
            btnLeft.isEnabled = true
            btnRight.isEnabled = true
            
            // Show all the control buttons
            btnUp.isHidden = false
            btnDown.isHidden = false
            btnLeft.isHidden = false
            btnRight.isHidden = false
        }
        
        // Change button label to Automatic/Manual
        if btnMode.currentTitle == "Automatic" {
            btnMode.setTitle("Manual", for: UIControlState.normal)
        } else {
            btnMode.setTitle("Automatic", for: UIControlState.normal)
        }
    }
    
    func updateStats() {
        StatsAndMetrics.globalMetricsVariables.orientation = 0
        StatsAndMetrics.globalMetricsVariables.impact = 0
        StatsAndMetrics.globalMetricsVariables.latitude = 52.674984
        StatsAndMetrics.globalMetricsVariables.longitude = -8.648125
    }
}

