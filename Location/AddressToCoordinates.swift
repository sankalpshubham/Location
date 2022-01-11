//
//  AddressToCoordinates.swift
//  Location
//
//  Created by Sankalp Shubham on 12/17/20.
//  Copyright © 2020 Sankalp Shubham. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class AddressToCoordinates: UIViewController {
    
    //apple given code ----*
    func getCoordinate( addressString : String, completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
}
