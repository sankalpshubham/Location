//
//  CoordinateViewController.swift
//  Location
//
//  Created by Sankalp Shubham on 3/28/20.
//  Copyright © 2020 Sankalp Shubham. All rights reserved.
//

import Foundation
import CoreLocation

class CoordinateViewController {
    
    func CLLocationCoordinate2DMake(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> CLLocationCoordinate2D {
        var coordinate2D : CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        coordinate2D.latitude = latitude
        coordinate2D.longitude = longitude
        //print("latitude value is " + (String)(latitude)) // to check the value of latitude
        
        return coordinate2D
    }

    func CLLocationCoordinate2DIsValid(_ coordinates: CLLocationCoordinate2D) -> Bool {
        if coordinates.latitude > 90 || coordinates.latitude < -90 {
            return false
        } else if coordinates.longitude > 180 || coordinates.longitude < -180 {
            return false
        }
        return true
    }
    
    
}
