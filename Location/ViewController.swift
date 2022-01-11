//
//  ViewController.swift
//  Location
//
//  Created by Sankalp Shubham on 3/7/20.
//  Copyright © 2020 Sankalp Shubham. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation
import UserNotifications
import Foundation
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    
    //Constant for LocationManager
    let locationManager  : CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var destinationNameBar: UITextField!
    @IBOutlet weak var phoneNumberBar: UITextField!
    
    let myCoordinates = AddressToCoordinates()
    var phoneNumber : String = ""
    var coordinates2D : CLLocationCoordinate2D = CLLocationCoordinate2D()
    var geoFencRegion : CLCircularRegion = CLCircularRegion()
    
    override func viewDidLoad() {                   //DO we NEED the HomeViewController then? Just Remove?
        super.viewDidLoad()
        view.snapshotView(afterScreenUpdates: true)                 // does this not change ViewSnapShot warning?!
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)                              // to dismiss the keyboard
        
        requestPermissionNotifications()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 10
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func homeButton(_ sender: UIButton) {                                     // this just ends the app when clicked on Home
        exit(0)
    }
    
    // monitor the location
    @IBAction func startMonitoringLocation(_ sender: UIButton) {
        geoFencRegion = CLCircularRegion(center: coordinates2D, radius: 50, identifier: destinationNameBar.text!)
        locationManager.startMonitoring(for: geoFencRegion)
    }
    
    // entered location
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered: \(region.identifier)")
        postLocalNotifications(eventTitle: "Entered: \(region.identifier)")
        sendMessage(message: "Your user arrived at the destination")
        locationManager.stopMonitoring(for: geoFencRegion)
    }
    
    // exited location -- Maybe not needed since we are just monitoring destination
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        print("Exited: \(region.identifier)")
//        postLocalNotifications(eventTitle: "Exited: \(region.identifier)")
//        sendText(message: "Your user left the destination")
//    }
    
    // print the updated location every few meters
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations {
            print("\(String(describing: index)) : \(currentLocation)")
        }
    }
    
    
    // setup all the variables to run the main program and monitor location --------------
    @IBAction func enterAddress(_ sender: UIButton) {
        self.phoneNumber = phoneNumberBar.text!
        myCoordinates.getCoordinate(addressString: addressBar.text!) { (myCoordinate, error) in
            if error == nil {
                self.coordinates2D.latitude = myCoordinate.latitude
                self.coordinates2D.longitude = myCoordinate.longitude
            }
        }
        
        let convertTo2D = CoordinateViewController()
        if convertTo2D.CLLocationCoordinate2DIsValid(coordinates2D) == false {
            print("Give me some valid coordinates to process!")
        }
    }
    
    func sendMessage(message: String) {
        if let accountSID = ProcessInfo.processInfo.environment["TWILIO_ACCOUNT_SID"], let authToken = ProcessInfo.processInfo.environment["TWILIO_AUTH_TOKEN"] {
            
            let url = "https://api.twilio.com/2010-04-01/Accounts/ACe9af4c70887a4bd6d54354099409fda6/Messages"
            let parameters = ["From": "+14159037449", "To": phoneNumber, "Body": message]      //from: Twilio phone no.
            
            AF.request(url, method: .post, parameters: parameters)
                .authenticate(username: accountSID, password: authToken)
                .responseJSON { response in
                    debugPrint(response)
                }
            print("Worked!")
        } else {
            print("Did not work!")
        }
    }
    
    // request notifcation permissions --------------
    func requestPermissionNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }
                else{
                    if( isAuthorized ){
                        print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                    }
                    else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Turn on Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }

    // send post notification to the user phone --------------
    func postLocalNotifications(eventTitle:String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        content.body = "You've entered a new region"
        content.sound = UNNotificationSound.default // there was an error here when there was "()" after "default"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "Region", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }

}
